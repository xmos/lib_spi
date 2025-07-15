# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker
from helpers import generate_tests_from_json, create_if_needed


appname = "spi_master_sync_multi_device"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"

def do_test(capfd, burnt, cb_enabled, miso_mosi_enabled, arch, id):
    id_string = f"{burnt}_{cb_enabled}_{miso_mosi_enabled}_{arch}"
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{id_string}/{appname}_{id_string}.xe"
    assert binary.exists()

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B", "tile[0]:XS1_PORT_1G"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    with open(filepath/f"expected/master_sync.expect") as exp:
        expected = exp.read().splitlines()

    tester = Pyxsim.testers.ComparisonTester(expected,
                                            regexp = False,
                                            ordered = True)
    
    Pyxsim.run_on_simulator_(
        binary,
        #simargs=['--vcd-tracing', '-o ./spi_master_sync_multi_device/trace.vcd -tile tile[0] -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd)

    out, err = capfd.readouterr()
    output = out.split('\n')[:-1]

    with capfd.disabled():
        print(f"expected: {expected}")
        print(f"Actual output: {output}")

    assert tester.run(output)


@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_master_sync_rx_tx(capfd, params, request):
    do_test(capfd, *params, request.node.callspec.id)
