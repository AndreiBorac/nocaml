#!/usr/bin/env false
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("ErrorSuccess", 1);
wombat_register_constructor("ErrorFailure", 1);

wombat_ocaml(<<EOF
type ('a, 'b) wombat_error =
| Wombat_ErrorSuccess of 'a
| Wombat_ErrorFailure of 'b
;;

let wombat_constructor_ErrorSuccess (a : 'a) : ('a, 'b) wombat_error = failwith "oops";;
let wombat_constructor_ErrorFailure (b : 'b) : ('a, 'b) wombat_error = failwith "oops";;
EOF
            );

wombat_ocaml(<<EOF
type ('a, 'b) wombatx_error =
| Wombatx_ErrorSuccess of 'a
| Wombatx_ErrorFailure of 'b
;;

let wombatx_constructor_ErrorSuccess (args : 'a wombatxvector1) : ('a, 'b) wombatx_error = failwith "oops";;
let wombatx_constructor_ErrorFailure (args : 'b wombatxvector1) : ('a, 'b) wombatx_error = failwith "oops";;
EOF
            );
