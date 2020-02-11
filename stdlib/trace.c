/* copyright (c) 2020 by Andrei Borac */

#ifndef HOST_IS_LINUX

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_trace(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell) {
  return cell;
}

#else

static void trace_object(CollectorExternal* ce, uintptr_t* cell) {
  static char hexify[16] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
  uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
  uintptr_t tag = cell[0];
  if ((tag & bit) != 0) {
    uintptr_t len = (tag - bit);
    char hex[((len << 1) + 1)];
    for (uintptr_t i = 0; i < len; i++) {
      hex[((i << 1)    )] = hexify[(((((uint8_t*)(&(cell[1])))[i]) & 0xF0) >> 4)];
      hex[((i << 1) + 1)] = hexify[(((((uint8_t*)(&(cell[1])))[i]) & 0x0F)     )];
    }
    hex[(len << 1)] = 0;
    driver_fdprintf(2, "susss", "(blob[", len, "] ", hex, ")");
  } else {
    uintptr_t size = wombat_constructor_sizes[tag];
    
    driver_fdprintf(2, "sus", "(tag[", tag, "]");
    
    if (tag <= WOMBAT_LAST_NON_NATIVE_CONSTRUCTOR) {
      uintptr_t* ptr = ce->heap.ptr;
      uintptr_t* end = ce->heap.end;
      
      for (uintptr_t i = 1; i < size; i++) {
        uintptr_t* pv = ((uintptr_t*)(cell[i]));
        
        if ((ptr <= pv) && (pv < end)) {
          driver_fdprintf(2, "s", " ");
          trace_object(ce, pv);
        } else {
          driver_fdprintf(2, "su", " ", cell[i]);
        }
      }
    } else {
      for (uintptr_t i = 1; i < size; i++) {
        driver_fdprintf(2, "su", " ", cell[i]);
      }
    }
    
    driver_fdprintf(2, "s", ")");
  }
}

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_trace(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cell) {
  driver_fdprintf(2, "s", "trace: ");
  trace_object(((CollectorExternal*)(wombat_external)), cell);
  driver_fdprintf(2, "s", "\n");
  return cell;
}

#endif
