#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

stdlib_register_integer_primordial("int-997", 997);

[
  [ "reverse", 1 ],
  [ "concat", 3 ],
  [ "filter", 1 ],
  [ "map", 1 ],
  [ "blob-extract-range", 1 ],
  [ "foldl", 1 ],
  [ "foldr", 1 ],
  [ "concat-all", 1 ],
  [ "replicate", 1 ],
  [ "int-negate", 2 ],
  [ "pitab-coalesce", 1 ],
  [ "pitab-head-rest", 1 ],
].each{|pair|
  name, nr, = pair;
  (1..nr).each{|i|
    stdlib_register_blob_primordial("str-test-#{name}-#{i}", "test #{name} #{i}\n");
  };
};

stdlib_register_blob_primordial("str-hello-world", "Hello World!");
stdlib_register_blob_primordial("str-hello-world-trunc", "ello Worl");
