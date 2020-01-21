#!/usr/bin/env false
# copyright (c) 2020 by Andrei Borac

wombat_enable_ocaml;

# blob
wombat_register_primordial("blob-empty", <<EOF
static const uintptr_t wombat_primordial_blob_minus_empty[1] = { (1UL << ((8*sizeof(uintptr_t))-1)) };
EOF
                          );
wombat_register_builtin("blob-length", 2);
wombat_register_builtin("blob-copy-range", 5);

# False
wombat_register_constructor("False", 0);
wombat_register_primordial("false", <<EOF
static const uintptr_t wombat_primordial_false[1] = { WOMBAT_CONSTRUCTOR_False };
EOF
                          );

# True
wombat_register_constructor("True", 0);
wombat_register_primordial("true", <<EOF
static const uintptr_t wombat_primordial_true[1] = { WOMBAT_CONSTRUCTOR_True };
EOF
                          );

# List
wombat_register_constructor("ListFini", 2);
wombat_register_constructor("ListCons", 2);

wombat_register_primordial("list-fini", <<EOF
static const uintptr_t wombat_primordial_list_minus_fini[1] = { WOMBAT_CONSTRUCTOR_ListFini };
EOF
                          );

# Integer
wombat_register_native_constructor("Integer", 1);
wombat_register_primordial("zero", <<EOF
static const uintptr_t wombat_primordial_zero[2] = { WOMBAT_NATIVE_CONSTRUCTOR_Integer, 0 };
EOF
                          );
wombat_register_primordial("one", <<EOF
static const uintptr_t wombat_primordial_one[2] = { WOMBAT_NATIVE_CONSTRUCTOR_Integer, 1 };
EOF
                          );
wombat_register_builtin("int-lt", 2);
wombat_register_builtin("int-gt", 2);
wombat_register_builtin("int-add", 3);
wombat_register_builtin("int-sub", 3);

wombat_ocaml(<<EOF
let wombat_primordial_blob_minus_empty = Wombat_Blob;;

type wombat_bool =
| Wombat_False
| Wombat_True
;;

let wombat_primordial_false = Wombat_False;;
let wombat_primordial_true = Wombat_True;;

type 'a wombat_list =
| Wombat_ListFini
| Wombat_ListCons of 'a * 'a wombat_list
;;

let wombat_primordial_list_minus_fini = (Wombat_ListFini);;

let wombat_constructor_ListCons (head : 'a) (tail : 'a wombat_list) : 'a wombat_list = failwith "oops";;

type wombat_integer =
| Wombat_Integer
;;

(* can now define blob builtins that depend on Integer *)
let wombat_builtin_blob_minus_length (x : wombat_blob) (z : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_blob_minus_copy_minus_range (dst : wombat_blob) (off : wombat_integer) (len : wombat_integer) (src : wombat_blob) (srcoff : wombat_integer) : wombat_blob = failwith "oops";;

let wombat_native_constructor_Integer = (Wombat_Integer);;

let wombat_primordial_zero = (Wombat_Integer);;
let wombat_primordial_one = (Wombat_Integer);;

let wombat_builtin_int_minus_lt (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_gt (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_add (x : wombat_integer) (y : wombat_integer) (z : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_int_minus_sub (x : wombat_integer) (y : wombat_integer) (z : wombat_integer) : wombat_integer = failwith "oops";;
EOF
            );

wombat_ocaml(<<EOF
let wombatx_primordial_blob_minus_empty = Wombatx_Blob;;

type wombatx_bool =
| Wombatx_False
| Wombatx_True
;;

let wombatx_primordial_false = Wombatx_False;;
let wombatx_primordial_true = Wombatx_True;;

type 'a wombatx_list =
| Wombatx_ListFini
| Wombatx_ListCons of 'a * 'a wombatx_list
;;

let wombatx_primordial_list_minus_fini = (Wombatx_ListFini);;

let wombatx_constructor_ListCons (args : ('a, 'a wombatx_list) wombatxvector2) : 'a wombatx_list = failwith "oops";;

type wombatx_integer =
| Wombatx_Integer
;;

(* can now define blob builtins that depend on Integer *)
let wombatx_builtin_blob_minus_length (args : (wombatx_blob, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
let wombatx_builtin_blob_minus_copy_minus_range (args : (wombatx_blob, wombatx_integer, wombatx_integer, wombatx_blob, wombatx_integer) wombatxvector5) : wombatx_blob = failwith "oops";;

let wombatx_native_constructor_Integer (args : wombatxvector0) : wombatx_integer = failwith "oops";;

let wombatx_primordial_zero = (Wombatx_Integer);;
let wombatx_primordial_one = (Wombatx_Integer);;

let wombatx_builtin_int_minus_lt (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_gt (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_add (args : (wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector3) : wombatx_integer = failwith "oops";;
let wombatx_builtin_int_minus_sub (args : (wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector3) : wombatx_integer = failwith "oops";;
EOF
            );
