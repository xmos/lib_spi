#!/usr/bin/env python
import xmostest
from spi_master_checker import SPIMasterChecker
import os


def do_rx_tx_async(burnt_threads, mosi_enable, speed_tests, combine):
    resources = xmostest.request_resource("xsim")

    xmostest.build('spi_master_async_rx_tx', build_config="{burnt}{mosi}{speed}{combined}".format(burnt=burnt_threads, mosi=mosi_enable, combined=combine, speed=speed_tests))

    binary = "spi_master_async_rx_tx/bin/{burnt}{mosi}{speed}{combined}/spi_master_async_rx_tx_{burnt}{mosi}{speed}{combined}.xe".format(burnt=burnt_threads,mosi=mosi_enable, combined=combine, speed=speed_tests)


    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master.expect'),
                                     'lib_spi', 
                                     'spi_master_sim_tests',
                                     'spi_master_async_rx_tx_{burnt}{mosi}{speed}{combined}'.format(burnt=burnt_threads,mosi=mosi_enable, combined=combine, speed=speed_tests), 
                                     regexp=True)

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              #simargs=['--vcd-tracing', '-o ./spi_master_async_rx_tx/trace.vcd -tile tile[0] -pads -functions -ports -instructions','--gprof'],
                              simargs=[],
                              suppress_multidrive_messages = False,
                              tester = tester)

def runtest():
    for burnt_threads in [2, 6]:
      for combined in [0, 1]:
        for mosi_enabled in [0, 1]:
          do_rx_tx_async(burnt_threads + combined, mosi_enabled, 1, combined)
