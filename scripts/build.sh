#!/usr/bin/env bash
set -Eeuxo pipefail

SOLVER=$1
ARCH=$2

BIN=$(pwd)/bin
mkdir -p $BIN

case "$RUNNER_OS" in
  Linux)
    EXECUTABLE_EXT=""
    ;;
  macOS)
    EXECUTABLE_EXT=""
    ;;
  Windows)
    EXECUTABLE_EXT=".exe"
esac

case "$ARCH" in
  arm64)
    ARCH_OPT="--arm64=true"
    ;;
  *)
    ARCH_OPT=""
    ;;
esac

pushd repos/$SOLVER

# Apply Z3 source code fixes
if [[ "$SOLVER" == "z3-4.12.1" || "$SOLVER" == "z3-4.12.6" ]]; then
    COLUMN_INFO_FILE="src/math/lp/column_info.h"
    if [[ -f "$COLUMN_INFO_FILE" ]]; then
        echo "Fixing typo in $COLUMN_INFO_FILE"
        sed -i.bak 's/c\.m_low_bound/c.m_lower_bound/g' "$COLUMN_INFO_FILE"
    fi
fi

if [[ "$RUNNER_OS" == 'Windows' ]] ; then
  sed -i.bak -e 's/STATIC_BIN=False/STATIC_BIN=True/' scripts/mk_util.py
fi
python scripts/mk_make.py $ARCH_OPT
(cd build && make -j4 && cp z3$EXECUTABLE_EXT $BIN/$SOLVER$EXECUTABLE_EXT)
strip $BIN/$SOLVER$EXECUTABLE_EXT

if [[ "$ARCH" == 'x64' ]] ; then
  $BIN/$SOLVER$EXECUTABLE_EXT --version
fi

popd
