#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_enable_ocaml;

# blob
wombat_register_primordial("blob-empty", <<EOF
static const uintptr_t wombat_primordial_blob_minus_empty[1] = { (1UL << ((8*sizeof(uintptr_t))-1)) };
EOF
                          );
wombat_register_builtin("blob-eq", 2);
wombat_register_builtin("blob-length", 2);
wombat_register_builtin("blob-copy-range", 5);

# Unit
wombat_register_constructor("Unit", 0);
wombat_register_primordial("unit", <<EOF
static const uintptr_t wombat_primordial_unit[1] = { WOMBAT_CONSTRUCTOR_Unit };
EOF
                          );

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

# Pair
wombat_register_constructor("Pair", 2);

# Vector{3,4}
wombat_register_constructor("Vector3", 3);
wombat_register_constructor("Vector4", 4);

# List
wombat_register_constructor("ListFini", 0);
wombat_register_constructor("ListCons", 2);

wombat_register_primordial("list-fini", <<EOF
static const uintptr_t wombat_primordial_list_minus_fini[1] = { WOMBAT_CONSTRUCTOR_ListFini };
EOF
                          );

# Integer
wombat_register_native_constructor("Integer", 1);

wombat_register_builtin("int-eq", 2);
wombat_register_builtin("int-lt", 2);
wombat_register_builtin("int-lte", 2);
wombat_register_builtin("int-gt", 2);
wombat_register_builtin("int-gte", 2);
wombat_register_builtin("int-add", 3);
wombat_register_builtin("int-sub", 3);
wombat_register_builtin("int-min", 2);
wombat_register_builtin("int-max", 2);

wombat_ocaml(<<EOF);
let wombat_primordial_blob_minus_empty = Wombat_Blob;;

type wombat_unit =
| Wombat_Unit
;;

let wombat_primordial_unit = Wombat_Unit;;

type wombat_bool =
| Wombat_False
| Wombat_True
;;

(* can now define blob builtins that depend on bool *)
let wombat_builtin_blob_minus_eq (bloba : wombat_blob) (blobb : wombat_blob) : wombat_bool = failwith "oops";;

let wombat_primordial_false = Wombat_False;;
let wombat_primordial_true = Wombat_True;;

type ('a, 'b) wombat_pair =
| Wombat_Pair of 'a * 'b
;;

let wombat_constructor_Pair (a : 'a) (b : 'b) : ('a, 'b) wombat_pair = failwith "oops";;

