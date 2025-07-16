# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.

from pathlib import Path
import Pyxsim
import pytest
from spi_master_checker import SPIMasterChecker
from helpers import generate_tests_from_json, write_csv_row, create_if_needed, sort_csv_table

appname = "spi_master_sync_benchmark"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"
test_results_file = Path.cwd()/f"logs/{appname}.txt"

# This logs to a csv file since we don't want to do checking - it's just benchmark results
class Resultlogger(Pyxsim.testers.ComparisonTester):
    def __init__(self, id):
        # Turn ID back into a dict
        self.result = dict(item.split('=') for item in id.split(', '))

    def run(self, output):
        ignore_list = ["SPI Master checker"]
        result_8b = None
        result_32b = None
        for line in output: print(line)
        for line in reversed(output):
            if any(skip in line for skip in ignore_list):
                continue
            if "PASS" in line:
                width, speed = line.split(':')[1:3]
                if int(width) == 8 and result_8b is None:
                    result_8b = speed
                    continue
                if int(width) == 32 and result_32b is None:
                    result_32b = speed
        self.result["result_8b"] = result_8b
        self.result["result_32b"] = result_32b
        assert result_8b and result_32b, "No timing results found"

        print(self.result)
        write_csv_row(test_results_file, self.result)
        
@pytest.fixture(scope="module", autouse=True)
def remove_test_results():
    create_if_needed(test_results_file.parent)
    if test_results_file.exists():
        test_results_file.unlink()
    yield
    # Post test cleanup
    sort_csv_table(test_results_file)

def do_benchmark_sync(capfd, burnt, spi_mode, miso_mosi_enabled, arch, id):
    id_string = f"{burnt}_{spi_mode}_{miso_mosi_enabled}_{arch}"
    filepath = Path(__file__).resolve().parent
    binary = filepath/f"{appname}/bin/{id_string}/{appname}_{id_string}.xe"
    assert binary.exists(), f"Binary file {binary} not present - please pre-build"

    checker = SPIMasterChecker("tile[0]:XS1_PORT_1C",
                               "tile[0]:XS1_PORT_1D",
                               "tile[0]:XS1_PORT_1A",
                               ["tile[0]:XS1_PORT_1B"],
                               "tile[0]:XS1_PORT_1E",
                               "tile[0]:XS1_PORT_16B")

    tester = Resultlogger(id)

    Pyxsim.run_on_simulator_(
        binary,
        tester = tester,
        do_xe_prebuild = False,
        simthreads = [checker],
        simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -clock-blocks -ports -ports-detailed -pads -functions'],
        capfd=capfd)


@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_master_sync_benchmark(capfd, params, request):
    do_benchmark_sync(capfd, *params, request.node.callspec.id)