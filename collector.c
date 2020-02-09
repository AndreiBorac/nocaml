/***
 * collector.c
 * copyright (c) 2020 by Andrei Borac
 ***/

#include <stdbool.h>
#include <inttypes.h>
#ifdef COLLECTOR_INFO
#include <stdio.h>
#endif

#define COLLECTOR_PTRDIFF(x, y) ((uintptr_t)((x) - (y)))

static inline uintptr_t collector_popcount(uintptr_t x)
{
#ifdef COLLECTOR_USE_BUILTIN_POPCOUNT
  return ((uintptr_t)(__builtin_popcountl(x)));
#else
  // ruby -e 'p (0...256).map{|i| p = 0; while (i != 0) do; p += i & 1; i >>= 1; end; p; }'
  static uint8_t bytepop[256] = {
    0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
  };
  uintptr_t o = 0;
  while (x) {
    o += bytepop[(x & 0xFF)];
    x >>= 8;
  }
  return o;
#endif
}

static void collector_heapify(uintptr_t* arr, uintptr_t len, uintptr_t i)
{
  uintptr_t largest = i;
  uintptr_t l = ((i << 1) + 1);
  uintptr_t r = ((i << 1) + 2);
  
  if (l < len) {
    if (arr[l] > arr[largest]) {
      largest = l;
    }
    
    if (r < len) {
      if (arr[r] > arr[largest]) {
        largest = r;
      }
    }
  }
  
  if (largest != i) {
    uintptr_t t = arr[i];
    arr[i] = arr[largest];
    arr[largest] = t;
    
    collector_heapify(arr, len, largest);
  }
}

static void collector_heapsort(uintptr_t* arr, uintptr_t len)
{
  if (len < 2) {
    return;
  }
  
  for (intptr_t i = ((intptr_t)((len >> 1) - 1)); i >= 0; i--) {
    collector_heapify(arr, len, ((uintptr_t)(i)));
  }
  
  for (intptr_t i = ((intptr_t)(len - 1)); i >= 0; i--) {
    uintptr_t t = arr[0];
    arr[0] = arr[i];
    arr[i] = t;
    
    collector_heapify(arr, ((uintptr_t)(i)), 0);
  }
}

typedef struct {
  WombatExternal wombat;
  
  struct {
    uintptr_t* bas;
    uintptr_t* ptr;
    uintptr_t* end;
  } heap;
  
  struct {
    uintptr_t* bas;
  } bmap;
  
  struct {
    uintptr_t* bas;
  } cmap;
  
  struct {
    uintptr_t* bas;
    uintptr_t* end;
  } smap;
  
  struct {
    uintptr_t invocations;
    
    uintptr_t collected;
    uintptr_t surviving;
  } stat;
  
  struct {
    void* fun;
    uintptr_t* ctx;
    uintptr_t* args[6];
    uintptr_t* sp_in;
    uintptr_t* sp_out;
  } call;
} CollectorExternal;

// retrieves the idxth bit in the bitmap.
static inline bool collector_gc_bitmap_get(CollectorExternal* ce, uintptr_t idx)
{
  return ((ce->bmap.bas[(idx >> COLLECTOR_SHAM)] & (1UL << (idx & ((1UL << COLLECTOR_SHAM) - 1)))) != 0);
}

// sets the idxth bit in the bitmap. the counter map is not updated.
static inline void collector_gc_bitmap_set(CollectorExternal* ce, uintptr_t idx)
{
  ce->bmap.bas[(idx >> COLLECTOR_SHAM)] |= (1UL << (idx & ((1UL << COLLECTOR_SHAM) - 1)));
}

