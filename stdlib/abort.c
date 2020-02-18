/* copyright (c) 2020 by Andrei Borac */

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_abort(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED)
{
#ifdef DRIVER_ABORT_FUNC
  DRIVER_ABORT_FUNC();
#endif
  while (true);
  return NULL;
}
