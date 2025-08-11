# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker
import os
from helpers import generate_tests_from_json, create_if_needed, print_expected_vs_output


appname = "spi_master_async_multi_client"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"

def do_test(capfd, combined, burnt, mosi_enabled, arch, id):
    id_string = f"{combined}_{burnt}_{mosi_enabled}_{arch}"
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{id_string}/{appname}_{id_string}.xe"
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
    
    simargs = "--plugin LoopbackPort.dll '-port tile[0] XS1_PORT_1A 1 0 -port tile[0] XS1_PORT_1D 1 0'".split()
    # simargs += "--vcd-tracing '-o trace.vcd -tile tile[0] -pads -ports -functions'".split()

    Pyxsim.run_on_simulator_(
        binary,
        simargs=simargs,
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd,
        timeout=60) # In case of lock-up

    output = print_expected_vs_output(expected, capfd)
    assert tester.run(output), output


@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_master_async_multi_client(capfd, params, request):
    do_test(capfd, *params, request.node.callspec.id)

