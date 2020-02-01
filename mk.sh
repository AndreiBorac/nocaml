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

ARGKEY="${1-}"
shift || true

if [ "$ARGKEY" == "" ]
then
  echo "please specify one of: sort, udriver"
fi

if [ "$ARGKEY" == "sort" ]
then
  shift
  
  function compile_sort()
  (
    i=sort
    mkdir -p ./"$i"
    cd ./"$i"
    cp ./../../stdlib/*.{lisp,rb,c} .
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
fi

if [ "$ARGKEY" == "udriver" ]
then
  function crossbuild()
  {
    ./../../scraper.rb
    $CB_CC $CB_CFLAGS $CB_CFLAGS_SCRAPER -o ./scraper{,.c}
    $CB_EMU ./scraper >./scraped.rb
    cp ./../../stdlib/*.{lisp,rb,c} .
    cp ./../../programs/udriver/"$i"/*.lisp .
    ./../../wombat.rb ./main.lisp
    ocamlc -c ./wombat.ml
    # the compilation below is not expected to succeed; it is merely
    # used to verify the wombat translation. the only errors reported
    # should relate to "used but never defined" functions.
    $CB_CC $CB_CFLAGS -c -o /dev/null ./wombat.c || true
    cp ./../../collector.c ./
    cp ./../../udriver/udriver.c ./
    $CB_CC $CB_CFLAGS $CB_CFLAGS_FINAL -o ./main ./udriver.c
  }
  
  function crossbuild_amd64()
  {
    CB_CC=gcc
    CB_CFLAGS="-Os -Werror -Wall -Wextra -Wconversion -Wno-unused-const-variable -fno-strict-aliasing"
    CB_CFLAGS_SCRAPER=
    CB_CFLAGS_FINAL="-DCOLLECTOR_SHAM=6 -DCOLLECTOR_ARCH_X86_64_SYSV -DCOLLECTOR_USE_BUILTIN_POPCOUNT -mpopcnt -DUDRIVER_ARCH_X86_64_LINUX -nostartfiles -nodefaultlibs -static"
    CB_EMU=
  }
  
  function crossbuild_mipsel()
  {
    CB_CC=mipsel-linux-gnu-gcc
    CB_CFLAGS="-Os -Werror -Wall -Wextra -Wconversion -Wno-unused-const-variable -fno-strict-aliasing"
    CB_CFLAGS_SCRAPER="-static"
    CB_CFLAGS_FINAL="-DCOLLECTOR_SHAM=5 -DCOLLECTOR_ARCH_MIPSEL_O32_ABICALLS -DUDRIVER_ARCH_MIPSEL_LINUX_O32 -nostartfiles -nodefaultlibs -static"
    CB_EMU=qemu-mipsel-static
  }
  
  for i in 001 002
  do
    for a in amd64 mipsel
    do
      (
        echo "$i"-"$a"
        mkdir -p ./"$i"-"$a"
        cd ./"$i"-"$a"
        crossbuild_"$a"
        crossbuild
        echo "$i"-"$a"
        $CB_EMU ./main first_argument second_argument third_argument
      )
    done
  done
fi

echo "+OK (mk.sh)"
