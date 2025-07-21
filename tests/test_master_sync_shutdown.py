# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker
from helpers import generate_tests_from_json, create_if_needed, print_expected_vs_output

appname = "spi_master_sync_shutdown"

def do_test(capfd):
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{appname}.xe"
    assert binary.exists()

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               "tile[0]:XS1_PORT_1B",
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    with open(filepath/f"expected/master_sync.expect") as exp:
        expected = exp.read().splitlines()

    tester = Pyxsim.testers.ComparisonTester(expected,
                                            regexp = False,
                                            ordered = True)
    
    Pyxsim.run_on_simulator_(
        binary,
        # simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -ports -ports-detailed -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd)

    output = print_expected_vs_output(expected, capfd)
    assert tester.run(output), output

def test_master_sync_rx_tx(capfd, request):
    do_test(capfd)