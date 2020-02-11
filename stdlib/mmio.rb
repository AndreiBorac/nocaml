#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("mmio.c");

wombat_register_builtin("mmio-rd", 2);
wombat_register_builtin("mmio-wr", 2);
wombat_register_builtin("mmio-wr-16", 2);

wombat_ocaml(<<EOF);
let wombat_builtin_mmio_minus_rd (x : wombat_integer) (y : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_mmio_minus_wr (x : wombat_integer) (y : wombat_integer) : wombat_unit = failwith "oops";;
let wombat_builtin_mmio_minus_wr_minus_16 (x : wombat_integer) (y : wombat_integer) : wombat_unit = failwith "oops";;
EOF

wombat_ocaml(<<EOF);
let wombatx_builtin_mmio_minus_rd (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
let wombatx_builtin_mmio_minus_wr (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_unit = failwith "oops";;
let wombatx_builtin_mmio_minus_wr_minus_16 (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_unit = failwith "oops";;
EOF
