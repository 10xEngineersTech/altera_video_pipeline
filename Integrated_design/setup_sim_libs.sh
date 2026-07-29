#!/usr/bin/env bash
#
# setup_sim_libs.sh
# ------------------
# Builds a "stitched" simulation library directory (sim_libs/) that presents the
# classic Quartus  eda/sim_lib/{*, mentor/*}  layout that
# platform/pipeline/sim/mentor/msim_setup.tcl (dev_com) expects.
#
# Quartus 25.1.1 scatters these source files across questa_fse/...,
# quartus/libraries/vhdl/... and quartus/eda/sim_lib/common/ instead of a single
# flat eda/sim_lib/ dir -- only 2 of the ~24 files dev_com wants actually live
# there. This script locates each file by basename in the install tree and
# symlinks it into a flat dir, mirroring any subdirectory prefix (e.g. mentor/).
#
# The file list is NOT hardcoded -- it is parsed out of the generated
# msim_setup.tcl, so it follows the design automatically when the target device
# changes. (This script used to hardcode a Cyclone 10 GX list, which went
# silently stale when the platform moved to Agilex 5 / tennm atoms.)
#
# After running, point QUARTUS_SIM_LIB_DIR at the generated dir:
#   set QUARTUS_SIM_LIB_DIR .../Integrated_design/sim_libs
# app/runProject.py already does this.
#
# Usage: ./setup_sim_libs.sh [path/to/msim_setup.tcl]
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/sim_libs"

# Resolve the Quartus install root: an explicit QUARTUS_ROOT wins, else derive it
# from QUARTUS_ROOTDIR (which is <root>/quartus), else fall back to the local path.
if [ -n "${QUARTUS_ROOT:-}" ]; then
  :
elif [ -n "${QUARTUS_ROOTDIR:-}" ]; then
  QUARTUS_ROOT="$(dirname "$QUARTUS_ROOTDIR")"
else
  QUARTUS_ROOT="/home/lpt-10xe/altera_pro/25.1.1"
fi

if [ ! -d "$QUARTUS_ROOT" ]; then
  echo "ERROR: Quartus install root not found: $QUARTUS_ROOT" >&2
  echo "       Export QUARTUS_ROOT (or QUARTUS_ROOTDIR) and re-run." >&2
  exit 1
fi

MSIM_SETUP="${1:-$HERE/platform/pipeline/sim/mentor/msim_setup.tcl}"
if [ ! -f "$MSIM_SETUP" ]; then
  echo "ERROR: msim_setup.tcl not found: $MSIM_SETUP" >&2
  echo "       Generate the platform simulation model first." >&2
  exit 1
fi

# Every device-library file dev_com opens, as a path relative to
# $QUARTUS_SIM_LIB_DIR (entries may carry a subdir prefix, e.g. "mentor/").
mapfile -t NEED < <(
  grep -oE '\$QUARTUS_SIM_LIB_DIR/[A-Za-z0-9_./]+' "$MSIM_SETUP" \
    | sed 's|^\$QUARTUS_SIM_LIB_DIR/||' \
    | sort -u
)

if [ "${#NEED[@]}" -eq 0 ]; then
  echo "ERROR: parsed 0 device-library files out of $MSIM_SETUP" >&2
  exit 1
fi

# Prefer the canonical simulation-source trees over scattered example-project
# copies (e.g. ip/altera/.../example_project/common) which may be trimmed.
PREFERRED_ROOTS=(
  "$QUARTUS_ROOT/questa_fse/intel/verilog/src"
  "$QUARTUS_ROOT/questa_fse/intel/vhdl/src"
  "$QUARTUS_ROOT/quartus/libraries/vhdl"
  "$QUARTUS_ROOT/quartus/eda/sim_lib"
  "$QUARTUS_ROOT/quartus/eda/sim_lib/common"
  "$QUARTUS_ROOT/quartus/eda/fv_lib"
)

MISSING=()

link_one() {  # $1 = path relative to $OUT (may include a subdir prefix)
  local rel="$1" base dest hit="" root
  base="$(basename "$rel")"
  dest="$OUT/$(dirname "$rel")"
  mkdir -p "$dest"

  for root in "${PREFERRED_ROOTS[@]}"; do
    [ -d "$root" ] || continue
    hit="$(find "$root" -type f -name "$base" 2>/dev/null | head -1 || true)"
    [ -n "$hit" ] && break
  done
  # Fallback: anywhere in the install tree
  if [ -z "$hit" ]; then
    hit="$(find "$QUARTUS_ROOT" -type f -name "$base" 2>/dev/null | head -1 || true)"
  fi

  if [ -z "$hit" ]; then
    echo "  MISSING: $rel (no '$base' under $QUARTUS_ROOT)" >&2
    MISSING+=("$rel")
    return 0
  fi

  ln -sfn "$hit" "$OUT/$rel"
  printf '  linked : %-32s -> %s\n' "$rel" "${hit#"$QUARTUS_ROOT"/}"
}

echo "Quartus root : $QUARTUS_ROOT"
echo "msim_setup   : $MSIM_SETUP"
echo "Building     : $OUT  (${#NEED[@]} files)"
echo

rm -rf "$OUT"
mkdir -p "$OUT"

for rel in "${NEED[@]}"; do link_one "$rel"; done

echo
if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "FAILED: ${#MISSING[@]} of ${#NEED[@]} file(s) could not be located:" >&2
  printf '  - %s\n' "${MISSING[@]}" >&2
  exit 1
fi

echo "Done. All ${#NEED[@]} files linked."
echo "Set QUARTUS_SIM_LIB_DIR to: $OUT"
