#!/usr/bin/env bash
# copyright (c) 2020 by Andrei Borac

set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

[ -d ./build ] || sudo mkdir -m 0000 ./build
sudo mountpoint -q ./build && sudo umount ./build
sudo mountpoint -q ./build && exit 1
sudo mountpoint -q ./build || sudo mount -t tmpfs none ./build
cd ./build

function compile_sort()
(
  i=sort
  mkdir -p ./"$i"
  cd ./"$i"
  cp ./../../programs/"$i"/*.{lisp,rb,c} .
  ./../../wombat.rb ./program.lisp
  ocaml wombat.ml
  # the compilation below is not expected to succeed; it is merely
  # used to verify the wombat translation. the only errors reported
  # should relate to "used but never defined" functions.
  gcc -O2 -Werror -Wall -Wextra -Wconversion -c -o /dev/null ./wombat.c || true
  cp ./../../collector.c ./
  cp ./../../programs/"$i"/driver.c ./
  
  gcc   -DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -DQSELMS="$1" -DNTRIALS="$2" -g -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.g ./driver.c
  gcc   -DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -DQSELMS="$1" -DNTRIALS="$2" -O2 -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.o2 ./driver.c
  gcc   -DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -DQSELMS="$1" -DNTRIALS="$2" -Os -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.os ./driver.c
  clang -DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -DQSELMS="$1" -DNTRIALS="$2" -O2 -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.clang.o2 ./driver.c
  clang -DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -DQSELMS="$1" -DNTRIALS="$2" -Os -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.clang.os ./driver.c
  
  mipsel-linux-gnu-gcc -DCOLLECTOR_SHAM=5 -DCOLLECTOR_ARCH_MIPSEL_O32_ABICALLS -DQSELMS="$1" -DNTRIALS="$2" -DDRIVER_USE_MMAP  -g -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.mipsel.g ./driver.c -static
  mipsel-linux-gnu-gcc -DCOLLECTOR_SHAM=5 -DCOLLECTOR_ARCH_MIPSEL_O32_ABICALLS -DQSELMS="$1" -DNTRIALS="$2" -DDRIVER_USE_MMAP -O2 -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.mipsel.o2 ./driver.c -static
  mipsel-linux-gnu-gcc -DCOLLECTOR_SHAM=5 -DCOLLECTOR_ARCH_MIPSEL_O32_ABICALLS -DQSELMS="$1" -DNTRIALS="$2" -DDRIVER_USE_MMAP -Os -Werror -Wall -Wextra -Wconversion -fno-strict-aliasing -o ./driver.mipsel.os ./driver.c -static
)

compile_sort 1048576 9

if [ "${1-}" != "norun" ]
then
  setarch "$(uname -m)" -R ./sort/driver.o2
  setarch "$(uname -m)" -R ./sort/driver.os
  setarch "$(uname -m)" -R ./sort/driver.clang.o2
  setarch "$(uname -m)" -R ./sort/driver.clang.os
fi

if [ "${2-}" == "stats" ]
then
  for j in 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 242144 524288 1048576
  do
    k="$(( (10000000/j) ))"
    compile_sort "$j" "$k"
    u="$(setarch "$(uname -m)" -R ./sort/driver.o2 | egrep '^used=' | sed -e 's/^used=//')"
    echo "$j $u" >>./perf.txt
    u="$(setarch "$(uname -m)" -R ./sort/driver.clang.os | egrep '^used=' | sed -e 's/^used=//')"
    echo "$j $u" >>./perf.clang.os.txt
  done
fi

echo "+OK (mk.sh)"
