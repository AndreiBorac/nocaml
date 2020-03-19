#!/usr/bin/env bash
# -*- mode: ruby; coding: binary -*-
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

NIL2=\
=begin
exec env -i PATH="$(echo /{usr/{local/,},}{s,}bin | tr ' ' ':')" ruby -E BINARY:BINARY -I . -e 'load("'"$0"'");' -- "$@"
=end
nil;

def main()
  identifiers = [];
  identifiers += [ "O_APPEND", "O_ASYNC", "O_CLOEXEC", "O_CREAT", "O_DIRECT", "O_DIRECTORY", "O_DSYNC", "O_EXCL", "O_LARGEFILE", "O_NOATIME", "O_NOCTTY", "O_NOFOLLOW", "O_NONBLOCK", "O_PATH", "O_SYNC", "O_TMPFILE", "O_TRUNC", "O_RDONLY", "O_WRONLY", "O_RDWR", ];
  identifiers += [ "PROT_READ", "PROT_WRITE", "MAP_SHARED", "MAP_ANONYMOUS", ];
  
  out = [];

  out << <<EOF
#define _GNU_SOURCE

#include <stdbool.h>
#include <inttypes.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <sys/mman.h>

#include <stdio.h>

int main()
{
EOF
  
  identifiers.each{|identifier|
    out << "  printf(\"stdlib_register_integer_primordial(\\\"C_#{identifier}\\\", %u);\\n\", #{identifier});";
  };
  
  out << <<EOF
  
  return 0;
}
EOF
  
  IO.write("scraper.c", out.join("\n"));
end

main;
