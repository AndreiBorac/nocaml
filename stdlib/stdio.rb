#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("stdio.c");

stdlib_register_integer_primordial("int-22", 22);
stdlib_register_integer_primordial("int-65536", 65536);

wombat_register_constructor("StandardIO", 1);

wombat_register_builtin("system-blob-address", 4); # blob (Blob), offs (Integer), retv (Integer), float (Integer) => (Integer)
wombat_register_builtin("system-exit", 1); # retv (Integer) => 'a
wombat_register_builtin("system-read", 4); # fd (Integer), addr (Integer), count (Integer), retv (Integer) => (Integer)
wombat_register_builtin("system-write", 4); # fd (Integer), addr (Integr), count (Integer), retv (Integer) => (Integer)
wombat_register_builtin("system-open", 4); # pathname (Blob), flags (Integer), mode (Integer), retv (Integer) => (Integer)
wombat_register_builtin("system-close", 2); # fd (Integer), retv (Integer) => (Integer)

wombat_ocaml(<<EOF);
type wombat_standard_io =
| Wombat_StandardIO of wombat_blob
;;

let wombat_constructor_StandardIO (a : wombat_blob) : wombat_standard_io = failwith "oops";;

type wombatx_standard_io =
| Wombatx_StandardIO of wombatx_blob
;;

let wombatx_constructor_StandardIO (a : wombatx_blob wombatxvector1) : wombatx_standard_io = failwith "oops";;

let wombat_builtin_system_minus_blob_minus_address (blob : wombat_blob) (offs : wombat_integer) (retv : wombat_integer) (float : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_system_minus_exit (retv : wombat_integer) : 'a = failwith "oops";;
let wombat_builtin_system_minus_read (fd : wombat_integer) (addr : wombat_integer) (count : wombat_integer) (retv : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_system_minus_write (fd : wombat_integer) (addr : wombat_integer) (count : wombat_integer) (retv : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_system_minus_open (pathname : wombat_blob) (flags : wombat_integer) (mode : wombat_integer) (retv : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_system_minus_close (fd : wombat_integer) (retv : wombat_integer) : wombat_integer = failwith "oops";;

let wombatx_builtin_system_minus_blob_minus_address (args : (wombatx_blob, wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector4) : wombatx_integer = failwith "oops";;
let wombatx_builtin_system_minus_exit (args : wombatx_integer wombatxvector1) : 'a = failwith "oops";;
let wombatx_builtin_system_minus_read (args : (wombatx_integer, wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector4) : wombatx_integer = failwith "oops";;
let wombatx_builtin_system_minus_write (args : (wombatx_integer, wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector4) : wombatx_integer = failwith "oops";;
let wombatx_builtin_system_minus_open (args : (wombatx_blob, wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector4) : wombatx_integer = failwith "oops";;
let wombatx_builtin_system_minus_close (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
EOF
