# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker


appname = "spi_master_sync_clock_port_sharing"

def do_test(capfd, combined, id):
    id_string = f"{combined}"
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


@pytest.mark.parametrize("combined", ["COMBINED", "NOT_COMBINED"], ids=["COMBINED=1", "COMBINED=0"])
def test_master_sync_clock_port_sharing(capfd, combined, request):
    do_test(capfd, combined, request.node.callspec.id)
