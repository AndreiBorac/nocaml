#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

IO.read("constants.txt").each_line{|line|
  name, valu, = line.split;
  stdlib_register_integer_primordial("int-#{name}", valu.to_i);
};

stdlib_register_integer_primordial("int-GPIO_ODR", 0x14);
stdlib_register_integer_primordial("int-RCC_AHBENR", 0x14);
stdlib_register_integer_primordial("int-GPIO_MODER", 0);
