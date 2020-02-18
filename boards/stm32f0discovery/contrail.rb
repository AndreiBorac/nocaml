#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_c_file("contrail.c");

wombat_register_builtin("contrail-sbrk", 2);

wombat_ocaml(<<EOF);
let wombat_builtin_contrail_minus_sbrk (a : wombat_integer) (b : wombat_integer) : wombat_integer = failwith "oops";;
let wombatx_builtin_contrail_minus_sbrk (args : (wombatx_integer, wombatx_integer) wombatxvector2) : wombatx_integer = failwith "oops";;
EOF

[ 16 ].each{|i|
  stdlib_register_integer_primordial("int-#{i}", i);
};

[ "ACR", "KEYR", "OPTKEYR", "SR", "CR", "AR", nil, "OBR", "WRPR", ].each_with_index{|n, i|
  if (n.nil?.!)
    stdlib_register_integer_primordial("int-FLASH_#{n}", i*4);
  end
};

stdlib_register_integer_primordial("int-FLASH_KEY1",    0x45670123);
stdlib_register_integer_primordial("int-FLASH_KEY2",    0xCDEF89AB);
stdlib_register_integer_primordial("int-FLASH_SR_BUSY", 0x00000001);
stdlib_register_integer_primordial("int-FLASH_CR_LOCK", (1 << 7));
