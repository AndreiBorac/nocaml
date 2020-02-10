#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("Pair", 2);

wombat_ocaml(<<EOF

type ('a, 'b) wombat_pair =
| Wombat_Pair of 'a * 'b
;;

let wombat_constructor_Pair (a : 'a) (b : 'b) : ('a, 'b) wombat_pair = failwith "oops";;

EOF
            );

wombat_ocaml(<<EOF

type ('a, 'b) wombatx_pair =
| Wombatx_Pair of 'a * 'b
;;

let wombatx_constructor_Pair (args : ('a, 'b) wombatxvector2) = failwith "oops";;

EOF
            );
