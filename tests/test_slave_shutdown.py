# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_slave_checker import SPISlaveChecker
from helpers import generate_tests_from_json, create_if_needed, print_expected_vs_output

appname = "spi_slave_shutdown"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"

def do_test(combined, arch, capfd):
    filepath = Path(__file__).resolve().parent
    id_string = f"{combined}_{arch}"
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
        transfer_size = 8
        NUM_LOOPS = 3 # See spi_slave_shutdown.xc for equivalent define. Must match
        expected = expected[:3 + transfer_size] + expected[-1:]
        expected = expected + expected[1:] * (NUM_LOOPS - 1) # We don't want SPI Slave checker started after the first time

    tester = Pyxsim.testers.ComparisonTester(expected,
                                            regexp = True,
                                            ordered = True)
    
    Pyxsim.run_on_simulator_(
        binary,
        # simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -ports -ports-detailed -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd,
        timeout=60)

    output = print_expected_vs_output(expected, capfd)
    assert tester.run(output), output


@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_slave_shutdown(capfd, params, request):
    do_test(*params, capfd)