type ('a, 'b, 'c) wombat_vector3 =
| Wombat_Vector3 of 'a * 'b * 'c
;;

let wombat_constructor_Vector3 (a : 'a) (b : 'b) (c : 'c) : ('a, 'b, 'c) wombat_vector3 = failwith "oops";;

type ('a, 'b, 'c, 'd) wombat_vector4 =
| Wombat_Vector4 of 'a * 'b * 'c * 'd
;;

let wombat_constructor_Vector4 (a : 'a) (b : 'b) (c : 'c) (d : 'd) : ('a, 'b, 'c, 'd) wombat_vector4 = failwith "oops";;

type 'a wombat_list =
| Wombat_ListFini
| Wombat_ListCons of 'a * 'a wombat_list
;;

let wombat_primordial_list_minus_fini = (Wombat_ListFini);;

let wombat_constructor_ListCons (head : 'a) (tail : 'a wombat_list) : 'a wombat_list = failwith "oops";;

type wombat_integer =
| Wombat_Integer
;;

(* can now define blob builtins that depend on integer *)
let wombat_builtin_blob_minus_length (x : wombat_blob) (z : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_blob_minus_copy_minus_range (dst : wombat_blob) (off : wombat_integer) (len : wombat_integer) (src : wombat_blob) (srcoff : wombat_integer) : wombat_blob = failwith "oops";;

let wombat_native_constructor_Integer = (Wombat_Integer);;

let wombat_builtin_int_minus_eq (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_lt (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_lte (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_gt (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_gte (x : wombat_integer) (y : wombat_integer) : wombat_bool = failwith "oops";;
let wombat_builtin_int_minus_add (x : wombat_integer) (y : wombat_integer) (z : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_int_minus_sub (x : wombat_integer) (y : wombat_integer) (z : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_int_minus_min (x : wombat_integer) (y : wombat_integer) : wombat_integer = failwith "oops";;
let wombat_builtin_int_minus_max (x : wombat_integer) (y : wombat_integer) : wombat_integer = failwith "oops";;
EOF

wombat_ocaml(<<EOF);
let wombatx_primordial_blob_minus_empty = Wombatx_Blob;;

type wombatx_unit =
| Wombatx_Unit
;;

let wombatx_primordial_unit = Wombatx_Unit;;

type wombatx_bool =
| Wombatx_False
| Wombatx_True
;;

(* can now define blob builtins that depend on bool *)
let wombatx_builtin_blob_minus_eq (args : (wombatx_blob, wombatx_blob) wombatxvector2) : wombatx_bool = failwith "oops";;

let wombatx_primordial_false = Wombatx_False;;
let wombatx_primordial_true = Wombatx_True;;

type ('a, 'b) wombatx_pair =
| Wombatx_Pair of 'a * 'b
;;

let wombatx_constructor_Pair (args : ('a, 'b) wombatxvector2) : ('a, 'b) wombatx_pair = failwith "oops";;

type ('a, 'b, 'c) wombatx_vector3 =
| Wombatx_Vector3 of 'a * 'b * 'c
;;

let wombatx_constructor_Vector3 (args : ('a, 'b, 'c) wombatxvector3) : ('a, 'b, 'c) wombatx_vector3 = failwith "oops";;

type ('a, 'b, 'c, 'd) wombatx_vector4 =
| Wombatx_Vector4 of 'a * 'b * 'c *'d
;;

let wombatx_constructor_Vector4 (args : ('a, 'b, 'c, 'd) wombatxvector4) : ('a, 'b, 'c, 'd) wombatx_vector4 = failwith "oops";;

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

let wombatx_builtin_int_minus_eq (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_lt (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_lte (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_gt (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_gte (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_bool = failwith "oops";;
let wombatx_builtin_int_minus_add (args : (wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector3) : wombatx_integer = failwith "oops";;
let wombatx_builtin_int_minus_sub (args : (wombatx_integer, wombatx_integer, wombatx_integer) wombatxvector3) : wombatx_integer = failwith "oops";;
let wombatx_builtin_int_minus_min (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
let wombatx_builtin_int_minus_max (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
EOF

$stdlib_registered_integer_primordials = {};

def stdlib_register_integer_primordial(name, value)
  raise if (!(name.class == String));
  raise if (!(value.class == Fixnum));
  
  if ((name2 = $stdlib_registered_integer_primordials[value]).nil?.!)
    return if (name == name2);
    wombat_register_primordial(name, <<EOF);
#define wombat_primordial_#{c_ify(name)} wombat_primordial_#{c_ify(name2)}
EOF
  else
    $stdlib_registered_integer_primordials[value] = name;
    wombat_register_primordial(name, <<EOF);
static const uintptr_t wombat_primordial_#{c_ify(name)}[2] = { WOMBAT_NATIVE_CONSTRUCTOR_Integer, #{value} };
EOF
  end
  
  wombat_ocaml(<<EOF);
let wombat_primordial_#{c_ify(name)} = (Wombat_Integer);;
let wombatx_primordial_#{c_ify(name)} = (Wombatx_Integer);;
EOF
end

stdlib_register_integer_primordial("zero", 0);
stdlib_register_integer_primordial("int-0", 0);

stdlib_register_integer_primordial("one", 1);
stdlib_register_integer_primordial("int-1", 1);

stdlib_register_integer_primordial("two", 2);
stdlib_register_integer_primordial("int-2", 2);

stdlib_register_integer_primordial("int-3", 3);
stdlib_register_integer_primordial("int-4", 4);
stdlib_register_integer_primordial("int-5", 5);
stdlib_register_integer_primordial("int-6", 6);
stdlib_register_integer_primordial("int-7", 7);
stdlib_register_integer_primordial("int-8", 8);
stdlib_register_integer_primordial("int-9", 9);

$stdlib_registered_blob_primordials = {};

def stdlib_register_blob_primordial(name, value)
  raise if (!(name.class == String));
  raise if (!(value.class == String));
  raise if (!(value.encoding == Encoding::ASCII_8BIT));
  
  if ((name2 = $stdlib_registered_blob_primordials[value]).nil?.!)
    return if (name == name2);
    wombat_register_primordial(name, <<EOF);
#define wombat_primordial_#{c_ify(name)} wombat_primordial_#{c_ify(name2)}
EOF
  else
    $stdlib_registered_integer_primordials[value] = name;
    c_tag = "((1UL << ((8*sizeof(uintptr_t))-1)) | #{value.length})";
    wombat_register_primordial(name, <<EOF);
struct {
  uintptr_t tag;
  uint8_t chr[((#{value.length}+sizeof(uintptr_t)-1)/sizeof(uintptr_t))*sizeof(uintptr_t)];
} wombat_raw_primordial_#{c_ify(name)} = { #{c_tag}, { #{value.chars.map{|i| i.ord; }.join(", ")} } };
static const uintptr_t* wombat_primordial_#{c_ify(name)} = (&(wombat_raw_primordial_#{c_ify(name)}.tag));
EOF
  end
  
  wombat_ocaml(<<EOF);
let wombat_primordial_#{c_ify(name)} = Wombat_Blob;;
let wombatx_primordial_#{c_ify(name)} = Wombatx_Blob;;
EOF
end

