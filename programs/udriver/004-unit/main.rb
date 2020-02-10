#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

[
  [ "reverse", 1 ],
  [ "concat", 1 ],
  [ "concat", 2 ],
  [ "concat", 3 ],
  [ "filter", 1 ],
  [ "map", 1 ],
  [ "blob-extract-range", 1 ],
  [ "concat-all", 1 ],
].each{|pair|
  name, nr, = pair;
  stdlib_register_blob_primordial("str-test-#{name}-#{nr}", "test #{name} #{nr}\n");
};

stdlib_register_blob_primordial("str-hello-world", "Hello World!");
stdlib_register_blob_primordial("str-hello-world-trunc", "ello Worl");
