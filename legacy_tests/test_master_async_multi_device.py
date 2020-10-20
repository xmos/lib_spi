#!/usr/bin/env python
# Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
import xmostest
from spi_master_checker import SPIMasterChecker
import os

def do_multi_device_async(full_load, mosi_enabled):
    resources = xmostest.request_resource("xsim")

    binary = "spi_master_async_multi_device/bin/{load}{mosi}/spi_master_async_multi_device_{load}{mosi}.xe".format(load=full_load,mosi=mosi_enabled)

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B", "tile[0]:XS1_PORT_1G"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master.expect'),
                                     'lib_spi',
                                     'spi_master_sim_tests',
                                     'spi_master_async_multi_device_{load}{mosi}'.format(load=full_load, mosi=mosi_enabled),
                                     regexp=True)

    if full_load == 0:
        tester.set_min_testlevel('nightly')

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              #simargs=['--vcd-tracing', '-o ./spi_master_async_multi_device/trace.vcd -tile tile[0] -pads -functions'],
                              simargs=[],
                              suppress_multidrive_messages = False,
                              tester = tester)

def runtest():
    for full_load in [0, 1]:
        for mosi_enabled in [0, 1]:
            do_multi_device_async(full_load, mosi_enabled)
