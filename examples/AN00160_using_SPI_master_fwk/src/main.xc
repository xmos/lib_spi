// Copyright 2015-2025 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.
#include <xs1.h>
#include <spi.h>
#include <syscall.h>
#include <timer.h>
#include <print.h>
#include <platform.h>


out buffered port:32   p_sclk  = WIFI_CLK;
out port               p_ss    = WIFI_CS_N;
in buffered port:32    p_miso  = WIFI_MISO;
out buffered port:32   p_mosi  = WIFI_MOSI;
out port               p_rstn  = WIFI_WUP_RST_N;

clock clk0 = on tile[0]: XS1_CLKBLK_1;
clock clk1 = on tile[0]: XS1_CLKBLK_2;

/* This application function sends some traffic as SPI master using
 * the synchronous interface. It reads the config register (address 0)
 * of the WFM200S using a 16b command and prints the 32b read result */
void app(client spi_master_if spi)
{
    uint8_t val;
    printstrln("Sending SPI traffic");
    
    p_rstn <: 0x2; //Take out of reset and wait
    delay_microseconds(1000);
    spi.set_ss_port_bit(1); // We are using bit 1 in WIFI_CS_N

    spi.begin_transaction(0, 1000, SPI_MODE_0);
    uint32_t reg_addr = 0; // Read reg 0
    uint32_t read_cmd = 0x8000;
    uint32_t num_16b_words = 2;
    uint32_t command = read_cmd | num_16b_words | (reg_addr << 12); //Do read command
    val = spi.transfer8(command >> 8);
    val = spi.transfer8(command & 0xff);
    uint32_t reg = 0;
    reg = spi.transfer32(0x00);
    spi.end_transaction(0);
    printhexln(reg >> 16); // Should be 0x5400
    delay_microseconds(100000);

    printstrln("Done.");
    delay_microseconds(100000);
    _exit(0);
}


int main(void) {
  interface spi_master_if i_spi[1];
  par {
    on tile[0]: app(i_spi[0]);
    on tile[0]: spi_master_fwk(i_spi, 1,
                               p_sclk, p_mosi, p_miso, p_ss, 1,
                               clk0);
  }
  return 0;
}

