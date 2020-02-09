#!/bin/false

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

X="$($CB_EMU ./main)"
[ "$X" == "./main" ]
