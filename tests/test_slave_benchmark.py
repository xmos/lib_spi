# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from pathlib import Path
import Pyxsim
import pytest
from spi_slave_checker import SPISlaveChecker
from helpers import generate_tests_from_json, write_csv_row, create_if_needed, sort_csv_table

appname = "spi_slave_benchmark"
test_params_file = Path(__file__).parent / f"{appname}/test_params.json"
test_results_file = Path.cwd()/f"logs/{appname}.txt"

# This logs to a csv file since we don't want to do checking - it's just benchmark results
class Resultlogger(Pyxsim.testers.ComparisonTester):
    def __init__(self, id):
        # Turn ID back into a dict
        self.result = dict(item.split('=') for item in id.split(', '))


    def run(self, output):
        # DUT outputs RESULT: SPI_MODE, TRANSFER_SIZE, BURNT_THREADS, miso_enabled, mosi_enabled, cd, kbps

        for line in output:
            print(line)
        ignore_list = ["SPI Slave checker", "Drive bit"]
        result_clock_delay_ns = None
        result_kbps = None
        for line in output:
            if any(skip in line for skip in ignore_list):
                continue
            if "RESULT:" in line:
                result_kbps = line.split(' ')[-1]
                result_clock_delay_ns = line.split(' ')[-2]
                self.result["CLK_DLY_NS"] = result_clock_delay_ns
                self.result["KBPS"] = result_kbps
        
        assert result_clock_delay_ns and result_kbps, "No timing results found"

        write_csv_row(test_results_file, self.result)
        
@pytest.fixture(scope="module", autouse=True)
def remove_test_results():
    create_if_needed(test_results_file.parent)
    if test_results_file.exists():
        test_results_file.unlink()
    yield
    # Post test cleanup
    sort_csv_table(test_results_file)

def do_benchmark_slave(capfd, combined, burnt, miso_enabled, spi_mode, transfer_size, arch, id):
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

    tester = Resultlogger(id)

    Pyxsim.run_on_simulator_(
        binary,
        tester = tester,
        # simargs=['--vcd-tracing', '-o ./trace.vcd -tile tile[0] -ports -pads -functions'],
        do_xe_prebuild = False,
        simthreads = [checker],
        capfd=capfd
        )

@pytest.mark.parametrize("params", generate_tests_from_json(test_params_file)[0], ids=generate_tests_from_json(test_params_file)[1])
def test_slave_benchmark(capfd, params, request):
    do_benchmark_slave(capfd, *params, request.node.callspec.id)

