/* copyright (c) 2020 by Andrei Borac */

#define CONTRAIL_CHECK_TOP(x) assure(((x) == (((CollectorExternal*)(wombat_external))->heap.ptr)))

#define CONTRAIL_INIT_0 0xFFFFFFFF
#define CONTRAIL_INIT_1 CONTRAIL_INIT_0, CONTRAIL_INIT_0
#define CONTRAIL_INIT_2 CONTRAIL_INIT_1, CONTRAIL_INIT_1
#define CONTRAIL_INIT_3 CONTRAIL_INIT_2, CONTRAIL_INIT_2
#define CONTRAIL_INIT_4 CONTRAIL_INIT_3, CONTRAIL_INIT_3
#define CONTRAIL_INIT_5 CONTRAIL_INIT_4, CONTRAIL_INIT_4
#define CONTRAIL_INIT_6 CONTRAIL_INIT_5, CONTRAIL_INIT_5
#define CONTRAIL_INIT_7 CONTRAIL_INIT_6, CONTRAIL_INIT_6
#define CONTRAIL_INIT_8 CONTRAIL_INIT_7, CONTRAIL_INIT_7
#define CONTRAIL_INIT_9 CONTRAIL_INIT_8, CONTRAIL_INIT_8
#define CONTRAIL_INIT_10 CONTRAIL_INIT_9, CONTRAIL_INIT_9
#define CONTRAIL_INIT_11 CONTRAIL_INIT_10, CONTRAIL_INIT_10
#define CONTRAIL_INIT_12 CONTRAIL_INIT_11, CONTRAIL_INIT_11
#define CONTRAIL_INIT_13 CONTRAIL_INIT_12, CONTRAIL_INIT_12

__attribute__((used,aligned(1024)))
static const uintptr_t contrail_buffer[65536/2/sizeof(uintptr_t)] = { CONTRAIL_INIT_13 };

static uintptr_t contrail_offset;

WOMBAT_BUILTIN static uintptr_t* wombat_builtin_contrail_minus_sbrk(WombatExternal* wombat_external WOMBAT_UNUSED, uintptr_t* wombat_context WOMBAT_UNUSED, uintptr_t* cella, uintptr_t* cellb)
{
  CONTRAIL_CHECK_TOP(cellb);
  assure((cella[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  assure((cellb[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer));
  uintptr_t len = cella[1];
  uintptr_t amt = (1 + ((len + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t)));
  uintptr_t retv;
  if ((contrail_offset + amt) <= (sizeof(contrail_buffer) / sizeof(contrail_buffer[0]))) {
    retv = ((uintptr_t)(contrail_buffer + contrail_offset));
    contrail_offset += amt;
  } else {
    retv = 0;
    contrail_offset = (sizeof(contrail_buffer) / sizeof(contrail_buffer[0]));
  }
  cellb[1] = retv;
  return cellb;
}
