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
if [[ "$SOLVER" == "z3-4.12.1" ]]; then
    # Fix typo in column_info.h
    COLUMN_INFO_FILE="src/math/lp/column_info.h"
    if [[ -f "$COLUMN_INFO_FILE" ]]; then
        echo "Fixing typo in $COLUMN_INFO_FILE"
        sed -i.bak 's/c\.m_low_bound/c.m_lower_bound/g' "$COLUMN_INFO_FILE"
    fi
    
    # Fix typo in static_matrix.h
    STATIC_MATRIX_FILE="src/math/lp/static_matrix.h"
    if [[ -f "$STATIC_MATRIX_FILE" ]]; then
        echo "Fixing typo in $STATIC_MATRIX_FILE"
        sed -i.bak 's/v\.m_matrix\.get(/v.m_matrix.get_elem(/g' "$STATIC_MATRIX_FILE"
    fi
    
    # Fix typo in static_matrix_def.h
    STATIC_MATRIX_DEF_FILE="src/math/lp/static_matrix_def.h"
    if [[ -f "$STATIC_MATRIX_DEF_FILE" ]]; then
        echo "Fixing typo in $STATIC_MATRIX_DEF_FILE"
        sed -i.bak 's/A\.get_value_of_column_cell(col)/A.get_val(col)/g' "$STATIC_MATRIX_DEF_FILE"
    fi
    
    # Fix tail_matrix.h debug-only get_elem issue
    TAIL_MATRIX_FILE="src/math/lp/tail_matrix.h"
    if [[ -f "$TAIL_MATRIX_FILE" ]]; then
        echo "Fixing debug-only get_elem issue in $TAIL_MATRIX_FILE"
        # Wrap the ref_row struct and operator[] in debug condition
        sed -i.bak 's/struct ref_row {/#ifdef Z3DEBUG\n    struct ref_row {/' "$TAIL_MATRIX_FILE"
        sed -i.bak 's/ref_row operator\[\](unsigned i) const { return ref_row(\*this, i);}/ref_row operator[](unsigned i) const { return ref_row(*this, i);}\n#endif/' "$TAIL_MATRIX_FILE"
    fi
fi

if [[ "$SOLVER" == "z3-4.12.6" ]]; then
    # Fix typo in column_info.h
    COLUMN_INFO_FILE="src/math/lp/column_info.h"
    if [[ -f "$COLUMN_INFO_FILE" ]]; then
        echo "Fixing typo in $COLUMN_INFO_FILE"
        sed -i.bak 's/c\.m_low_bound/c.m_lower_bound/g' "$COLUMN_INFO_FILE"
    fi
    
    # Fix typo in static_matrix.h
    STATIC_MATRIX_FILE="src/math/lp/static_matrix.h"
    if [[ -f "$STATIC_MATRIX_FILE" ]]; then
        echo "Fixing typo in $STATIC_MATRIX_FILE"
        sed -i.bak 's/v\.m_matrix\.get(/v.m_matrix.get_elem(/g' "$STATIC_MATRIX_FILE"
    fi
    
    # Fix typo in static_matrix_def.h
    STATIC_MATRIX_DEF_FILE="src/math/lp/static_matrix_def.h"
    if [[ -f "$STATIC_MATRIX_DEF_FILE" ]]; then
        echo "Fixing typo in $STATIC_MATRIX_DEF_FILE"
        sed -i.bak 's/A\.get_value_of_column_cell(col)/A.get_val(col)/g' "$STATIC_MATRIX_DEF_FILE"
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
