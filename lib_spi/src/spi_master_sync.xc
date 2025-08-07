// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <xclib.h>
#include <stdlib.h>
#include <stdio.h>
#include <print.h>
#include <platform.h>
#include <string.h>

#include "spi.h"
#include "spi_master_shared.h"


#pragma unsafe arrays
[[distributable]]
void spi_master(server interface spi_master_if i[num_clients],
        static const size_t num_clients,
        out buffered port:32 sclk,
        out buffered port:32 ?mosi,
        in buffered port:32 ?miso,
        out port p_ss, // Note only one SS port supported - individual bits in port may be used for different devices however
        static const size_t num_slaves,
        clock ?cb){

    // For clock-block based fast SPI
    spi_master_t spi_master;
    spi_master_device_t spi_dev[num_slaves];
    spi_master_ss_clock_timing_t device_ss_clock_timing[num_slaves];                // Initialised below 
    spi_master_miso_capture_timing_t device_miso_capture_timing[num_slaves] = {{0}};
    unsigned current_device;

    // For clock-blockless slow SPI
    unsigned clkblkless_period_ticks;

    // For all SPI types
    unsigned cpol = 0;
    unsigned cpha = 0;

    if(!isnull(cb)){
        unsafe{
            spi_master_init(&spi_master, (xclock_t)cb, (port_t)p_ss, (port_t)sclk, (port_t)mosi, (port_t)miso);
            // Set default timings
            for(int i = 0; i < num_slaves; i++){
                device_ss_clock_timing[i].cs_to_clk_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
                device_ss_clock_timing[i].clk_to_cs_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
                spi_dev[i].cs_to_cs_delay_ticks = SPI_MASTER_DEFAULT_SS_CLOCK_DELAY_TICKS;
                device_miso_capture_timing[i].miso_pad_delay = spi_master_sample_delay_1_2; // Half a SPI clock
                device_miso_capture_timing[i].miso_sample_delay = 0;                        // Default no delay
            }
        }
    } else {
        // Initial SS bit pattern - deselected
        p_ss <: 0xffffffff;
        sync(p_ss);
    }

    int accepting_new_transactions = 1;

    // By default use the port bit which is the number of the slave (slave 0 uses port bit 0 etc.)
    uint8_t ss_port_bit[num_slaves];
    for(int i = 0; i < num_slaves; i++){
        ss_port_bit[i] = i;
    }


    while(1){
        select {
            case accepting_new_transactions => i[int x].begin_transaction(unsigned device_index,
                unsigned speed_in_khz, spi_mode_t mode):{
                accepting_new_transactions = 0;
                current_device = device_index;

                // Grab mode bits
                cpol = mode >> 1;
                cpha = mode & 0x1;

                // Fast SPI state
                spi_master_source_clock_t source_clock;
                unsigned divider;

                if(isnull(cb)){
                    // Set the expected clock idle state on the clock port
                    partout(sclk, 1, cpol);
                    sync(sclk);

                    unsigned ss_port_val = ~(1 << ss_port_bit[current_device]);
                    p_ss <: ss_port_val;
                    clkblkless_period_ticks = (XS1_TIMER_KHZ + speed_in_khz - 1) / speed_in_khz; // round up (rounds speed down)
                } else {
                    spi_master_determine_clock_settings(&source_clock, &divider, speed_in_khz);

#if SPI_DEBUG_REPORT_ACTUAL_SPEED
                    unsigned actual_speed_khz = spi_master_get_actual_clock_rate(source_clock, divider);
                    printf("Actual speed_in_khz: %u div(%u) clock: (%s) %uMHz\n",
                        actual_speed_khz,
                        divider,
                        ((source_clock == spi_master_source_clock_ref) ? "ref" : "core"),
                        ((source_clock == spi_master_source_clock_ref) ? PLATFORM_REFERENCE_MHZ : PLATFORM_NODE_0_SYSTEM_FREQUENCY_MHZ));
#endif

                    spi_master_device_init(&spi_dev[current_device], &spi_master,
                        ss_port_bit[current_device],
                        cpol, cpha,
                        source_clock,
                        divider,
                        device_miso_capture_timing[current_device].miso_sample_delay,
                        device_miso_capture_timing[current_device].miso_pad_delay,
                        device_ss_clock_timing[current_device].clk_to_cs_delay_ticks,
                        device_ss_clock_timing[current_device].cs_to_clk_delay_ticks,
                        spi_dev[current_device].cs_to_cs_delay_ticks); // Write same value back

                    spi_master_start_transaction(&spi_dev[current_device]);
                }

                break;
            }

            case i[int x].end_transaction(unsigned ss_deassert_time):{
                if(isnull(cb)){
                    p_ss <: 0xffffffff;
                    delay_ticks(ss_deassert_time);
                } else {
                    spi_dev[current_device].cs_to_cs_delay_ticks = ss_deassert_time;
                    spi_master_end_transaction(&spi_dev[current_device]);
                }

                // Unlock the transaction
                accepting_new_transactions = 1;

                break;
            }

            case i[int x].transfer8(uint8_t data)-> uint8_t r :{
                if(isnull(cb)){
                    r = transfer8_sync_zero_clkblk(sclk, mosi, miso, data, clkblkless_period_ticks, cpol, cpha);
                } else {
                    spi_master_transfer(&spi_dev[current_device], (uint8_t *)&data, &r, 1);
                }

                break;
            }

            case i[int x].transfer32(uint32_t data) -> uint32_t r:{
                if(isnull(cb)){
                    r = transfer32_sync_zero_clkblk(sclk, mosi, miso, data, clkblkless_period_ticks, cpol, cpha);
                } else {
                    // For 32b words, we need to swap to big endian (standard for SPI) from little endian (XMOS)
                    // This means we transmit the MSByte first
                    data = byterev(data);
                    uint32_t read_val;                
                    spi_master_transfer(&spi_dev[current_device], (uint8_t *)&data, (uint8_t *)&read_val, 4);
                    r = byterev(read_val);
                }

                break;
            }

            case i[int x].transfer_array(NULLABLE_ARRAY_OF(const uint8_t, data_out), NULLABLE_ARRAY_OF(uint8_t, data_in), static const size_t num_bytes):{
                if(isnull(cb)){
                    for(int n = 0; n < num_bytes; n++){
                        uint8_t send;
                        if(!isnull(mosi)){
                            send = data_out[n];
                        }
                        uint8_t recv = transfer8_sync_zero_clkblk(sclk, mosi, miso, send, clkblkless_period_ticks, cpol, cpha);
                        if(!isnull(miso)){
                            data_in[n] = recv;
                        }
                    }
                } else {
                    // Remote references not allowed in XC so need to memcpy
                    uint8_t data[num_bytes];
                    if(!isnull(data_out)){
                        memcpy(data, data_out, num_bytes);
                    }
                    unsafe{
                        // Do in-place transfer
                        uint8_t * unsafe data_alias = data;
                        spi_master_transfer(&spi_dev[current_device], data, data_alias, num_bytes);
                    }
                    if(!isnull(data_in)){
                        memcpy(data_in, data, num_bytes);
                    }
                }

                break;
            }

            case i[int x].set_ss_port_bit(unsigned device_index, unsigned port_bit):{
                if(device_index > num_slaves){
                    printstrln("Invalid port bit - must be less than num_slaves");
                }
                ss_port_bit[device_index] = port_bit;

                break;
            }

            case i[int x].set_miso_capture_timing(unsigned device_index, spi_master_miso_capture_timing_t miso_capture_timing):{
                device_miso_capture_timing[x] = miso_capture_timing;
                break;
            }

            case i[int x].set_ss_clock_timing(unsigned device_index, spi_master_ss_clock_timing_t ss_clock_timing):{
                device_ss_clock_timing[x] = ss_clock_timing;
                break;
            }

            case i[int x].shutdown(void):{
                p_ss <: 0xffffffff;
                // If using XC, then we need to enable/init which is how XC does it
                if (!isnull(mosi)) {
                    set_port_use_on(mosi);
                }
                if (!isnull(miso)) {
                    set_port_use_on(miso);
                }
                set_port_use_on(sclk);
                if(!isnull(cb)){
                    set_clock_on(cb);
                }

                return;
            }
        }
    }

}