// if len is greater than zero, sets the idxth bit in the bitmap, as
// well as the len-1 subsequent bits. also updates the counter map.
static inline void collector_gc_bitmap_smear(CollectorExternal* ce, uintptr_t idx, uintptr_t len)
{
  uintptr_t lim = (idx + len);
  
  uintptr_t idx_page = (idx >> COLLECTOR_SHAM); uintptr_t idx_resd = (idx & ((1UL << COLLECTOR_SHAM) - 1));
  uintptr_t lim_page = (lim >> COLLECTOR_SHAM); uintptr_t lim_resd = (lim & ((1UL << COLLECTOR_SHAM) - 1));
  
  if (idx_page == lim_page) { // single page case
    ce->bmap.bas[idx_page] |= (((1UL << lim_resd) - 1UL) - ((1UL << idx_resd) - 1UL));
    ce->cmap.bas[idx_page] += (lim_resd - idx_resd);
  } else { // multiple pages case
    uintptr_t idx_next = (((idx + ((1UL << COLLECTOR_SHAM) - 1)) >> COLLECTOR_SHAM) << COLLECTOR_SHAM);
    uintptr_t lim_page = (lim >> COLLECTOR_SHAM);
    uintptr_t lim_prev = (lim_page << COLLECTOR_SHAM);
    
    // smear [idx, idx_next*)
    {
      ce->bmap.bas[idx_page] |= (((uintptr_t)(-1)) << idx_resd);
      ce->cmap.bas[idx_page] += ((1UL << COLLECTOR_SHAM) - idx_resd);
    }
    
    // smear [idx_next*, lim_prev*)
    {
      for (uintptr_t i = idx_next; i < lim_prev; i += (1UL << COLLECTOR_SHAM)) {
        uintptr_t i_page = (i >> COLLECTOR_SHAM);
        ce->bmap.bas[i_page] = ((uintptr_t)(-1));
        ce->cmap.bas[i_page] += (1UL << COLLECTOR_SHAM);
      }
    }
    
    // smear [lim_prev*, lim)
    {
      ce->bmap.bas[lim_page] |= ((1UL << lim_resd) - 1);
      ce->cmap.bas[lim_page] += lim_resd;
    }
  }
}

