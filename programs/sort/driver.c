/* copyright (c) 2020 by Andrei Borac */

#define WOMBAT_UNSAFE_OPTIMIZATIONS
#include "wombat.c"
#define COLLECTOR_UNSAFE_OPTIMIZATIONS
//#define COLLECTOR_INFO
#include "collector.c"

#include "stdlib.c"

#include <stdint.h>
#include <inttypes.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <sys/mman.h>

#define UNUSED __attribute__((unused))
#define NOINLINE __attribute__((noinline))

__attribute__((noinline,noreturn)) static void wombat_panic(WombatExternal* wombat_external UNUSED, uintptr_t* bad) {
  fprintf(stderr, "wombat_panic: %" PRIuPTR "\n", ((uintptr_t)(bad)));
  while (1);
}

#define NELM (1536*1024*1024/8)
static uintptr_t memory[NELM];
static uintptr_t bitmap[((NELM+((8*sizeof(uintptr_t))-1))/(8*sizeof(uintptr_t)))];
static uintptr_t ctrmap[(sizeof(bitmap)/sizeof(uintptr_t))];
#define STKMAPLEN 32768
static uintptr_t stkmap[STKMAPLEN];

int main(int argc UNUSED, char *const *const argv UNUSED)
{
#ifdef DRIVER_USE_MMAP
  uintptr_t sz_memory = sizeof(memory);
  uintptr_t sz_bitmap = sizeof(bitmap);
  uintptr_t sz_ctrmap = sizeof(ctrmap);
  uintptr_t sz_stkmap = sizeof(stkmap);
  
  uintptr_t* memory = mmap(NULL, sz_memory, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), -1, 0);
  uintptr_t* bitmap = mmap(NULL, sz_bitmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), -1, 0);
  uintptr_t* ctrmap = mmap(NULL, sz_ctrmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), -1, 0);
  uintptr_t* stkmap = mmap(NULL, sz_stkmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), -1, 0);
#endif
  
  fprintf(stderr, "heap.bas=%" PRIuPTR ", heap.end=%" PRIuPTR "\n", ((uintptr_t)(memory)), ((uintptr_t)(&(memory[NELM]))));
  
  double used = 1000000.0;

#ifndef NTRIALS
#define NTRIALS 100
#endif
#ifndef QSELMS
#define QSELMS 1000
#endif
#define N 1
  for (uintptr_t trial = 0; trial < NTRIALS; trial++) {
    CollectorExternal external;
    memset((&external), 0, sizeof(external));
    external.heap.bas = memory;
    external.heap.end = memory + NELM;
    external.heap.ptr = external.heap.end;
    external.bmap.bas = bitmap;
    external.cmap.bas = ctrmap;
    external.smap.bas = stkmap;
    external.smap.end = stkmap + STKMAPLEN;
    
    uintptr_t* rest = ((uintptr_t*)(wombat_primordial_list_minus_fini));
    
    for (uintptr_t i = 0; i < QSELMS; i++) {
      uintptr_t v = ((uintptr_t)(rand()));
      rest = wombat_constructor_3(&(external.wombat), WOMBAT_CONSTRUCTOR_ListCons, wombat_constructor_2(&(external.wombat), WOMBAT_NATIVE_CONSTRUCTOR_Integer, ((uintptr_t*)(v))), rest);
    }
    
    uintptr_t* n = wombat_constructor_2(&(external.wombat), WOMBAT_NATIVE_CONSTRUCTOR_Integer, ((uintptr_t*)(N)));
    
    struct timespec clkin;
    clock_gettime(CLOCK_MONOTONIC, &clkin);
    rest = collector_invoke((&external), ((void*)(wombat_defun_main_minus_quicksort_minus_ntimes)), NULL, rest, n, NULL, NULL, NULL, NULL);
    struct timespec clkout;
    clock_gettime(CLOCK_MONOTONIC, &clkout);
    double elapsed = (((double)(clkout.tv_sec - clkin.tv_sec)) + (((double)(clkout.tv_nsec - clkin.tv_nsec)) / 1e9));
    if (elapsed < used) {
      used = elapsed;
    }
    
    assert((external.stat.invocations == 1));
    
    if (trial == 0) {
      uintptr_t prev = 0;
      
      while (rest[0] == WOMBAT_CONSTRUCTOR_ListCons) {
        uintptr_t* item = ((uintptr_t*)(rest[1]));
        assert(item[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
        assert(item[1] >= prev);
        prev = item[1];
        rest = ((uintptr_t*)(rest[2]));
      }
      
      fprintf(stderr, "collected=%" PRIuPTR " surviving=%" PRIuPTR "\n", external.stat.collected, external.stat.surviving);
    }
  }
  
  printf("used=%lf\n", used);
  
  {
    uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));
    
    CollectorExternal external;
    external.heap.bas = memory;
    external.heap.end = memory + NELM;
    external.heap.ptr = external.heap.end;
    external.bmap.bas = bitmap;
    external.cmap.bas = ctrmap;
    
    uintptr_t* seed = wombat_malloc(&(external.wombat), (1+((strlen("hello")+sizeof(uintptr_t)-1)/sizeof(uintptr_t))));
    seed[0] = (bit | strlen("hello"));
    memcpy(seed + 1, "hello", strlen("hello"));
    uintptr_t* times = wombat_constructor_2(&(external.wombat), WOMBAT_NATIVE_CONSTRUCTOR_Integer, ((uintptr_t*)(100)));
    uintptr_t* result = collector_invoke((&external), ((void*)(wombat_defun_main_minus_replicate)), NULL, seed, times, NULL, NULL, NULL, NULL);
    assert((result[0] & bit) != 0);
    uintptr_t len = (result[0] - bit);
    char* str = strndup(((char*)(&(result[1]))), len);
    printf("str='%s' [%" PRIuPTR "]\n", str, strlen(str));
  }
  
  return 0;
}
