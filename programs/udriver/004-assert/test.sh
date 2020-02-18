#!/bin/false

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

if $CB_EMU ./main
then
  echo "oops, got a clean exit from an assert that should have failed"
  exit 1
else
  echo "success, got non-zero exit code $?"
fi
