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
  [ "records", 2 ],
].each{|pair|
  name, nr, = pair;
  (1..nr).each{|i|
    stdlib_register_blob_primordial("str-test-#{name}-#{i}", "test #{name} #{i}\n");
  };
};

stdlib_register_blob_primordial("str-hello-world", "Hello World!");
stdlib_register_blob_primordial("str-hello-world-trunc", "ello Worl");

wombat_register_constructor("Record", 3);
wombat_register_fields("Record", [ "apple", "orange", "grape" ]);

wombat_ocaml(<<EOF);
type ('a, 'b, 'c) wombat_record =
| Wombat_Record of 'a * 'b * 'c
;;

let wombat_constructor_Record (a : 'a) (b : 'b) (c : 'c) : ('a, 'b, 'c) wombat_record = failwith "oops";;

type ('a, 'b, 'c) wombatx_record =
| Wombatx_Record of 'a * 'b * 'c
;;

let wombatx_constructor_Record (args : ('a, 'b, 'c) wombatxvector3) : ('a, 'b, 'c) wombatx_record = failwith "oops";;
EOF
