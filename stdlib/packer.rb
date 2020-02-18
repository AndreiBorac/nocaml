#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("packer.c");

wombat_register_builtin("packer-pack-8", 2);
wombat_register_builtin("packer-pack-16", 2);
wombat_register_builtin("packer-pack-32", 2);

wombat_register_builtin("packer-unpack-8", 2);
wombat_register_builtin("packer-unpack-16", 2);
wombat_register_builtin("packer-unpack-32", 2);

wombat_ocaml(<<EOF);
let wombat_builtin_packer_minus_pack_minus_8  (x : wombat_integer) (y : wombat_blob) : wombat_blob = failwith "oops";;
let wombat_builtin_packer_minus_pack_minus_16 (x : wombat_integer) (y : wombat_blob) : wombat_blob = failwith "oops";;
let wombat_builtin_packer_minus_pack_minus_32 (x : wombat_integer) (y : wombat_blob) : wombat_blob = failwith "oops";;

let wombat_builtin_packer_minus_unpack_minus_8  (x : wombat_blob) (y : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_packer_minus_unpack_minus_16 (x : wombat_blob) (y : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_packer_minus_unpack_minus_32 (x : wombat_blob) (y : wombat_integer) : wombat_integer = failwith "oops";;
EOF

wombat_ocaml(<<EOF);
let wombatx_builtin_packer_minus_pack_minus_8  (args : (wombatx_integer, wombatx_blob) wombatxvector2) : wombatx_blob = failwith "oops";;
let wombatx_builtin_packer_minus_pack_minus_16 (args : (wombatx_integer, wombatx_blob) wombatxvector2) : wombatx_blob = failwith "oops";;
let wombatx_builtin_packer_minus_pack_minus_32 (args : (wombatx_integer, wombatx_blob) wombatxvector2) : wombatx_blob = failwith "oops";;

let wombatx_builtin_packer_minus_unpack_minus_8  (args : (wombatx_blob, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
let wombatx_builtin_packer_minus_unpack_minus_16 (args : (wombatx_blob, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
let wombatx_builtin_packer_minus_unpack_minus_32 (args : (wombatx_blob, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
EOF
