# Copyright 2020-2021 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
""" This script is used to reset one or more targets using xtagctl
"""
import traceback
import xtagctl
import sys

if __name__ == "__main__":
    if len(sys.argv) > 1:
        num_xtags = int(sys.argv[1])
    else:
        num_xtags = 1

    targets = ["XCORE-AI-EXPLORER"] * num_xtags
    print(f"XTAGCTL acquiring targets: {targets}")
    with xtagctl.acquire(*targets, timeout=10) as adapter_ids:
        if type(adapter_ids) is str:
            adapter_id_list = [adapter_ids]
        else:
            adapter_id_list = adapter_ids
        print(adapter_id_list)

        for adapter_id in adapter_id_list:
            print(f"acquiring adapter_id: {adapter_id}")
            try:
                xtagctl.reset_adapter(adapter_id)
                print("Successfully reset XTAG")
            except xtagctl.XtagctlException:
                print("WARNING: Could not reset xtag!")
                traceback.print_exc()
