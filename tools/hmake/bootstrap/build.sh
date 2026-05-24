#!/usr/bin/env sh
#
# build.sh — Bootstrap hmake for the host PC using FPC.
#
# Run from the repository root:
#   sh tools/hmake/bootstrap/build.sh
#
# CopyLeft (c) 1995-2024 by PopolonY2k.
# CopyLeft (c) since 2024 by Hinotori Team.

set -e

OUTDIR="build"
ENTRY="tools/hmake/src/main/fpc/hmake.pas"
TARGET="${OUTDIR}/hmake"

if ! command -v fpc >/dev/null 2>&1; then
    echo "Error: fpc not found in PATH. Install Free Pascal Compiler first." >&2
    exit 1
fi

mkdir -p "${OUTDIR}"

echo "Building hmake..."
fpc -FE"${OUTDIR}" -g -gw "${ENTRY}"
echo "Done: ${TARGET}"
