#!/usr/bin/env false
# coding: binary
# frozen_string_literal: true
# copyright (c) 2020 by Andrei Borac

wombat_register_constructor("Random", 2);

wombat_ocaml(<<EOF);
type wombat_random =
| Wombat_Random of wombat_integer wombat_amo_queue * wombat_integer wombat_amo_queue
;;

let wombat_constructor_Random (jq : wombat_integer wombat_amo_queue) (kq : wombat_integer wombat_amo_queue) : wombat_random = failwith "oops";;

type wombatx_random =
| Wombatx_Random of wombatx_integer wombatx_amo_queue * wombatx_integer wombatx_amo_queue
;;

let wombatx_constructor_Random (args : ((wombatx_integer wombatx_amo_queue, wombatx_integer wombatx_amo_queue) wombatxvector2)) : wombatx_random = failwith "oops";;
EOF

$randoms = [];

"e3 75 09 04 2f 9c 5d e9 8d ee 0b 8a c1 4e e3 c7 5b 75 58 0d 17 e9 14 34 5b 81 b4 11 97 b4 1f 78 58 65 c1 1b b7 e1 c7 1b 09 7d 85 cf 20 ea 77 48 9f d9 74 11 62 dc 85 cc f9 a1 79 c2 44 66 c7 c6 4d cd 29 5b 3c 21 8b d0 e1 be 23 70 d1 f6 c7 f8 1d 52 e9 69 72 ef 7a 8b 08 35 8a 58 62 d0 01 08 7a fb d2 1f 74 52 3e 4d ec 9a 03 15 bf 1f d3 8b 63 2a c5 c0 81 72 54 21 80 f7 dd dd 70 60 58 4f 09 22 1c b9 eb 3e fb 7b e2 02 5f 8c ae 2a 80 66 2c 32 e2 de 64 67 40 f3 64 48 ee 9e 62 8e 5f f0 f3 a3 2d 6f f9 06 0d a7 fe 87 4f df 7f 4f 42 c8 6d 68 d1 b6 98 b7 46 d9 ee 0b 7a d0 99 d2 ae 14 9c 28 e1 ab 6e 70 a0 4a ec 58 02 60 37 46 42 30 c1 22 7b 07 bb ed 1f 0e 30 86 72 4a d2 09 83 8b 11 48 a7 1b 00 81 4c 6e 6d a2 9a 7c 6c 15 7a bf f2 e7 7f 19 45 c0 1e 94 61 89 0c d4 40 42 1c 04 e4 66 8e 66 49 20 12 19 6e 02 3b 60 3c dd c4 1e 41 84 a3 9f 97 1e 60 db 18 bd ee 90 ef 6d e8 46 18 35 92 6f 52 ab ff 6e 2c 96 b5 3c 8d 40 e6 2a 5d 9b c3 7a ba c6 94 1e b8 c4 96 e8 a6 ec e3 37 c2 94 5a ce 03 66 4e 1f e7 d9 95 3e 66 6f f2 da 72 c4 26 c5 82 33 5d 2e 0f 74 80 8f ba 90 12 5c 0a 47 1d 87 f0 d2 84 ee d3 97 18 b4 be 5d 27 73 28 c1 29 d0 8f ec f2 18 57 94 99 9a 51 82 34 74 56 33 3b 85 dd a6 23 b6 33 0f 37 5b 80 cc 53 07 a9 12 03 e7 50 44 be 81 4e 2d fd 05 e3 7e 1e c1 d3 f2 c7 b3 50 d9 4c 1c e1 4c 9e 2e 60 f9 4d 5f 0c b9 94 d8 3e ea 18 84".split.each_slice(8){|slice| $randoms << [ slice.join ].pack("H*").unpack("Q>")[0]; };

def mkexpected()
  q24 = $randoms.clone[0...24];
  q31 = $randoms.clone[24..-1];
  
  raise if (!(q31.length == 31));
  
  nextrand = ->(){
    a = q24.pop;
    b = q31.pop;
    
    s = a + b;
    
    q31.unshift(a);
    q24.unshift(s);
    
    return s;
  };
  
  a = nextrand.call;
  b = nextrand.call;
  c = nextrand.call;
  
  (1000-3).times{ nextrand.call; };
  
  d = nextrand.call;
  e = nextrand.call;
  f = nextrand.call;
  
  IO.write("random-expected.txt", [ a, b, c, d, e, f ].inspect);
  IO.write("random-expected-32.txt", [ a%(2**32), b%(2**32), c%(2**32), d%(2**32), e%(2**32), f%(2**32) ].inspect);
end

mkexpected;

[ 24, 31 ].each{|len|
  (0...len).each{|i|
    name = "list-int-random-#{len}-int-#{i}";
    random = $randoms.shift;
    raise if (random.nil?);
    wombat_register_primordial(name, <<EOF);
static const uintptr_t wombat_primordial_#{c_ify(name)}[2] = { WOMBAT_NATIVE_CONSTRUCTOR_Integer, ((uintptr_t)(UINT64_C(#{random}))) };
EOF
    name2 = "list-int-random-#{len}-list-#{i}";
    if (i == 0)
      wombat_register_primordial(name2, <<EOF);
static const uintptr_t wombat_primordial_#{c_ify(name2)}[3] = { WOMBAT_CONSTRUCTOR_ListCons, ((uintptr_t)(&(wombat_primordial_#{c_ify(name)}))), ((uintptr_t)(&(wombat_primordial_list_minus_fini))) };
EOF
    else
      nameP = "list-int-random-#{len}-list-#{i-1}";
      wombat_register_primordial(name2, <<EOF);
static const uintptr_t wombat_primordial_#{c_ify(name2)}[3] = { WOMBAT_CONSTRUCTOR_ListCons, ((uintptr_t)(&(wombat_primordial_#{c_ify(name)}))), ((uintptr_t)(&(wombat_primordial_#{c_ify(nameP)}))) };
EOF
    end
  };
  name = "list-int-random-#{len}";
  name2 = "list-int-random-#{len}-list-#{len-1}";
  wombat_register_primordial(name, <<EOF);
#define wombat_primordial_#{c_ify(name)} wombat_primordial_#{c_ify(name2)}
EOF
  wombat_ocaml(<<EOF);
let rec wombat_primordial_#{c_ify(name)} : wombat_integer wombat_list = failwith "oops";;
let rec wombatx_primordial_#{c_ify(name)} : wombatx_integer wombatx_list = failwith "oops";;
EOF
};
