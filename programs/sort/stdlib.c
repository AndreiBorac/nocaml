/* copyright (c) 2020 by Andrei Borac */

#include <assert.h>

#define STDLIB_CHECK_TOP(x) assert((x == (((CollectorExternal*)(wombat_external))->heap.ptr)))

WOMBAT_BUILTIN static uintptr_t wombat_measure(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_object) {
  assert(wombat_object[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  return wombat_object[1];
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_blob_minus_length(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  STDLIB_CHECK_TOP(cellb);
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assert((cella[0] & bit) != 0);
  assert((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  cellb[1] = (cella[0] - bit);
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_blob_minus_copy_minus_range(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* dst, uintptr_t* off, uintptr_t* len, uintptr_t* src, uintptr_t* srcoff)
{
  STDLIB_CHECK_TOP(dst);
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assert(((dst[0] & src[0]) & bit) != 0);
  uintptr_t dstlen = (dst[0] - bit);
  uintptr_t srclen = (src[0] - bit);
  uint8_t* dstptr = ((uint8_t*)(&(dst[1])));
  uint8_t* srcptr = ((uint8_t*)(&(src[1])));
  assert(off[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assert(len[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assert(srcoff[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  uintptr_t offval = off[1];
  uintptr_t lenval = len[1];
  uintptr_t srcoffval = srcoff[1];
  assert((offval + lenval) <= dstlen);
  assert((srcoffval + lenval) <= srclen);
  dstptr += offval;
  srcptr += srcoffval;
  for (; lenval > 0; dstptr++, srcptr++, lenval--) {
    *dstptr = *srcptr;
  }
  return dst;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_lt(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] < cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_gt(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] > cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_add(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb, uintptr_t* cellc)
{
  STDLIB_CHECK_TOP(cellc);
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellc[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    cellc[1] = (cella[1] + cellb[1]);
    return cellc;
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_sub(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb, uintptr_t* cellc)
{
  STDLIB_CHECK_TOP(cellc);
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellc[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    cellc[1] = (cella[1] - cellb[1]);
    return cellc;
  } else {
    wombat_panic(wombat_external, NULL);
  }
}
