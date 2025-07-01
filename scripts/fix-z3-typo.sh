#!/usr/bin/env bash
# Fix typo in Z3 source code for versions 4.12.1 and 4.12.6
# This fixes a compilation error with newer GCC versions

SOLVER=$1

if [[ "$SOLVER" == "z3-4.12.1" || "$SOLVER" == "z3-4.12.6" ]]; then
    COLUMN_INFO_FILE="repos/$SOLVER/src/math/lp/column_info.h"
    if [[ -f "$COLUMN_INFO_FILE" ]]; then
        echo "Fixing typo in $COLUMN_INFO_FILE"
        sed -i.bak 's/c\.m_low_bound/c.m_lower_bound/g' "$COLUMN_INFO_FILE"
    fi
fi
