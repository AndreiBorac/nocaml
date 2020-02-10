/* copyright (c) 2020 by Andrei Borac */

#define STDLIB_CHECK_TOP(x) assure(((x) == (((CollectorExternal*)(wombat_external))->heap.ptr)))

WOMBAT_BUILTIN static uintptr_t wombat_measure(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_object) {
  assure(wombat_object[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  return wombat_object[1];
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_blob_minus_eq(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cella[0] & bit) != 0);
  assure((cellb[0] & bit) != 0);
  uintptr_t lena = (cella[0] - bit);
  uintptr_t lenb = (cellb[0] - bit);
  if (lena != lenb) {
    return ((uintptr_t*)(wombat_primordial_false));
  }
  return ((memcmp((&(cella[1])), (&(cellb[1])), lena) == 0) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_blob_minus_length(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  STDLIB_CHECK_TOP(cellb);
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cella[0] & bit) != 0);
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  cellb[1] = (cella[0] - bit);
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_blob_minus_copy_minus_range(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* dst, uintptr_t* off, uintptr_t* len, uintptr_t* src, uintptr_t* srcoff)
{
  //driver_fdprintf(2, "sus", "top tag: ", (((CollectorExternal*)(wombat_external))->heap.ptr)[0], "\n");
  STDLIB_CHECK_TOP(dst);
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure(((dst[0] & src[0]) & bit) != 0);
  uintptr_t dstlen = (dst[0] - bit);
  uintptr_t srclen = (src[0] - bit);
  uint8_t* dstptr = ((uint8_t*)(&(dst[1])));
  uint8_t* srcptr = ((uint8_t*)(&(src[1])));
  assure(off[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(len[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(srcoff[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  uintptr_t offval = off[1];
  uintptr_t lenval = len[1];
  uintptr_t srcoffval = srcoff[1];
  //driver_fdprintf(2, "sususususus", "dstlen=", dstlen, ", srclen=", srclen, ", offval=", offval, ", lenval=", lenval, ", srcoffval=", srcoffval, "\n");
  assure((offval + lenval) <= dstlen);
  assure((srcoffval + lenval) <= srclen);
  dstptr += offval;
  srcptr += srcoffval;
  for (; lenval > 0; dstptr++, srcptr++, lenval--) {
    *dstptr = *srcptr;
  }
  return dst;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_eq(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] == cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_lt(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] < cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_lte(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] <= cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
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

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_gte(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return ((cella[1] >= cellb[1]) ? ((uintptr_t*)(wombat_primordial_true)) : ((uintptr_t*)(wombat_primordial_false)));
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

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_min(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return (cella[1] < cellb[1] ? cella : cellb);
  } else {
    wombat_panic(wombat_external, NULL);
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_int_minus_max(WombatExternal* wombat_external, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  if ((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer) && (cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer)) {
    return (cella[1] > cellb[1] ? cella : cellb);
  } else {
    wombat_panic(wombat_external, NULL);
  }
}
