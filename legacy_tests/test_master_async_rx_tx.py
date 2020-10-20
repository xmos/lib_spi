#!/usr/bin/env python
# Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
import xmostest
from spi_master_checker import SPIMasterChecker
import os

def do_rx_tx_async(full_load, mosi_enabled, speed_kbps, combined):
    resources = xmostest.request_resource("xsim")

    binary = "spi_master_async_rx_tx/bin/{load}{mosi}{speed}{combined}/spi_master_async_rx_tx_{load}{mosi}{speed}{combined}.xe".format(load=full_load,mosi=mosi_enabled, combined=combined, speed=speed_kbps)

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master.expect'),
                                     'lib_spi',
                                     'spi_master_sim_tests',
                                     'spi_master_async_rx_tx_{load}{mosi}{speed}{combined}'.format(load=full_load,mosi=mosi_enabled, combined=combined, speed=speed_kbps),
                                     regexp=True)

    if full_load == 0 | combined == 0:
        tester.set_min_testlevel('nightly')

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=[],
                              timeout=1200,
                              tester = tester)

def runtest():
    for full_load in [0, 1]:
        for combined in [0, 1]:
            for mosi_enabled in [0, 1]:
                if full_load == 0:
                    speeds = [100, 3000]
                else:
                    speeds = [100, 2000]
                for speed in speeds:
                        do_rx_tx_async(full_load, mosi_enabled, speed, combined)
