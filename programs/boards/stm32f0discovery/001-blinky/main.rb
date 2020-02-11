#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

[
  "0x00000100",
  "0x00010000",
  "0x00080000",
].each{|str|
  stdlib_register_integer_primordial("int-#{str}", str[2..-1].to_i(16));
};
