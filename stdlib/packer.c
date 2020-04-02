/* copyright (c) 2020 by Andrei Borac */

#define PACKER_CHECK_TOP(x) assure(((x) == (((CollectorExternal*)(wombat_external))->heap.ptr)))

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_8(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 1);
  *((uint8_t*)(&(cellb[1]))) = ((uint8_t)(cella[1]));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_16(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 2);
  *((uint16_t*)(&(cellb[1]))) = ((uint16_t)(cella[1]));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_32(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 4);
  *((uint32_t*)(&(cellb[1]))) = ((uint32_t)(cella[1]));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_16_minus_el(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 2);
  ((uint8_t*)(&(cellb[1])))[0] = ((uint8_t)(cella[1]      ));
  ((uint8_t*)(&(cellb[1])))[1] = ((uint8_t)(cella[1] >>  8));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_32_minus_el(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 4);
  ((uint8_t*)(&(cellb[1])))[0] = ((uint8_t)(cella[1]      ));
  ((uint8_t*)(&(cellb[1])))[1] = ((uint8_t)(cella[1] >>  8));
  ((uint8_t*)(&(cellb[1])))[2] = ((uint8_t)(cella[1] >> 16));
  ((uint8_t*)(&(cellb[1])))[3] = ((uint8_t)(cella[1] >> 24));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_16_minus_be(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 2);
  ((uint8_t*)(&(cellb[1])))[0] = ((uint8_t)(cella[1] >>  8));
  ((uint8_t*)(&(cellb[1])))[1] = ((uint8_t)(cella[1]      ));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_pack_minus_32_minus_be(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cellb[0] & bit) != 0);
  uintptr_t len = (cellb[0] - bit);
  assure(len >= 4);
  ((uint8_t*)(&(cellb[1])))[0] = ((uint8_t)(cella[1] >> 24));
  ((uint8_t*)(&(cellb[1])))[1] = ((uint8_t)(cella[1] >> 16));
  ((uint8_t*)(&(cellb[1])))[2] = ((uint8_t)(cella[1] >>  8));
  ((uint8_t*)(&(cellb[1])))[3] = ((uint8_t)(cella[1]      ));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_unpack_minus_8(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cella[0] & bit) != 0);
  uintptr_t len = (cella[0] - bit);
  assure(len >= 1);
  cellb[1] = (*((uint8_t*)(&(cella[1]))));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_unpack_minus_16(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cella[0] & bit) != 0);
  uintptr_t len = (cella[0] - bit);
  assure(len >= 2);
  cellb[1] = (*((uint16_t*)(&(cella[1]))));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_packer_minus_unpack_minus_32(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  PACKER_CHECK_TOP(cellb);
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cella[0] & bit) != 0);
  uintptr_t len = (cella[0] - bit);
  assure(len >= 4);
  cellb[1] = (*((uint32_t*)(&(cella[1]))));
  return cellb;
}