static void collector_gc_with_stack(CollectorExternal* ce, uintptr_t* sp_lo, uintptr_t* sp_hi)
{
  uintptr_t* ptr = ce->heap.ptr;
  uintptr_t* end = ce->heap.end;
  
#ifdef COLLECTOR_INFO
  fprintf(stderr, "begin %lu %lu\n", ((uintptr_t)(ptr)), ((uintptr_t)(end)));
#endif
  
  ce->stat.invocations++;
  ce->stat.collected += COLLECTOR_PTRDIFF(end, ptr);
  
  uintptr_t map_siz = ((COLLECTOR_PTRDIFF(end, ptr) + ((8 * sizeof(uintptr_t)) - 1)) / (8 * sizeof(uintptr_t)));
  
  // clear the bitmap and ctrmap
  {
    for (uintptr_t i = 0; i < map_siz; i++) {
      ce->bmap.bas[i] = 0;
    }
    
    for (uintptr_t i = 0; i < map_siz; i++) {
      ce->cmap.bas[i] = 0;
    }
  }
  
  // copy the stack
  uintptr_t* smap_fin = ce->smap.bas;
  {
#ifdef COLLECTOR_INFO
    fprintf(stderr, "scanning stack from %lu to %lu [%lu]\n", ((uintptr_t)(sp_lo)), ((uintptr_t)(sp_hi)), COLLECTOR_PTRDIFF(sp_hi, sp_lo));
#endif
    
    for (uintptr_t* sp = sp_lo; sp < sp_hi; sp++) {
      uintptr_t* pv = ((uintptr_t*)(*sp));
      
      if ((ptr <= pv) && (pv < end)) {
        if (smap_fin == ce->smap.end) {
          wombat_panic((&(ce->wombat)), ((uintptr_t*)(__LINE__)));
        }
        
#ifdef COLLECTOR_INFO
        fprintf(stderr, "got pv=%lu\n", ((uintptr_t)(pv)));
#endif
        
        *(smap_fin++) = ((uintptr_t)(pv));
      }
    }
  }
  
  // sort the stack
  {
    collector_heapsort(ce->smap.bas, COLLECTOR_PTRDIFF(smap_fin, ce->smap.bas));
  }
  
#define collector_stackize \
  bool stackize_marked = collector_gc_bitmap_get(ce, COLLECTOR_PTRDIFF(at, ptr)); \
  while ((smap_pos < smap_fin) && (smap_pos[0] < ((uintptr_t)(at)))) { smap_pos++; } \
  while ((smap_pos < smap_fin) && (smap_pos[0] < ((uintptr_t)(at + len)))) { stackize_marked = true; smap_pos++; }
  
  // unified marking pass
  {
    uintptr_t bit = (1UL << ((8 * sizeof(uintptr_t)) - 1));
    
    uintptr_t* smap_pos = ce->smap.bas;
    
    for (uintptr_t* at = ptr; at < end; /* void */) {
#ifdef COLLECTOR_INFO
      fprintf(stderr, "passant %lu [%lu %lu %lu %lu]\n", ((uintptr_t)(at)), at[0], at[1], at[2], at[3]);
#endif
      
      uintptr_t tag = at[0];
      
      if ((tag & bit) != 0) { // blob case
        uintptr_t len = ((((tag - bit) + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t)) + 1);
        
        collector_stackize;
        
        if (stackize_marked) {
          collector_gc_bitmap_smear(ce, COLLECTOR_PTRDIFF(at, ptr), len);
          
#ifdef COLLECTOR_INFO
          fprintf(stderr, "found %lu %lu\n", ((uintptr_t)(at)), len);
#endif
        }
        
        at += len;
      } else { // non-blob case
        uintptr_t len = wombat_constructor_sizes[tag];
        
        collector_stackize;
        
        if (stackize_marked) {
          collector_gc_bitmap_smear(ce, COLLECTOR_PTRDIFF(at, ptr), len);
          
#ifdef COLLECTOR_INFO
          fprintf(stderr, "found %lu %lu\n", ((uintptr_t)(at)), len);
#endif
          
          if (tag <= WOMBAT_LAST_NON_NATIVE_CONSTRUCTOR) { // non-native case
            for (uintptr_t i = 1; i < len; i++) { // loop over fields
              uintptr_t* pv = ((uintptr_t*)(at[i]));
              
              if ((ptr <= pv) && (pv < end)) {
#ifndef COLLECTOR_UNSAFE_OPTIMIZATIONS
                if (pv <= at) { // check for reverse or looping pointers
                  wombat_panic((&(ce->wombat)), pv);
                }
#endif
                
                collector_gc_bitmap_set(ce, COLLECTOR_PTRDIFF(pv, ptr));
              }
            }
          }
        }
        
        at += len;
      }
    }
  }
  
  uintptr_t oal = 0;
  
  for (uintptr_t i = 0; i < map_siz; i++) {
    oal += ce->cmap.bas[i];
    ce->cmap.bas[i] = oal;
  }
  
  ce->stat.surviving += oal;
  
#ifdef COLLECTOR_INFO
  fprintf(stderr, "determined %lu oal from %lu used\n", oal, COLLECTOR_PTRDIFF(ce->heap.end, ptr));
#endif
  
#define collector_xlat(what_pv) ({                                      \
      uintptr_t* xlat_pv = (what_pv);                                   \
      uintptr_t xlat_idx = COLLECTOR_PTRDIFF(xlat_pv, ptr);             \
      uintptr_t xlat_idx_page = (xlat_idx >> COLLECTOR_SHAM); uintptr_t xlat_idx_resd = (xlat_idx & ((1UL << COLLECTOR_SHAM) - 1)); \
      uintptr_t xlat_pop = 0;                                           \
      if (xlat_idx_page > 0) {                                          \
        xlat_pop = ce->cmap.bas[(xlat_idx_page - 1)];                   \
      }                                                                 \
      uintptr_t xlat_lowbits = (ce->bmap.bas[xlat_idx_page] & ((1UL << xlat_idx_resd) - 1)); \
      xlat_pop += collector_popcount(xlat_lowbits);                     \
      /* fprintf(stderr, "xlat %lu %lu\n", ((uintptr_t)(xlat_pv)), ((uintptr_t)(ce->heap.end - oal + xlat_pop))); */ \
      (ce->heap.end - oal + xlat_pop);                                  \
    })
  
  // translate pointers on the stack
  {
#ifdef COLLECTOR_INFO
    fprintf(stderr, "xlat stack\n");
#endif
    
    for (uintptr_t* sp = sp_lo; sp < sp_hi; sp++) {
      uintptr_t* pv = ((uintptr_t*)(*sp));
      
      if ((ptr <= pv) && (pv < end)) {
        *sp = ((uintptr_t)(collector_xlat(pv)));
      }
    }
  }
  
  // translate pointers in marked objects
  {
    uintptr_t bit = (1UL << ((8 * sizeof(uintptr_t)) - 1));
    
    for (uintptr_t* at = ptr; at < end; /* void */) {
#ifdef COLLECTOR_INFO
      fprintf(stderr, "xlat from %lu\n", ((uintptr_t)(at)));
#endif
      
      uintptr_t tag = at[0];
      
      if ((tag & bit) != 0) { // blob case
        uintptr_t len = (((tag - bit) + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t));
        
        at += (1 + len);
      } else { // non-blob case
        uintptr_t len = wombat_constructor_sizes[tag];
        
        if (tag <= WOMBAT_LAST_NON_NATIVE_CONSTRUCTOR) { // non-native case
          if (collector_gc_bitmap_get(ce, COLLECTOR_PTRDIFF(at, ptr))) { // marked case
            for (uintptr_t i = 1; i < len; i++) { // loop over fields
              uintptr_t* pv = ((uintptr_t*)(at[i]));
              
              if ((ptr <= pv) && (pv < end)) {
                at[i] = ((uintptr_t)(collector_xlat(pv)));
              }
            }
          }
        }
        
        at += len;
      }
    }
  }
  
  // forward-copy objects, filling gaps
  {
    uintptr_t bit = (1UL << ((8 * sizeof(uintptr_t)) - 1));
    
    for (uintptr_t *dst = ptr, *src = ptr; src < end; /* void */) {
      uintptr_t tag = src[0];
      
      if ((tag & bit) != 0) { // blob case
        uintptr_t len = ((((tag - bit) + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t)) + 1);
        
        if (collector_gc_bitmap_get(ce, COLLECTOR_PTRDIFF(src, ptr))) { // marked case
          for (uintptr_t i = 0; i < len; i++) { // loop over fields
            dst[i] = src[i];
          }
          
          dst += len;
        }
        
        src += len;
      } else { // non-blob case
        uintptr_t len = wombat_constructor_sizes[tag];
        
        if (collector_gc_bitmap_get(ce, COLLECTOR_PTRDIFF(src, ptr))) { // marked case
          for (uintptr_t i = 0; i < len; i++) { // loop over fields
            dst[i] = src[i];
          }
          
          dst += len;
        }
        
        src += len;
      }
    }
  }

  // backward-copy objects to their final positions
  {
    for (uintptr_t i = 0; i < oal; i++) {
      end[-i-1] = ptr[oal-i-1];
    }
  }
  
  // unbump heap pointer
  ce->heap.ptr = (ce->heap.end - oal);
  
