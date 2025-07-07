# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_slave_checker import SPISlaveChecker
from helpers import generate_tests_from_json, create_if_needed

appname = "spi_slave_rx_tx"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"

def do_slave_rx_tx(capfd, combined, burnt, miso_enabled, spi_mode, transfer_size, arch, id):
    id_string = f"{combined}_{burnt}_{miso_enabled}_{spi_mode}_{transfer_size}_{arch}"
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{id_string}/{appname}_{id_string}.xe"
    assert binary.exists()

    checker = SPISlaveChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               "tile[0]:XS1_PORT_1B",
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B",
                               "tile[0]:XS1_PORT_1F")

    with open(filepath/f"expected/slave.expect") as exp:
        expected = exp.read().splitlines()
        expected = expected[:3 + transfer_size] + expected[-1:]

    tester = Pyxsim.testers.ComparisonTester(expected,
                                            regexp = True,
                                            ordered = True)

    Pyxsim.run_on_simulator_(
        binary,
        # simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -ports -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd
        )

    out, err = capfd.readouterr()
    output = out.split('\n')[:-1]

    with capfd.disabled():
        print(f"expected: {expected}")
        print(f"Actual output: {out}")

    assert tester.run(output)

@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_slave_rx_tx(capfd, params, request):
    do_slave_rx_tx(capfd, *params, request.node.callspec.id)
