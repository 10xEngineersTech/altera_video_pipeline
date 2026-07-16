#!/usr/bin/env bash
#
# setup_sim_libs.sh
# ------------------
# Builds a "stitched" simulation library directory (sim_libs_c10gx/) that
# presents the classic Quartus  eda/sim_lib/{*, mentor/*}  layout that
# platform/pipeline/sim/mentor/msim_setup.tcl (dev_com) expects.
#
# Quartus 25.1.1 scatters these source files across questa_fse/...,
# quartus/libraries/vhdl/... and quartus/eda/sim_lib/common/ instead of a
# single flat eda/sim_lib/ dir. This script auto-locates each file dev_com
# needs (by basename) in the 25.1.1 tree and symlinks it into a flat dir,
# plus a mentor/ subdir for the encrypted atoms. The two Cyclone 10 GX
# HIP/HSSI *_ncrypt.v files are NOT shipped in 25.1.1, so they are stubbed
# with empty files (unused by the video pipeline).
#
# After running, point QUARTUS_SIM_LIB_DIR at the generated dir:
#   set QUARTUS_SIM_LIB_DIR .../Integrated_design/sim_libs_c10gx
#
set -euo pipefail

# Override by exporting QUARTUS_ROOT in ~/.bashrc; falls back to the local path.
QUARTUS_ROOT="${QUARTUS_ROOT:-/mnt/ssd2/Quartus_25_1_1_Setup_Installation}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/sim_libs_c10gx"

# Files dev_com opens directly under $QUARTUS_SIM_LIB_DIR/
FLAT=(
  220model.v 220model.vhd 220pack.vhd
  alt_dspbuilder_package.vhd altera_europa_support_lib.vhd
  altera_lnsim.sv altera_lnsim_components.vhd
  altera_mf.v altera_mf.vhd altera_mf_components.vhd
  altera_primitives.v altera_primitives.vhd altera_primitives_components.vhd
  altera_standard_functions.vhd altera_syn_attributes.vhd
  cyclone10gx_atoms.v cyclone10gx_atoms.vhd cyclone10gx_components.vhd
  cyclone10gx_hip_atoms.v cyclone10gx_hip_atoms.vhd cyclone10gx_hip_components.vhd
  cyclone10gx_hssi_atoms.v cyclone10gx_hssi_atoms.vhd cyclone10gx_hssi_components.vhd
  sgate.v sgate.vhd sgate_pack.vhd
  simsf_dpi.cpp
)

# Files dev_com opens under $QUARTUS_SIM_LIB_DIR/mentor/
MENTOR=( cyclone10gx_atoms_ncrypt.v )

# Not shipped in 25.1.1 -> stub as empty (unused by this design)
MENTOR_STUB=( cyclone10gx_hip_atoms_ncrypt.v cyclone10gx_hssi_atoms_ncrypt.v )

rm -rf "$OUT"
mkdir -p "$OUT/mentor"

# Prefer the canonical simulation-source trees over scattered example-project
# copies (e.g. ip/altera/.../example_project/common) which may be trimmed.
PREFERRED_ROOTS=(
  "$QUARTUS_ROOT/questa_fse/intel/verilog/src"
  "$QUARTUS_ROOT/questa_fse/intel/vhdl/src"
  "$QUARTUS_ROOT/quartus/libraries/vhdl"
  "$QUARTUS_ROOT/quartus/eda/sim_lib"
  "$QUARTUS_ROOT/quartus/eda/fv_lib"
)

link_one() {  # $1 = basename, $2 = dest dir
  local base="$1" dest="$2" hit=""
  local root
  for root in "${PREFERRED_ROOTS[@]}"; do
    [ -d "$root" ] || continue
    hit="$(find "$root" -type f -name "$base" 2>/dev/null | head -1)"
    [ -n "$hit" ] && break
  done
  # Fallback: anywhere in the install tree
  if [ -z "$hit" ]; then
    hit="$(find "$QUARTUS_ROOT" -type f -name "$base" 2>/dev/null | head -1)"
  fi
  if [ -z "$hit" ]; then
    echo "  MISSING: $base (not found in $QUARTUS_ROOT)" >&2
    return 1
  fi
  ln -sf "$hit" "$dest/$base"
  echo "  linked : $base -> $hit"
}

echo "Building $OUT ..."
for f in "${FLAT[@]}";   do link_one "$f" "$OUT";        done
for f in "${MENTOR[@]}"; do link_one "$f" "$OUT/mentor"; done

for f in "${MENTOR_STUB[@]}"; do
  printf '// Stub: %s is not shipped in Quartus 25.1.1 and is unused by the video pipeline.\n' "$f" > "$OUT/mentor/$f"
  echo "  stubbed: mentor/$f"
done

echo "Done. Set QUARTUS_SIM_LIB_DIR to: $OUT"
