"""Run Tiny Tapeout's test for this project (../test/test.py) from the
course's `make cocotb` and `make check-cocotb`, so CI checks it too.

The test itself stays in test/, where the Tiny Tapeout template expects it.
"""
import importlib.util
import os

_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "test", "test.py")
_spec = importlib.util.spec_from_file_location("tt_fir_tt_test", _path)
_tt = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_tt)

test_project = _tt.test_project