#ifdef COLLECTOR_INFO
  fprintf(stderr, "new heap %lu to %lu\n", ((uintptr_t)(ce->heap.ptr)), ((uintptr_t)(ce->heap.end)));
#endif
  
#ifdef COLLECTOR_INFO
  // loop through heap printing new addresses
  {
    uintptr_t* ptr = ce->heap.ptr;
    
    uintptr_t bit = (1UL << ((8 * sizeof(uintptr_t)) - 1));
    
    for (uintptr_t* at = ptr; at < end; /* void */) {
#ifdef COLLECTOR_INFO
      fprintf(stderr, "destination %lu\n", ((uintptr_t)(at)));
#endif
      
      uintptr_t tag = at[0];
      
      if ((tag & bit) != 0) { // blob case
        uintptr_t len = (((tag - bit) + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t));
        
        at += (1 + len);
      } else { // non-blob case
        uintptr_t len = wombat_constructor_sizes[tag];
        
        at += len;
      }
    }
  }
#endif
}

void collector_gc_firewall_exterior(CollectorExternal* ce)
{
  if (ce->call.sp_in == NULL) {
    // a panic here means we ran out of space while not executing any
    // Nocaml code. it is not possible to GC in this case.
    wombat_panic((&(ce->wombat)), ((uintptr_t*)(__LINE__)));
    while (1);
  }
  
  collector_gc_with_stack(ce, ce->call.sp_out, ce->call.sp_in);
}

void collector_gc_firewall(CollectorExternal* ce, uintptr_t** sp_out);

#ifdef COLLECTOR_ARCH_X86_64_SYSV

asm(".text\n"
    ".global collector_gc_firewall\n"
    "collector_gc_firewall:\n"
    "pushq %rbx\n"
    "pushq %rbp\n"
    "pushq %r12\n"
    "pushq %r13\n"
    "pushq %r14\n"
    "pushq %r15\n"
    "pushq %r15\n" // for alignment
    "movq %rsp, (%rsi)\n"
    "callq collector_gc_firewall_exterior\n"
    "popq %r15\n"
    "popq %r15\n"
    "popq %r14\n"
    "popq %r13\n"
    "popq %r12\n"
    "popq %rbp\n"
    "popq %rbx\n"
    "retq\n");

