#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("OptionSuccess", 1);
wombat_register_constructor("OptionFailure", 1);

wombat_ocaml(<<EOF);
type ('a, 'b) wombat_option =
| Wombat_OptionSuccess of 'a
| Wombat_OptionFailure of 'b
;;

let wombat_constructor_OptionSuccess (a : 'a) : ('a, 'b) wombat_option = failwith "oops";;
let wombat_constructor_OptionFailure (b : 'b) : ('a, 'b) wombat_option = failwith "oops";;
EOF

wombat_ocaml(<<EOF);
type ('a, 'b) wombatx_option =
| Wombatx_OptionSuccess of 'a
| Wombatx_OptionFailure of 'b
;;

let wombatx_constructor_OptionSuccess (args : 'a wombatxvector1) : ('a, 'b) wombatx_option = failwith "oops";;
let wombatx_constructor_OptionFailure (args : 'b wombatxvector1) : ('a, 'b) wombatx_option = failwith "oops";;
EOF
