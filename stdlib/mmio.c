/* copyright (c) 2020 by Andrei Borac */

#define MMIO_CHECK_TOP(x) assure(((x) == (((CollectorExternal*)(wombat_external))->heap.ptr)))

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_mmio_minus_rd(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  STDLIB_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  cellb[1] = (*((uintptr_t volatile*)(cella[1])));
  return cellb;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_mmio_minus_wr(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  (*((uintptr_t volatile*)(cella[1]))) = cellb[1];
  return ((uintptr_t*)(wombat_primordial_unit));
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_mmio_minus_wr_minus_16(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  (*((uint16_t volatile*)(cella[1]))) = ((uint16_t)(cellb[1]));
  return ((uintptr_t*)(wombat_primordial_unit));
}
