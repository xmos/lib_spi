#!/usr/bin/env python
# Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
import xmostest
from spi_slave_checker import SPISlaveChecker
import os


def do_slave_rx_tx(full_load, miso_enable, mode):

    resources = xmostest.request_resource("xsim")

    binary = "spi_slave_rx_tx/bin/{load}_{miso}_{m}/spi_slave_rx_tx_{load}_{miso}_{m}.xe".format(load=full_load,miso=miso_enable,m=mode)

    checker = SPISlaveChecker("tile[0]:XS1_PORT_1C",
                              "tile[0]:XS1_PORT_1D",
                              "tile[0]:XS1_PORT_1A",
                              "tile[0]:XS1_PORT_1B",
                              "tile[0]:XS1_PORT_1E",
                              "tile[0]:XS1_PORT_16B",
                              "tile[0]:XS1_PORT_1F")

    tester = xmostest.ComparisonTester(open('slave.expect'),
                                     'lib_spi',
                                     'spi_slave_sim_tests',
                                     'rx_tx_slave_{load}_{miso}_{m}.xe'.format(load=full_load,miso=miso_enable,m=mode),
                                     {'full_load': full_load, 'miso_enable': miso_enable, 'mode': mode},
                                     regexp=True)

    if full_load == 0:
        tester.set_min_testlevel('nightly')

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              # simargs=['--vcd-tracing', '-o ./spi_slave_rx_tx/trace{load}_{miso}_{m}.vcd -tile tile[0] -pads -functions -clock-blocks -ports-detailed -instructions'.format(load=full_load,miso=miso_enable,m=mode)],
                              simargs=[],
                              suppress_multidrive_messages = False,
                              tester = tester)

def runtest():
    for full_load in [0, 1]:
        for miso_enable in [0, 1]:
            for mode in range(0, 4):
                do_slave_rx_tx(full_load, miso_enable, mode)
