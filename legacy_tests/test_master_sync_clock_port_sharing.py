#!/usr/bin/env python
# Copyright (c) 2015-2020, XMOS Ltd, All rights reserved
import xmostest
from spi_master_checker import SPIMasterChecker
import os

def do_clock_port_sharing(combine):
    resources = xmostest.request_resource("xsim")

    binary = "spi_master_sync_clock_port_sharing/bin/{combined}/spi_master_sync_clock_port_sharing_{combined}.xe".format(combined=combine)

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = xmostest.ComparisonTester(open('master.expect'),
                                     'lib_spi',
                                     'spi_master_sim_tests',
                                     'spi_master_sync_clock_port_sharing_{combined}'.format(combined=combine),
                                     regexp=True)

    if combine == 0:
        tester.set_min_testlevel('nightly')

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=[],
                              timeout=1200,
                              tester = tester)

def runtest():
    for combine in [0, 1]:
        do_clock_port_sharing(combine)
