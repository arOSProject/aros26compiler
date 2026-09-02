#!/usr/bin/env python3
"""Regenerate basic reference metadata without changing the written UX analysis."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

from PIL import Image


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    originals = root / "reference" / "original"
    records = []
    for path in sorted(originals.glob("IMG_*.jpg")):
        with Image.open(path) as image:
            records.append(
                {
                    "file": path.name,
                    "width": image.width,
                    "height": image.height,
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                }
            )
    output = root / "reference" / "inventory.json"
    output.write_text(json.dumps({"count": len(records), "images": records}, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

