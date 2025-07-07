# Copyright 2025 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
import os
import random
import sys
import Pyxsim as px
import pytest
import json
import csv
import threading
import itertools
from filelock import FileLock

# Thread safe create a folder
def create_if_needed(folder):
    lock_path = f"{folder}.lock"
    # xdist can cause race conditions so use a lock
    with FileLock(lock_path):
        if not os.path.exists(folder):
            os.makedirs(folder)
        return folder

# Read a JSON and get the test configs and IDs. Pass the JSON files
def generate_tests_from_json(test_params_json):
    with open(test_params_json) as f:
        params = json.load(f)

        # Prepare keys and values
        keys = []
        values = []

        for key, val_or_dict_list in params.items():
            if isinstance(val_or_dict_list[0], dict):
                # Instead of keeping the key, we flatten the dicts inside the list
                combined_keys = list(val_or_dict_list[0].keys())  # "COMBINED", "BURNT_THREADS"
                # Save separate keys for later flattening
                keys.extend(combined_keys)
                # Convert list of dicts to list of tuples (flattened for combinations)
                values.append([tuple(d[k] for k in combined_keys) for d in val_or_dict_list])
            else:
                keys.append(key)
                values.append(val_or_dict_list)

        # Generate combinations
        combinations = itertools.product(*values)

        # Build final output
        test_config_ids = []
        test_configs = []
        for combo in combinations:
            test_config_id = {}

            key_idx = 0
            for val in combo:
                if isinstance(val, tuple):  # This only happens for THREAD_PROFILES
                    for subval in val:
                        key = keys[key_idx]
                        test_config_id[key] = subval
                        key_idx += 1
                else:
                    key = keys[key_idx]
                    test_config_id[key] = val
                    key_idx += 1

            test_config = list(test_config_id.values())
            test_config_id = ", ".join(f"{k}={v}" for k, v in test_config_id.items())
            # print(test_config, test_config_id)
            test_configs.append(test_config)
            test_config_ids.append(test_config_id)

    return test_configs, test_config_ids


# Create a global lock
csv_write_lock = threading.Lock()
def write_csv_row(filepath, row):
    """
    Thread-safe write to a CSV file.

    Args:
        filepath (str): Path to the CSV file.
        row (dict): A dictionary representing a single CSV row.
    """
    with csv_write_lock:
        file_exists = False
        try:
            with open(filepath, 'r', newline='') as f:
                file_exists = True
        except FileNotFoundError:
            pass

        with open(filepath, 'a', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=row.keys())
            if not file_exists:
                writer.writeheader()
            writer.writerow(row)

def sort_csv_table(file_path):
    with csv_write_lock:
        try:
            with open(file_path, newline='') as f:
                reader = csv.DictReader(f)
                rows = list(reader)
                fieldnames = reader.fieldnames

            # Sort rows by all columns lexicographically (as a tuple of values)
            rows.sort(key=lambda row: tuple(row[col] for col in fieldnames))

            with open(file_path, 'w', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(rows)

        except FileNotFoundError:
            assert 0, f"No CSV table {file_path} to sort"