#endif

#ifdef COLLECTOR_ARCH_MIPSEL_O32_ABICALLS

asm(".text\n"
    ".set noat\n"
    ".set noreorder\n"
    ".globl collector_gc_firewall\n"
    "collector_gc_firewall:\n"
    // prologue
    ".ent collector_gc_firewall\n"
    ".frame $29, 64, $31\n"
    ".cpload $25\n"
    ".set reorder\n"
    "addiu $sp, $sp, -64\n" // 4*(4[a0-a3]+8[s0-s7]+1[fp]+1[ra]+1[gp]) = 60 % 8 = 4
    ".cprestore 60\n"
    // save preserved registers
    "sw $s0, 16($sp)\n"
    "sw $s1, 20($sp)\n"
    "sw $s2, 24($sp)\n"
    "sw $s3, 28($sp)\n"
    "sw $s4, 32($sp)\n"
    "sw $s5, 36($sp)\n"
    "sw $s6, 40($sp)\n"
    "sw $s7, 44($sp)\n"
    "sw $fp, 48($sp)\n"
    "sw $ra, 52($sp)\n"
    // copy stack pointer into location pointed to by second argument
    "sw $sp, ($a1)\n"
    // call into exterior of firewall
    "jal collector_gc_firewall_exterior\n"
    // no branch delay slot in the current assembler mode (!)
    // restore preserved registers
    "lw $s0, 16($sp)\n"
    "lw $s1, 20($sp)\n"
    "lw $s2, 24($sp)\n"
    "lw $s3, 28($sp)\n"
    "lw $s4, 32($sp)\n"
    "lw $s5, 36($sp)\n"
    "lw $s6, 40($sp)\n"
    "lw $s7, 44($sp)\n"
    "lw $fp, 48($sp)\n"
    "lw $ra, 52($sp)\n"
    // epilogue
    "addiu $sp, $sp, 64\n"
    "jr $ra\n"
    ".end collector_gc_firewall\n");

#endif

static uintptr_t* collector_malloc_failed(CollectorExternal* ce, uintptr_t len)
{
  ce->heap.ptr += len;
  
  collector_gc_firewall(ce, (&(ce->call.sp_out)));
  
  uintptr_t* out = (ce->heap.ptr -= len);
  
  if (out < ce->heap.bas) {
    wombat_panic((&(ce->wombat)), ((uintptr_t*)(__LINE__)));
    while (1);
  } else {
#ifdef COLLECTOR_INFO
    fprintf(stderr, "allocate %lu [long path]\n", ((uintptr_t)(out)));
#endif
  }
  
  return out;
}

static inline uintptr_t* wombat_malloc(WombatExternal* wombat_external, uintptr_t len)
{
  CollectorExternal* ce = ((CollectorExternal*)(wombat_external));
  
  uintptr_t* out = (ce->heap.ptr -= len);
  
  if (
#ifdef COLLECTOR_ALWAYS_GC
      true
#else
      out < ce->heap.bas
#endif
      ) {
    return collector_malloc_failed(ce, len);
  } else {
#ifdef COLLECTOR_INFO
    fprintf(stderr, "allocate %lu\n", ((uintptr_t)(out)));
#endif
  }
  
  return out;
}

static uintptr_t* collector_gc_single_root(CollectorExternal* ce, uintptr_t* object)
{
  uintptr_t virtual_stack[2];
  
  virtual_stack[0] = ((uintptr_t)(object));
  
  collector_gc_with_stack(ce, (&(virtual_stack[0])), (&(virtual_stack[1])));
  
  return ((uintptr_t*)(virtual_stack[0]));
}

uintptr_t* collector_invoke_firewall_interior(CollectorExternal* ce)
{
  return (((uintptr_t* (*)(WombatExternal* wombat_external, uintptr_t* ctx, uintptr_t* arg0, uintptr_t* arg1, uintptr_t* arg2, uintptr_t* arg3, uintptr_t* arg4, uintptr_t* arg5))(ce->call.fun))((&(ce->wombat)), ce->call.ctx, ce->call.args[0], ce->call.args[1], ce->call.args[2], ce->call.args[3], ce->call.args[4], ce->call.args[5]));
}

