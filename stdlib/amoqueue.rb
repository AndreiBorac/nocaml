#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("AmoQueue", 2);

wombat_ocaml(<<EOF);
type 'a wombat_amo_queue =
| Wombat_AmoQueue of 'a wombat_list * 'a wombat_list
;;

let wombat_constructor_AmoQueue (ff : 'a wombat_list) (rr : 'a wombat_list) : 'a wombat_amo_queue = failwith "oops";;

type 'a wombatx_amo_queue =
| Wombatx_AmoQueue of 'a wombatx_list * 'a wombatx_list
;;

let wombatx_constructor_AmoQueue (args : (('a wombatx_list, 'a wombatx_list) wombatxvector2)) : 'a wombatx_amo_queue = failwith "oops";;
EOF
