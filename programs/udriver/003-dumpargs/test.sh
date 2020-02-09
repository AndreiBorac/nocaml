#!/bin/false

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

X="$($CB_EMU ./main first_argument second_argument third_argument fourth_argument fifth_argument sixth_argument)"
[ "$X" == "./mainfirst_argumentsecond_argumentthird_argumentfourth_argumentfifth_argumentsixth_argument" ]
