#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


def balanced_qml(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    stack: list[str] = []
    pairs = {"}": "{", "]": "[", ")": "("}
    opener = set(pairs.values())
    quote: str | None = None
    escaped = False
    line_comment = False
    block_comment = False
    index = 0
    while index < len(text):
        char = text[index]
        nxt = text[index + 1] if index + 1 < len(text) else ""
        if line_comment:
            if char == "\n":
                line_comment = False
            index += 1
            continue
        if block_comment:
            if char == "*" and nxt == "/":
                block_comment = False
                index += 2
            else:
                index += 1
            continue
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            index += 1
            continue
        if char == "/" and nxt == "/":
            line_comment = True
            index += 2
            continue
        if char == "/" and nxt == "*":
            block_comment = True
            index += 2
            continue
        if char in {'"', "'"}:
            quote = char
        elif char in opener:
            stack.append(char)
        elif char in pairs:
            assert stack and stack.pop() == pairs[char], f"unbalanced {char} in {path}"
        index += 1
    assert not stack and quote is None and not block_comment, f"unterminated construct in {path}"


def main() -> int:
    root = Path(sys.argv[1]).resolve()
    originals = sorted((root / "reference" / "original").glob("IMG_*.jpg"))
    assert len(originals) == 49, f"expected 49 reference images, found {len(originals)}"
    assert (root / "reference" / "Archive-original.zip").is_file()
    assert (root / "reference" / "REFERENCE_CATALOG.md").is_file()

    qml_files = sorted((root / "qml").rglob("*.qml"))
    assert len(qml_files) >= 15
    for qml in qml_files:
        balanced_qml(qml)
        text = qml.read_text(encoding="utf-8")
        assert "reference/original" not in text, f"reference screenshot embedded in UI: {qml}"
        assert not re.search(r"IMG_19\d\d\.jpg", text), f"screenshot used as interface: {qml}"

    required_apps = {"files", "settings", "terminal", "software", "updater", "about", "oobe", "lock"}
    for name in required_apps:
        assert (root / "scripts" / "launchers" / f"ar-{name}").is_file()
        if name != "lock":
            assert (root / "config" / "applications" / f"ar-{name}.desktop").is_file()

    bridge = (root / "src" / "systembridge.cpp").read_text(encoding="utf-8")
    for integration in ("nmcli", "bluetoothctl", "wpctl", "brightnessctl", "flatpak", "pkcon", "timedatectl"):
        source = bridge + (root / "src" / "systemhelper.cpp").read_text(encoding="utf-8")
        assert integration in source, f"missing real integration: {integration}"

    search = (root / "src" / "searchprovider.cpp").read_text(encoding="utf-8")
    for provider in ("applications", "settings", "files"):
        assert f'QStringLiteral("{provider}")' in search, f"missing search provider: {provider}"

    assert "initialPartitioningChoice: none" in (root / "config" / "calamares" / "modules" / "partition.conf").read_text()
    cleanup = (root / "config" / "calamares" / "modules" / "cleanup.conf").read_text()
    assert "99-ar-os-live-autologin.conf" in cleanup, "installed system must remove live autologin"
    assert "--distribution trixie" in (root / "iso" / "auto" / "config").read_text()
    print(f"validated {len(qml_files)} QML files, {len(originals)} references, native integrations, and ISO safety defaults")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
