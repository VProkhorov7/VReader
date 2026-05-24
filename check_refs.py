#!/usr/bin/env python3
"""
Compatibility wrapper for VReader validator.

Canonical validator:
    Description/check_refs.py
"""

from pathlib import Path
import runpy
import sys

ROOT = Path(__file__).resolve().parent
VALIDATOR = ROOT / "Description" / "check_refs.py"

if not VALIDATOR.exists():
    print(f"❌ Validator not found: {VALIDATOR}")
    sys.exit(1)

runpy.run_path(str(VALIDATOR), run_name="__main__")
