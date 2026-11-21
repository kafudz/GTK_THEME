#!/usr/bin/env python3
"""Static sanity checks for MyTheme (no GTK installation required).

Usage: scripts/check.py [path/to/MyTheme]

Checks
  * GTK3/GTK4 CSS: balanced braces, terminated comments, every @colour used is
    defined, and the dark/light pair is structurally identical (only colour
    values may differ).
  * Active copies (gtk.css, gtk-2.0/gtkrc) match the committed dark variant.
  * GTK2 rc: balanced braces, every style is applied and every class line
    refers to an existing style.
  * settings.ini templates parse and contain a [Settings] section.
  * switch-mode.sh passes `bash -n`.
Exit status is non-zero if any check fails.
"""
import configparser
import re
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "MyTheme")
errors = []


def err(msg):
    errors.append(msg)
    print(f"FAIL {msg}")


def strip_comments(text, name):
    if text.count("/*") != text.count("*/"):
        err(f"{name}: unterminated comment")
    return re.sub(r"/\*.*?\*/", "", text, flags=re.S)


def colourless(text):
    return re.sub(r"#[0-9a-fA-F]{3,8}\b|rgba?\([^)]*\)", "COLOR", text)


for d in ("gtk-3.0", "gtk-4.0"):
    variants = {}
    for v in ("dark", "light"):
        path = root / d / f"gtk-{v}.css"
        name = f"{d}/gtk-{v}.css"
        raw = path.read_text()
        css = strip_comments(raw, name)
        if css.count("{") != css.count("}"):
            err(f"{name}: unbalanced braces")
        defined = set(re.findall(r"@define-color\s+(\w+)", css))
        used = set(re.findall(r"@(\w+)", re.sub(r"@define-color", "", css)))
        for missing in sorted(used - defined):
            err(f"{name}: @{missing} is used but never defined")
        for unused in sorted(defined - used):
            print(f"note {name}: @{unused} is defined but never used")
        variants[v] = raw
    # Comments (e.g. the "Dark/Light variant" header) are allowed to differ.
    if colourless(strip_comments(variants["dark"], d)) != colourless(strip_comments(variants["light"], d)):
        err(f"{d}: dark and light variants differ in more than colour values")
    if (root / d / "gtk.css").read_text() != variants["dark"]:
        err(f"{d}/gtk.css is not identical to gtk-dark.css (commit the dark variant as default)")

rc_dark = root / "gtk-2.0" / "gtkrc-dark"
rc_light = root / "gtk-2.0" / "gtkrc-light"
if (root / "gtk-2.0" / "gtkrc").read_text() != rc_dark.read_text():
    err("gtk-2.0/gtkrc is not identical to gtkrc-dark")
if colourless(rc_dark.read_text()).splitlines()[1:] != colourless(rc_light.read_text()).splitlines()[1:]:
    err("gtk-2.0: gtkrc-dark and gtkrc-light differ in more than colour values")
for rc in (rc_dark, rc_light):
    text = re.sub(r"#.*", "", rc.read_text())
    if text.count("{") != text.count("}"):
        err(f"gtk-2.0/{rc.name}: unbalanced braces")
    if text.count('"') % 2:
        err(f"gtk-2.0/{rc.name}: unbalanced quotes")
    styles = set(re.findall(r'^\s*style\s+"([^"]+)"', text, flags=re.M))
    applied = re.findall(r'^\s*class\s+"[^"]+"\s+style\s+"([^"]+)"', text, flags=re.M)
    for s in sorted(set(applied) - styles):
        err(f"gtk-2.0/{rc.name}: class line uses undefined style {s!r}")
    for s in sorted(styles - set(applied) - set(re.findall(r'style\s+"[^"]+"\s*=\s*"([^"]+)"', text))):
        err(f"gtk-2.0/{rc.name}: style {s!r} is never applied")

for ini in sorted((root / "user-config").glob("gtk-*/settings.ini")):
    cp = configparser.ConfigParser(interpolation=None)
    try:
        cp.read_string(ini.read_text())
    except configparser.Error as exc:
        err(f"{ini.relative_to(root)}: {exc}")
        continue
    if not cp.has_section("Settings"):
        err(f"{ini.relative_to(root)}: missing [Settings] section")

if subprocess.run(["bash", "-n", str(root / "switch-mode.sh")]).returncode:
    err("switch-mode.sh: bash -n failed")

print("FAILED" if errors else "all checks passed")
sys.exit(1 if errors else 0)
