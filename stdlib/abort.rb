#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("abort.c");

wombat_register_builtin("abort", 0);

wombat_ocaml(<<EOF);
let wombat_builtin_abort : 'a = failwith "oops";;
let wombatx_builtin_abort (args : wombatxvector0) : 'a = failwith "oops";;
EOF
