#!/usr/bin/env python
# Copyright 2015-2021 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
import xmostest
from spi_master_checker import SPIMasterChecker
import os


def do_shutdown_async(combine, testlevel):
    resources = xmostest.request_resource("xsim")

    binary = "spi_master_async_shutdown/bin/{combined}/spi_master_async_shutdown_{combined}.xe".format(combined=combine)


    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master.expect'),
                                     'lib_spi',
                                     'spi_master_sim_tests',
                                     'spi_master_async_shutdown_{combined}'.format(combined=combine),
                                     regexp=True)

    tester.set_min_testlevel(testlevel)
    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=[],
                              timeout=1200,
                              tester = tester)

def runtest():
    # do_shutdown_async(1, "smoke")

    # for combined in [0, 1]:
    #     do_shutdown_async(combined, "nightly")
    pass