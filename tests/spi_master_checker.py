# Copyright 2015-2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
import Pyxsim as px
from functools import partial

# We need to disable output buffering for this test to work on MacOS; this has
# no effect on Linux systems. Let's redefine print once to avoid putting the 
# same argument everywhere.
print = partial(print, flush=True)

class SPIMasterChecker(px.SimThread):
    """"
    This simulator thread will act as SPI slave and check any transactions
    caused by the master.
    """
    def __init__(self, 
                 sck_port: str, 
                 mosi_port: str, 
                 miso_port: str, 
                 ss_port: str, 
                 setup_strobe_port: str, 
                 setup_data_port: str) -> None:
        self._miso_port = miso_port
        self._mosi_port = mosi_port
        self._sck_port = sck_port
        self._ss_port = ss_port
        self._ss_port_width = px.pyxsim.xsi_get_port_width(ss_port.split(':')[1] if ":" in ss_port else ss_port) # May need to trim on tile[x]:
        self._setup_strobe_port = setup_strobe_port
        self._setup_data_port = setup_data_port

    def get_setup_data(self, 
                       xsi: px.pyxsim.Xsi, 
                       setup_strobe_port: str, 
                       setup_data_port: str) -> int:
        self.wait_for_port_pins_change([setup_strobe_port])
        self.wait_for_port_pins_change([setup_strobe_port])
        return xsi.sample_port_pins(setup_data_port)

    def run(self) -> None:
        xsi: px.pyxsim.Xsi = self.xsi

        print("SPI Master checker started")

        # some timing constants
        xsi_tick_freq_hz = float(1e15) # pending merge of https://github.com/xmos/test_support/blob/develop/lib/python/Pyxsim/pyxsim.py#L246-L265
        millisecond_ticks = xsi_tick_freq_hz / 1e3
        microsecond_ticks = xsi_tick_freq_hz / 1e6
        nanosecond_ticks = xsi_tick_freq_hz / 1e9

        sck_value = xsi.sample_port_pins(self._sck_port)
        ss_value = xsi.sample_port_pins(self._ss_port)
        ss_deaserted_value = (0xffffffff >> (32 - self._ss_port_width))

        while True:
            #first do the setup rx from DUT
            strobe_val = xsi.sample_port_pins(self._setup_strobe_port)
            if strobe_val == 1:
                self.wait_for_port_pins_change([self._setup_strobe_port])

            expected_cpol = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_cpha = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_frequency_in_khz = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_mosi_enabled = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_miso_enabled = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_device_id = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_interframe_space = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            expected_num_bytes = self.get_setup_data(xsi, self._setup_strobe_port, self._setup_data_port)
            # print(f"Got Settings cpol:{expected_cpol} cpha:{expected_cpha} mosi:{expected_miso_enabled} miso:{expected_miso_enabled} expected_frequency_in_khz:{expected_frequency_in_khz} expected_device_id:{expected_device_id} expected_interframe_space:{expected_interframe_space} expected_num_bytes:{expected_num_bytes}")

            clock_half_period = millisecond_ticks / (expected_frequency_in_khz*2)

            all_ss_deserted = True
            if (xsi.sample_port_pins(self._ss_port) != ss_deaserted_value):
                all_ss_deserted = False

            # Wait until all SS go high
            while not all_ss_deserted:
                self.wait_for_port_pins_change([self._ss_port])
                all_ss_deserted = True if xsi.sample_port_pins(self._ss_port) == ss_deaserted_value else False
            # print("ALL HIGH", ss_deaserted_value)

            error = False

            # Wait for any SS to assert
            active_slave = -1 # no active slaves
            while(active_slave == -1):
                self.wait_for_port_pins_change([self._ss_port])
                ss_port_val = xsi.sample_port_pins(self._ss_port)
                for i in range(self._ss_port_width):
                    if ((ss_port_val >> i) & 1) == 0:
                        assert active_slave == -1, f"more than one SS asserted, SS port val: 0x{ss_port_val:x}"
                        active_slave = i
                        # print(f"active_slave: {active_slave}")
                        
            last_clock_event_time = xsi.get_time()

            rx_bit_counter = 0
            tx_bit_counter = 0
            tx_data = [0xfe, 0xf7, 0xfb, 0xef, 0xdf, 0xbf, 0xfd, 0x7f, 0x01, 0x08, 0x04, 0x10, 0x20, 0x04, 0x02, 0x80]
            rx_data = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x04, 0x80, 0xfe, 0xfd, 0xfb, 0xf7, 0xef, 0xdf, 0xbf, 0x7f]
            rx_byte = 0
            tx_byte = tx_data[0]
            # check the polarity

            sampled_cpol = xsi.sample_port_pins(self._sck_port)
            if sampled_cpol != expected_cpol:
                print(f"ERROR: unexpected clock polarity {sampled_cpol} (expected {expected_cpol}) at the slave select point, time: {xsi.get_time() / nanosecond_ticks}ns")
                error = True
            clock_edge_number = 0

            #probably not physically possible but good for testing
            if expected_cpha == 0:
                xsi.drive_port_pins(self._miso_port, (tx_byte>>7)&1)
                tx_bit_counter += 1
                tx_byte = tx_byte << 1

            ss_value = ((xsi.sample_port_pins(self._ss_port) >> active_slave) & 1) # Select of interest
            sck_value = xsi.sample_port_pins(self._sck_port)

            while ss_value == 0:
                self.wait_for_port_pins_change([self._ss_port] + [self._sck_port])
                
                # check no other SS asserted
                ss_port_val = xsi.sample_port_pins(self._ss_port) & ss_deaserted_value
                # print(f"{self._ss_port}, 0x{ss_port_val:x}, 0x{ss_deaserted_value:x}, {active_slave}, {(ss_deaserted_value & ~(1 << active_slave)):x}")
                for i in range(self._ss_port_width):
                    if (ss_port_val & (1 << i) == 0) and (i != active_slave):
                        error = True
                        print(f"Error: Additional slave selected during first transaction, SS port val:0x{ss_port_val:x} (active slave:{active_slave} mask 0x{ss_deaserted_value:x}) at time: {xsi.get_time() / nanosecond_ticks}ns")

                if (ss_value == ((xsi.sample_port_pins(self._ss_port) >> active_slave) & 1) and (sck_value == xsi.sample_port_pins(self._sck_port))):
                    continue

                ss_value = ((xsi.sample_port_pins(self._ss_port) >> active_slave) & 1)
                sck_value = xsi.sample_port_pins(self._sck_port)

                if ss_value == 0:
                    clock_event_time = xsi.get_time()
                    measured_time_elapsed = clock_event_time - last_clock_event_time
                    if clock_edge_number > 1 and (measured_time_elapsed*1.05) < clock_half_period :
                        print(f"ERROR: Clock half period less than allowed for given SCLK frequency, measured_time_elapsed: {measured_time_elapsed/nanosecond_ticks:.2f}ns clock_half_period:{clock_half_period/nanosecond_ticks}ns, at time: {xsi.get_time() / nanosecond_ticks}ns")
                        error = True
                    last_clock_event_time = clock_event_time

                #check that the clock edges never go faster than the expected clock rate
                if ss_value == 0:
                    clock_edge_number += 1
                    # print(f"MISO clock_edge_number: {clock_edge_number}")
                    #the the clock must have transitioned
                    if sck_value == (expected_cpha ^ expected_cpol):
                        if expected_miso_enabled == 1:
                            #drive data out
                            xsi.drive_port_pins(self._miso_port, (tx_byte>>7)&1)
                            tx_bit_counter += 1
                            tx_byte = tx_byte << 1
                            if (tx_bit_counter%8) == 0:
                                index = tx_bit_counter//8
                                if index < 16:
                                    tx_byte = tx_data[index]
                                else:
                                    tx_byte = 0
                    else:
                        #clock data in
                        if expected_mosi_enabled == 1:
                            rx_byte = rx_byte << 1
                            rx_byte += xsi.sample_port_pins(self._mosi_port)
                            rx_bit_counter = rx_bit_counter + 1
                            if((rx_bit_counter%8) == 0):
                                expected_rx_byte = rx_data[(rx_bit_counter//8) - 1]
                                #print "slave got {seen} and expected {expect}".format(seen=rx_byte, expect=expected_rx_byte)
                                if expected_rx_byte != rx_byte:
                                    print(f"ERROR: slave received incorrect data Got:{rx_byte:02x} Expected:{expected_rx_byte:02x} at time: {xsi.get_time() / nanosecond_ticks}ns")
                                    error = True
                                # print(f"Checker correctly got byte: {rx_byte:02x} at time {xsi.get_time() / nanosecond_ticks}ns")
                                rx_byte = 0
                else:
                    if clock_edge_number != expected_num_bytes*2*8:
                        error = True
                        print(f"ERROR: incorrect number of clock edges at slave {clock_edge_number}/{expected_num_bytes*2*8} at time: {xsi.get_time() / nanosecond_ticks}ns")
                    if error:
                        print(f"Fail: CPOL:{expected_cpol} CPHA:{expected_cpha} KHz:{expected_frequency_in_khz} MOSI Enabled:{expected_mosi_enabled} MISO Enabled:{expected_miso_enabled}")
