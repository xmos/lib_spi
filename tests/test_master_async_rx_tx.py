# Copyright 2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker
from helpers import generate_tests_from_json, create_if_needed
from itertools import zip_longest

appname = "spi_master_async_rx_tx"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"

def do_test(capfd, combined, burnt, mosi_enabled, transfer_width, speed_tests, spi_mode, arch, id):

    id_string = f"{combined}_{burnt}_{mosi_enabled}_{speed_tests}_{transfer_width}_{spi_mode}_{arch}"
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{id_string}/{appname}_{id_string}.xe"
    assert binary.exists()

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    with open(filepath/f"expected/master_sync.expect") as exp:
        expected = exp.read().splitlines()

    tester = Pyxsim.testers.ComparisonTester(expected,
                                            regexp = False,
                                            ordered = True)
    
    Pyxsim.run_on_simulator_(
        binary,
        simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -ports -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd)

    out, err = capfd.readouterr()
    output = out.split('\n')[:-1]

    with capfd.disabled():
        print()
        print(f"{'Expected':<40}Actual")
        for e, o in zip_longest(expected, output, fillvalue = ''):
            print(f"{str(e):<40}{str(o)}")

    assert tester.run(output)


@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_master_async_rx_tx(capfd, params, request):
    # print("***", params)
    do_test(capfd, *params, request.node.callspec.id)
