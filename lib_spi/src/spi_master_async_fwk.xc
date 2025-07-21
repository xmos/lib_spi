// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>
#include <stdlib.h>

#include <print.h>
#include "spi.h"
extern "C"{
#include "spi_fwk.h"
}
#include "spi_master_shared_fwk.h"

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
void spi_master_async_fwk(server interface spi_master_async_if i[num_clients],
        static const size_t num_clients,
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 miso,
        out port p_ss,
        static const size_t num_slaves,
        clock cb0,
        clock cb1){

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
    spi_master_device_t spi_dev;
    unsafe{
        spi_master_init(&spi_master, cb0, (port)p_ss, (port)sclk, (port)mosi, (port)miso);
    }

    // By default use the port bit which is the number of the client (client 0 uses port bit 0 etc.)
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

                spi_master_device_init(&spi_dev, &spi_master,
                    ss_port_bit[device_index],
                    cpol, cpha,
                    source_clock,
                    divider,
                    spi_master_sample_delay_0,
                    0, 0 ,0 ,0 );

                spi_master.current_device = 0xffffffff; // This is needed to force mode and speed in spi_master_start_transaction()
                                                        // Otherwise fwk_spi sees the next transaction on the existing device as the same settings as last on the same client
                spi_master_start_transaction(&spi_dev);
    
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
                        spi_master_transfer(&spi_dev, (uint8_t*movable)&buffer_tx[0], &r8, 1);
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
                        spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t*)&r32, 4);
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
                        spi_master_transfer(&spi_dev, &((uint8_t*movable)buffer_tx)[buffer_current_index], &r8, 1);
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
                        spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t*)&r32, 4);
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

                spi_master_end_transaction(&spi_dev);

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

                    spi_master_device_init(&spi_dev, &spi_master,
                        ss_port_bit[new_device_index],
                        cpol, cpha,
                        source_clock,
                        divider,
                        spi_master_sample_delay_0,
                        0, 0 ,0 ,0 );

                    spi_master.current_device = 0xffffffff; // This is needed to force mode and speed in spi_master_start_transaction()
                                                            // Otherwise fwk_spi sees the next transaction on the existing device as the same settings as last on the same client
                    spi_master_start_transaction(&spi_dev);

                    active_device = new_device_index;
                    active_mode = mode;

                    buffer_nbytes = tr_buffer[index].buffer_nbytes;

                    if(buffer_nbytes != NBYTES_UNASSIGNED){
                        buffer_tx = move(tr_buffer[index].buffer_tx);
                        buffer_rx = move(tr_buffer[index].buffer_rx);
                        buffer_transfer_width = tr_buffer[index].buffer_transfer_width;
                        if(buffer_transfer_width == 8){
                            spi_master_transfer(&spi_dev, (uint8_t*movable)&buffer_tx[0], &r8, 1);
                            tmr :> default_case_time;
                            default_case_enabled = 1;
                        } else {
                            uint32_t data = byterev(buffer_tx[0]);
                            // uint32_t data = buffer_tx[0];
                            spi_master_transfer(&spi_dev, (uint8_t *)&data, (uint8_t*)&r32, 4);
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

            case i[int x].set_ss_port_bit(unsigned port_bit):{
                if(port_bit > SPI_MAX_DEVICES){
                    printstrln("Invalid port bit - must be less than SPI_MAX_DEVICES");
                }
                ss_port_bit[x] = port_bit;
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
                set_clock_on(cb0);
                return;
        }
    }

}
