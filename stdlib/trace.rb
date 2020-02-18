#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("trace.c");

wombat_register_builtin("trace", 1);

wombat_ocaml(<<EOF);
let wombat_builtin_trace (x : 'a) : 'a = failwith "oops";;
let wombatx_builtin_trace (x : 'a wombatxvector1) : 'a = failwith "oops";;
EOF
