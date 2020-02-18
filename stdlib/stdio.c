/* copyright (c) 2020 by Andrei Borac */

#ifndef HOST_IS_LINUX
#error "stdio requires a linux host"
#endif

#define STDIO_CHECK_TOP(x, t) assure((((x)-(t)) == (((CollectorExternal*)(wombat_external))->heap.ptr)))

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_system_minus_blob_minus_address(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell_blob, uintptr_t* cell_offs, uintptr_t* cell_retv, uintptr_t* cell_float) {
  STDIO_CHECK_TOP(cell_float, 0);
  assure(cell_float[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  STDIO_CHECK_TOP(cell_retv, 2);
  assure(cell_retv[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  assure((cell_blob[0] & bit) != 0);
  uintptr_t offs = cell_offs[1];
  assure(offs < (cell_blob[0] - bit));
  cell_retv[1] = (((uintptr_t)(&(cell_blob[1]))) + offs);
  return cell_retv;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_system_minus_exit(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell_retv) {
  assure(cell_retv[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  sy6(cell_retv[1], 0, 0, 0, 0, 0, SYS_exit);
  while (1);
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_system_minus_read(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell_fd, uintptr_t* cell_addr, uintptr_t* cell_count, uintptr_t* cell_retv) {
  STDIO_CHECK_TOP(cell_retv, 0);
  assure(cell_fd[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_addr[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_count[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_retv[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  cell_retv[1] = sy6(cell_fd[1], cell_addr[1], cell_count[1], 0, 0, 0, SYS_read);
  return cell_retv;
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_system_minus_write(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell_fd, uintptr_t* cell_addr, uintptr_t* cell_count, uintptr_t* cell_retv) {
  STDIO_CHECK_TOP(cell_retv, 0);
  assure(cell_fd[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_addr[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_count[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  assure(cell_retv[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  cell_retv[1] = sy6(cell_fd[1], cell_addr[1], cell_count[1], 0, 0, 0, SYS_write);
  return cell_retv;
}
