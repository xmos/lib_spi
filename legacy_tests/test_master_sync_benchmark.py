#!/usr/bin/env python
# Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
import xmostest
from spi_master_checker import SPIMasterChecker
import os

def do_benchmark_sync(full_load, cb_enabled, miso_enabled, mosi_enable):
    resources = xmostest.request_resource("xsim")

    binary = "spi_master_sync_benchmark/bin/{load}{cb}{miso}{mosi}/spi_master_sync_benchmark_{load}{cb}{miso}{mosi}.xe".format(load=full_load,cb=cb_enabled,miso=miso_enabled,mosi=mosi_enable)

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master_benchmark.expect'),
                                     'lib_spi',
                                     'spi_master_sim_tests',
                                     'spi_master_sync_benchmark_{load}{cb}{miso}{mosi}'.format(load=full_load,cb=cb_enabled,miso=miso_enabled,mosi=mosi_enable),
                                     regexp=True)

    if full_load == 0:
        tester.set_min_testlevel('nightly')

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=[],
                              suppress_multidrive_messages = False,
                              tester = tester)

def runtest():
    for full_load in [0, 1]:
        for cb_enabled in [0, 1]:
            for miso_enabled in [0, 1]:
                for mosi_enabled in [0, 1]:
                    do_benchmark_sync(full_load, cb_enabled, miso_enabled, mosi_enabled)
