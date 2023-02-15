#!/usr/bin/env bash
set -Eeuxo pipefail

SOLVER=$1
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

pushd repos/$SOLVER
if [[ "$RUNNER_OS" == 'Windows' ]] ; then
  sed -i.bak -e 's/STATIC_BIN=False/STATIC_BIN=True/' scripts/mk_util.py
fi
python scripts/mk_make.py
(cd build && make -j4 && cp z3$EXECUTABLE_EXT $BIN/$SOLVER$EXECUTABLE_EXT)
strip $BIN/$SOLVER$EXECUTABLE_EXT
$BIN/$SOLVER$EXECUTABLE_EXT --version
popd
