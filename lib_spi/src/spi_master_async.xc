// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>

#include <print.h>
#include "spi.h"
#include "spi_master_shared.h"

#define SPI_MAX_DEVICES 32 //Used to size the array of which bit in the SS port maps to which device

typedef struct {
    unsigned client_id;
    unsigned device_index;
    unsigned speed_in_khz;
    spi_mode_t mode;
    size_t               buffer_nbytes;
    unsigned             buffer_transfer_width;
    uint32_t * movable   buffer_tx;
    uint32_t * movable   buffer_rx;

} transaction_request;
#define NBYTES_UNASSIGNED (-1)


[[combinable]]
void spi_master_async(server interface spi_master_async_if i[num_clients],
        static const size_t num_clients,
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 miso,
        out port p_ss,
        static const size_t num_slaves,
        clock cb){

    //These buffer are for the transaction requests
    transaction_request tr_buffer[num_clients]; ///FIXME num_clients
    unsigned            tr_tail = 0;
    unsigned            tr_fill = 0;

    //These buffers are for the active transaction
    uint32_t * movable  buffer_tx;
    uint32_t * movable  buffer_rx;
    size_t              buffer_nbytes;
    unsigned            buffer_current_index;
    unsigned            buffer_transfer_width;

    //These variables are for the active transaction state
    unsigned active_device;
    unsigned active_client;
    unsigned active_mode;
    int currently_performing_a_transaction = 0;

    //Setup fwk SPI master and device instance
    spi_master_t spi_master;
    spi_master_device_t spi_dev[num_slaves];
    spi_master_ss_clock_timing_t device_ss_clock_timing[num_slaves];                // Initialised below 
    spi_master_miso_capture_timing_t device_miso_capture_timing[num_slaves] = {{0}};// Default no delay
    
    unsafe{
        spi_master_init(&spi_master, cb, (port)p_ss, (port)sclk, (port)mosi, (port)miso);
        for(int i = 0; i < num_slaves; i++){
            device_ss_clock_timing[i].cs_to_clk_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
            device_ss_clock_timing[i].clk_to_cs_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
            spi_dev[i].cs_to_cs_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
        }
    }

    // By default use the port bit which is the number of the slave (slave 0 uses port bit 0 etc.)
    uint8_t ss_port_bit[SPI_MAX_DEVICES];
    for(int i = 0; i < SPI_MAX_DEVICES; i++){
        ss_port_bit[i] = i;
    }

    // Initial SS bit pattern - deselected
    p_ss <: 0xffffffff;

    // TMP MISO vals
    uint8_t r8;
    uint32_t r32;

    // Use as way of implementing a default case. Setting the default_case_time to the current time makes an event happen immediately
    // This is used for subsequent SPI transfers after the first during a transaction
    timer tmr;
    int default_case_time;
    int default_case_enabled = 0;

    while(1){
        select {
            case i[int x].begin_transaction(unsigned device_index, unsigned speed_in_khz, spi_mode_t mode):{
                //if doing a transaction then buffer this one
                if(currently_performing_a_transaction){
                    //Note, the tr_fill should never exceed num_clients if the calling protocol is respected
                    unsigned index = (tr_tail + tr_fill)%num_clients; //FIXME div?
                    tr_buffer[index].device_index = device_index;
                    tr_buffer[index].speed_in_khz = speed_in_khz;
                    tr_buffer[index].mode = mode;
                    tr_buffer[index].client_id = x;
                    tr_buffer[index].buffer_nbytes = NBYTES_UNASSIGNED;
                    tr_fill++;
                    break;
                }
 
                active_client = x;
                active_device = device_index;
                active_mode = mode;

                // Calculate clock divider and SPI mode vs CPOL/CPHA
                spi_master_source_clock_t source_clock;
                unsigned divider;
                spi_master_determine_clock_settings(&source_clock, &divider, speed_in_khz);

                unsigned cpol = mode >> 1;
                unsigned cpha = mode & 0x1;

                spi_master_device_init(&spi_dev[active_device], &spi_master,
                        ss_port_bit[active_device],
                        cpol, cpha,
                        source_clock,
                        divider,
                        device_miso_capture_timing[active_device].miso_sample_delay,
                        device_miso_capture_timing[active_device].miso_pad_delay,
                        device_ss_clock_timing[active_device].clk_to_cs_delay_ticks,
                        device_ss_clock_timing[active_device].cs_to_clk_delay_ticks,
                        spi_dev[active_device].cs_to_cs_delay_ticks); // Write same value back

                spi_master_start_transaction(&spi_dev[active_device]);
    
                buffer_current_index = 0;
                currently_performing_a_transaction = 1;  

                break;
            }

            case i[int x].init_transfer_array_8(uint8_t * movable inbuf,
                                                uint8_t * movable outbuf,
                                                size_t nbytes) :{
                // if(dbg) printstr("init_transfer_array_8 "); if(dbg) printintln(nbytes);
                if(x != active_client){
                    // Just buffer it
                    unsigned index;
                    for(unsigned j=0;j<num_clients;j++){
                        if(tr_buffer[j].client_id==x){
                            index = j;
                            break;
                        }
                    }
                    // Note we suppress the warning about re-interpretting 8b ptr as 32b in the lib makefile
                    tr_buffer[index].buffer_nbytes = nbytes;
                    tr_buffer[index].buffer_tx = (uint32_t * movable)move(outbuf);
                    tr_buffer[index].buffer_rx = (uint32_t * movable)move(inbuf);
                    tr_buffer[index].buffer_transfer_width = 8;
                } else {
                    // This is for the current client
                    buffer_nbytes = nbytes*sizeof(uint8_t);
                    buffer_tx = (uint32_t * movable)move(outbuf);
                    buffer_rx = (uint32_t * movable)move(inbuf);
                    if(buffer_nbytes == 0){
                        // Notify client
                        default_case_enabled = 0;
                        buffer_current_index = 0;
                        i[x].transfer_complete();
                    } else {
                        buffer_transfer_width = 8;
                        spi_master_transfer(&spi_dev[active_device], (uint8_t*movable)&buffer_tx[0], &r8, 1);
                        tmr :> default_case_time;
                        default_case_enabled = 1;   
                    }
                }
                break;
            }

            case i[int x].init_transfer_array_32(uint32_t * movable inbuf,
                                                 uint32_t * movable outbuf,
                                                 size_t nwords):{
                if(x != active_client){
                    // Just buffer it 
                    unsigned index;
                    for(unsigned j=0;j<num_clients;j++){
                        if(tr_buffer[j].client_id==x){
                            index = j;
                            break;
                        }
                    }
                    tr_buffer[index].buffer_nbytes = nwords*sizeof(uint32_t);
                    tr_buffer[index].buffer_tx = move(outbuf);
                    tr_buffer[index].buffer_rx = move(inbuf);
                    tr_buffer[index].buffer_transfer_width = 32;
                } else {
                    // This is for the current client
                    buffer_nbytes = nwords*sizeof(uint32_t);
                    buffer_tx = move(outbuf);
                    buffer_rx = move(inbuf);

                    if(buffer_nbytes == 0){
                        default_case_enabled = 0;
                        buffer_current_index = 0;
                        i[x].transfer_complete();
                    } else {
                        buffer_transfer_width = 32;
                        uint32_t data = byterev(buffer_tx[0]);
                        // uint32_t data = buffer_tx[0];
                        spi_master_transfer(&spi_dev[active_device], (uint8_t *)&data, (uint8_t*)&r32, 4);
                        tmr :> default_case_time;
                        default_case_enabled = 1;
                    }
                }
                break;
            }

            // This case handles the input from the last transfer
            case default_case_enabled => tmr when timerafter(default_case_time) :> int _:{
                //put the data into the correct array and send the next data if need be
                if(buffer_transfer_width == 8){
                    uint32_t data = byterev((uint32_t)r8<<24); // TODO - this is just r8!???
                    ((uint8_t*movable)buffer_rx)[buffer_current_index] = (uint8_t)data;
                    buffer_current_index++;
                    if((buffer_current_index*sizeof(uint8_t)) == buffer_nbytes){
                        default_case_enabled = 0;
                        buffer_current_index = 0;
                        i[active_client].transfer_complete();
                    } else {
                        spi_master_transfer(&spi_dev[active_device], &((uint8_t*movable)buffer_tx)[buffer_current_index], &r8, 1);
                        tmr :> default_case_time;
                        default_case_enabled = 1;
                    }
                } else {
                    uint32_t data = byterev(r32);
                    buffer_rx[buffer_current_index] = data;
                    buffer_current_index++;
                    if((buffer_current_index*sizeof(uint32_t)) == buffer_nbytes){
                        default_case_enabled = 0;
                        buffer_current_index = 0;
                        i[active_client].transfer_complete();
                    } else {
                        uint32_t data = byterev(buffer_tx[buffer_current_index]);
                        spi_master_transfer(&spi_dev[active_device], (uint8_t *)&data, (uint8_t*)&r32, 4);
                        tmr :> default_case_time;
                        default_case_enabled = 1;
                    }
                }
                break;
            }

            //Note, end transaction can only be called from the active_client
            case i[int x].end_transaction(unsigned ss_deassert_time):{
                //xassert(x == active_client);

                //An end_transaction can only be completed after all transfers
                //have been completed

                spi_dev[active_device].cs_to_cs_delay_ticks = ss_deassert_time;
                spi_master_end_transaction(&spi_dev[active_device]);

                if(tr_fill > 0){
                    //begin a new transaction - the tail of the list is the next one to go
                    unsigned index = tr_tail%num_clients;
                    unsigned new_device_index = tr_buffer[index].device_index;
                    unsigned speed_in_khz = tr_buffer[index].speed_in_khz;
                    spi_mode_t mode = tr_buffer[index].mode;

                    active_client = tr_buffer[index].client_id;

                    tr_fill--;
                    tr_tail++;

                    // Put in generic start transaction stuff (Functionise?)
                    // Calculate clock divider and SPI mode vs CPOL/CPHA
                    spi_master_source_clock_t source_clock;
                    unsigned divider;
                    spi_master_determine_clock_settings(&source_clock, &divider, speed_in_khz);
                    unsigned cpol = mode >> 1;
                    unsigned cpha = mode & 0x1;

                    spi_master_device_init(&spi_dev[new_device_index], &spi_master,
                        ss_port_bit[new_device_index],
                        cpol, cpha,
                        source_clock,
                        divider,
                        device_miso_capture_timing[new_device_index].miso_sample_delay,
                        device_miso_capture_timing[new_device_index].miso_pad_delay,
                        device_ss_clock_timing[new_device_index].clk_to_cs_delay_ticks,
                        device_ss_clock_timing[new_device_index].cs_to_clk_delay_ticks,
                        spi_dev[new_device_index].cs_to_cs_delay_ticks); // Write same value back

                    spi_master_start_transaction(&spi_dev[new_device_index]);

                    active_device = new_device_index;
                    active_mode = mode;

                    buffer_nbytes = tr_buffer[index].buffer_nbytes;

                    if(buffer_nbytes != NBYTES_UNASSIGNED){
                        buffer_tx = move(tr_buffer[index].buffer_tx);
                        buffer_rx = move(tr_buffer[index].buffer_rx);
                        buffer_transfer_width = tr_buffer[index].buffer_transfer_width;
                        if(buffer_transfer_width == 8){
                            spi_master_transfer(&spi_dev[active_device], (uint8_t*movable)&buffer_tx[0], &r8, 1);
                            tmr :> default_case_time;
                            default_case_enabled = 1;
                        } else {
                            uint32_t data = byterev(buffer_tx[0]);
                            // uint32_t data = buffer_tx[0];
                            spi_master_transfer(&spi_dev[active_device], (uint8_t *)&data, (uint8_t*)&r32, 4);
                            tmr :> default_case_time;
                            default_case_enabled = 1;
                        }
                        buffer_current_index = 0;
                    }   
                } else {
                    currently_performing_a_transaction = 0;
                }
                break;
            }

            case i[int x].retrieve_transfer_buffers_8(uint8_t * movable &inbuf, uint8_t * movable &outbuf):{
                inbuf = (uint8_t*movable)move(buffer_rx);
                outbuf = (uint8_t*movable)move(buffer_tx);
                break;
            }

            case i[int x].retrieve_transfer_buffers_32(uint32_t * movable &inbuf, uint32_t * movable &outbuf):{
                inbuf = move(buffer_rx);
                outbuf = move(buffer_tx);
                break;
            }

            case i[int x].set_ss_port_bit(unsigned device_index, unsigned port_bit):{
                if(device_index > num_slaves){
                    printstrln("Invalid port bit - must be less than num_slaves");
                }
                ss_port_bit[device_index] = port_bit;

                break;
            }

            case i[int x].shutdown(void):
                move(buffer_rx);
                move(buffer_tx);
                // When using XC, then we need to enable/init so ports are still on
                p_ss <: 0xffffffff;
                // These just reset the ports and clk
                if (!isnull(mosi)) {
                    set_port_use_on(mosi);
                }
                set_port_use_on(miso);
                set_port_use_on(sclk);
                set_clock_on(cb);
                return;
        }
    }

}
