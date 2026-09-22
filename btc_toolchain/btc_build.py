#!/usr/bin/env python3
"""
BTC Arma 3 Build Helper
Toggles debug defines in addon script_component.hpp files,
then runs HEMTT accordingly.

Usage:
    python btc_build.py --dev                        # toggle ALL addons
    python btc_build.py --dev --addon my_addon       # toggle only my_addon; comment out all others
    python btc_build.py --release                    # comment out ALL addons
    python btc_build.py --release --addon my_addon   # same as --release (all commented out)
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────

ADDONS_DIR = Path("./addons")           # relative to this script's location
HEMTT_CMD_DEV = ["../hemtt", "dev"]
HEMTT_CMD_RELEASE = ["../hemtt", "release"]

# Matches lines like:
#   // #define BTC_DEBUG_ANYTHING
#   //#define DISABLE_COMPILE_CACHE
#   #define BTC_DEBUG_ANYTHING
#   #define DISABLE_COMPILE_CACHE
DEFINE_PATTERN = re.compile(
    r"^(?P<comment>//\s*)?(?P<define>#define\s+(?:BTC_DEBUG_\w+|DISABLE_COMPILE_CACHE).*)$",
    re.MULTILINE,
)

# ── Helpers ───────────────────────────────────────────────────────────────────

def find_script_components(addons_dir: Path) -> list[Path]:
    """Return all script_component.hpp files under addons/*/."""
    files = list(addons_dir.glob("*/script_component.hpp"))
    if not files:
        print(f"[WARN] No script_component.hpp files found under '{addons_dir}'.")
    return files


def process_file(path: Path, dev_mode: bool) -> bool:
    """
    Comment out or uncomment the debug defines in *path*.
    Returns True if the file was modified.
    """
    original = path.read_text(encoding="utf-8")

    def replacer(m: re.Match) -> str:
        define = m.group("define")
        if dev_mode:
            # Uncomment  →  ensure no leading `// `
            return define
        else:
            # Comment out →  ensure leading `// `
            return f"// {define}"

    updated = DEFINE_PATTERN.sub(replacer, original)

    if updated == original:
        return False

    path.write_text(updated, encoding="utf-8")
    return True


def run_hemtt(cmd: list[str], cwd: Path) -> None:
    """Run HEMTT and stream its output live."""
    print(f"\n[RUN] {' '.join(cmd)}  (cwd: {cwd})\n{'─' * 60}")
    result = subprocess.run(cmd, cwd=cwd)
    print("─" * 60)
    if result.returncode != 0:
        print(f"[ERROR] HEMTT exited with code {result.returncode}.")
        sys.exit(result.returncode)
    print("[OK] HEMTT finished successfully.")



# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Toggle BTC debug defines and run HEMTT."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--dev",     action="store_true", help="Uncomment debug defines and run 'hemtt dev'")
    group.add_argument("--release", action="store_true", help="Comment out debug defines and run 'hemtt release'")
    parser.add_argument(
        "--addon",
        metavar="ADDON_NAME",
        default=None,
        help=(
            "Only uncomment defines for this addon folder name. "
            "All other addons will have their defines commented out. "
            "Has no extra effect with --release (everything is commented out anyway)."
        ),
    )
    args = parser.parse_args()

    dev_mode   = args.dev
    target     = args.addon   # None  →  apply to all
    mode_label = "DEV" if dev_mode else "RELEASE"
    suffix     = f"  |  Target addon: {target}" if target else "  |  All addons"
    print(f"[BTC Build] Mode: {mode_label}{suffix}")

    # Resolve paths relative to this script's location
    script_dir   = Path(__file__).parent      # btc_toolchain/
    project_root = script_dir          # btc/  ← hemtt lives here
    addons_dir   = script_dir / ADDONS_DIR    # btc_toolchain/addons/

    if not addons_dir.is_dir():
        print(f"[ERROR] Addons directory not found: {addons_dir.resolve()}")
        sys.exit(1)

    files = find_script_components(addons_dir)
    if not files:
        sys.exit(1)

    # Validate --addon value if provided
    if target is not None:
        known_addons = {f.parent.name for f in files}
        if target not in known_addons:
            print(f"[ERROR] Addon '{target}' not found. Available addons:")
            for name in sorted(known_addons):
                print(f"    {name}")
            sys.exit(1)

    print(f"\n[INFO] Found {len(files)} script_component.hpp file(s).")

    modified = 0
    for f in sorted(files):
        addon_name = f.parent.name
        # When --addon is given: only that addon gets dev_mode=True; others are always commented out.
        # When --addon is omitted: dev_mode applies uniformly.
        effective_dev = dev_mode and (target is None or addon_name == target)
        changed = process_file(f, effective_dev)
        status = "modified" if changed else "unchanged"
        flag   = "DEBUG ON " if effective_dev else "DEBUG OFF"
        print(f"  {'*' if changed else ' '} {addon_name:30s} [{status}]  ({flag})")
        if changed:
            modified += 1

    print(f"\n[INFO] {modified}/{len(files)} file(s) updated.")

    hemtt_cmd = HEMTT_CMD_DEV if dev_mode else HEMTT_CMD_RELEASE
    run_hemtt(hemtt_cmd, cwd=project_root)


if __name__ == "__main__":
    main()