uintptr_t* collector_invoke_firewall(CollectorExternal* ce, uintptr_t** sp_in);

#ifdef COLLECTOR_ARCH_X86_64_SYSV

asm(".text\n"
    ".global collector_invoke_firewall\n"
    "collector_invoke_firewall:\n"
    "pushq %rbx\n"
    "pushq %rbp\n"
    "pushq %r12\n"
    "pushq %r13\n"
    "pushq %r14\n"
    "pushq %r15\n"
    "pushq %r15\n" // for alignment
    "xorq %rbx, %rbx\n"
    "xorq %rbp, %rbp\n"
    "xorq %r12, %r12\n"
    "xorq %r13, %r13\n"
    "xorq %r14, %r14\n"
    "xorq %r15, %r15\n"
    "movq %rsp, (%rsi)\n"
    "callq collector_invoke_firewall_interior\n"
    "popq %r15\n"
    "popq %r15\n"
    "popq %r14\n"
    "popq %r13\n"
    "popq %r12\n"
    "popq %rbp\n"
    "popq %rbx\n"
    "retq\n");

#endif

#ifdef COLLECTOR_ARCH_MIPSEL_O32_ABICALLS

asm(".text\n"
    ".set noat\n"
    ".set noreorder\n"
    ".globl collector_invoke_firewall\n"
    "collector_invoke_firewall:\n"
    // prologue
    ".ent collector_invoke_firewall\n"
    ".frame $29, 64, $31\n"
    ".cpload $25\n"
    ".set reorder\n"
    "addiu $sp, $sp, -64\n" // 4*(4[a0-a3]+8[s0-s7]+1[fp]+1[ra]+1[gp]) = 60 % 8 = 4
    ".cprestore 60\n"
    // save preserved registers
    "sw $s0, 16($sp)\n"
    "sw $s1, 20($sp)\n"
    "sw $s2, 24($sp)\n"
    "sw $s3, 28($sp)\n"
    "sw $s4, 32($sp)\n"
    "sw $s5, 36($sp)\n"
    "sw $s6, 40($sp)\n"
    "sw $s7, 44($sp)\n"
    "sw $fp, 48($sp)\n"
    "sw $ra, 52($sp)\n"
    "and $s0, $0, $0\n"
    "and $s1, $0, $0\n"
    "and $s2, $0, $0\n"
    "and $s3, $0, $0\n"
    "and $s4, $0, $0\n"
    "and $s5, $0, $0\n"
    "and $s6, $0, $0\n"
    "and $s7, $0, $0\n"
    "and $fp, $0, $0\n"
    // copy stack pointer into location pointed to by second argument (delay slot!)
    "sw $sp, ($a1)\n"
    // call into interior of the invoke firewall
    "jal collector_invoke_firewall_interior\n"
    // no branch delay slot in the current assembler mode (!)
    // restore preserved registers
    "lw $s0, 16($sp)\n"
    "lw $s1, 20($sp)\n"
    "lw $s2, 24($sp)\n"
    "lw $s3, 28($sp)\n"
    "lw $s4, 32($sp)\n"
    "lw $s5, 36($sp)\n"
    "lw $s6, 40($sp)\n"
    "lw $s7, 44($sp)\n"
    "lw $fp, 48($sp)\n"
    "lw $ra, 52($sp)\n"
    // epilogue
    "addiu $sp, $sp, 64\n"
    "jr $ra\n"
    ".end collector_invoke_firewall\n");

#endif

static uintptr_t* collector_invoke(CollectorExternal* ce, void* fun, uintptr_t* ctx, uintptr_t* arg0, uintptr_t* arg1, uintptr_t* arg2, uintptr_t* arg3, uintptr_t* arg4, uintptr_t* arg5)
{
  ce->call.fun = fun;
  ce->call.ctx = ctx;
  ce->call.args[0] = arg0;
  ce->call.args[1] = arg1;
  ce->call.args[2] = arg2;
  ce->call.args[3] = arg3;
  ce->call.args[4] = arg4;
  ce->call.args[5] = arg5;
  
  uintptr_t* retv = collector_invoke_firewall(ce, (&(ce->call.sp_in)));
  
  ce->call.sp_in = NULL;
  
  return collector_gc_single_root(ce, retv);
}
