#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("PitabEntry", 3);

wombat_ocaml(<<EOF);
type wombat_pitabentry =
| Wombat_PitabEntry of wombat_blob * wombat_integer * wombat_integer
;;

let wombat_constructor_PitabEntry (a : wombat_blob) (b : wombat_integer) (c : wombat_integer) : wombat_pitabentry = failwith "oops";;

type wombatx_pitabentry =
| Wombatx_PitabEntry of wombatx_blob * wombatx_integer * wombatx_integer
;;

let wombatx_constructor_PitabEntry (a : (wombatx_blob, wombatx_integer, wombatx_integer) wombatxvector3) : wombatx_pitabentry = failwith "oops";;
EOF
