// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <spi.h>
#include <syscall.h>
#include <timer.h>
#include <print.h>
#include <platform.h>

out buffered port:32   p_sclk         = WIFI_CLK;
out port               p_ss           = WIFI_CS_N;
in buffered port:32    p_miso         = WIFI_MISO;
out buffered port:32   p_mosi         = WIFI_MOSI;
out port               p_rstn         = WIFI_WUP_RST_N;

clock clk                             = on tile[0]: XS1_CLKBLK_1;

#define RESET_DEASSERT                0x02
#define POST_RESET_DELAY_MICROSECONDS 1000
#define SPI_SPEED_KBPS                1000

/* This application function sends some traffic as SPI master using
 * the synchronous interface. It reads the config register (address 0)
 * of the WFM200S using a 16b command and prints the 32b read result */ 
void app(client spi_master_if spi)
{
    uint8_t val;
    printstrln("Sending SPI traffic");
    
    p_rstn <: RESET_DEASSERT; //Take out of reset and wait
    delay_microseconds(POST_RESET_DELAY_MICROSECONDS);

    spi.set_ss_port_bit(0, 1); // We are using bit 1 in WIFI_CS_N for device 0

    spi.begin_transaction(0, SPI_SPEED_KBPS, SPI_MODE_0);

    uint32_t reg_addr = 0; // Read reg 0 CONFIG register
    uint32_t read_cmd = 0x8000;
    uint32_t num_16b_words = 2;
    uint32_t reg_addr_shift = 12;
    uint32_t command = read_cmd | num_16b_words | (reg_addr << reg_addr_shift); //Do read command

    val = spi.transfer8(command >> 8);// MSB first
    val = spi.transfer8(command & 0xff);
    
    uint32_t reg;
    reg = spi.transfer32(0x00); //Read result
    spi.end_transaction(0);

    printhexln(reg >> 16);  // Should be 0x5400
    printstrln("Done.");
    spi.shutdown();
}

/* This application function sends some traffic as SPI master using
 * the synchronous interface. It reads the config register (address 0)
 * of the WFM200S using a 16b command and prints the 32b read result */
void async_app(client spi_master_async_if spi)
{

  printstrln("Sending aynch SPI traffic");
  
  p_rstn <: RESET_DEASSERT; //Take out of reset and wait
  delay_microseconds(POST_RESET_DELAY_MICROSECONDS);
  spi.set_ss_port_bit(0, 1); // We are using bit 1 in WIFI_CS_N for device 0

  spi.begin_transaction(0, SPI_SPEED_KBPS, SPI_MODE_0);

  // Build command
  uint32_t reg_addr = 0; // Read reg 0 CONFIG register
  uint32_t read_cmd = 0x8000;
  uint32_t num_16b_words = 2;
  uint32_t reg_addr_shift = 12;
  uint32_t command = read_cmd | num_16b_words | (reg_addr << reg_addr_shift); //Do read command

  uint8_t outbuffer[2];
  outbuffer[0] = (command >> 8) & 0xff; // MSB first
  outbuffer[1] = command & 0xff;

  uint8_t * movable inbuf = NULL; // We do not care about the read data for the cmd write
  uint8_t * movable outbuf = outbuffer;


  // This call passes the buffers over to the SPI task, after
  // this the application cannot access the buffers until
  // the retrieve_transfer_buffers_8 function is called.

  spi.init_transfer_array_8(move(inbuf),
                            move(outbuf),
                            2);

  // A select will wait for an event. In this case the event we are waiting
  // for is the transfer_complete() notification event from the SPI task.
  select {
      case spi.transfer_complete():
         // Once the transfer is complete, we can retrieve the
         // buffers back into the inbuf and outbuf pointer variables
         spi.retrieve_transfer_buffers_8(inbuf, outbuf);
         break;
  }

  spi.begin_transaction(0, SPI_SPEED_KBPS, SPI_MODE_0);

  uint32_t inbuffer32[1] = {0}; 
  uint32_t * movable inbuf32 = inbuffer32;
  uint32_t * movable outbuf32 = NULL; // We do not care what is written during reg reads

  spi.init_transfer_array_32(move(inbuf32),
                            null,
                            1);

  select {
      case spi.transfer_complete():
         // Once the transfer is complete, we can retrieve the
         // buffers back into the inbuf and outbuf pointer variables
         spi.retrieve_transfer_buffers_32(inbuf32,
                                          outbuf32);
         break;
  }

  printhexln(*inbuf32 >> 16); // Should be 0x5400
  printstrln("Done.");

  spi.shutdown();
}


#if SPI_USE_ASYNC

int main(void) {
  interface spi_master_async_if i_spi_async[1];
  par {
    on tile[0]: {
      par {
        async_app(i_spi_async[0]);
        spi_master_async(i_spi_async, 1, p_sclk, p_mosi, p_miso, p_ss, 1, clk);
      }
    }
  }
  return 0;
}

#else // SYNC
#ifndef CLKBLK
#define CLKBLK clk
#endif

int main(void) {
  interface spi_master_if i_spi[1];
  par {
    on tile[0]: app(i_spi[0]);
    on tile[0]: spi_master(i_spi, 1, p_sclk, p_mosi, p_miso, p_ss, 1, CLKBLK);
  }
  return 0;
}

#endif /*SPI_USE_ASYNC*/
