/* copyright (c) 2020 by Andrei Borac */

#include <inttypes.h>

#define WOMBAT_UNSAFE_OPTIMIZATIONS
#include "wombat.c"
#define COLLECTOR_UNSAFE_OPTIMIZATIONS
//#define COLLECTOR_INFO
#include "collector.c"

__attribute__((noinline,noreturn)) static void driver_assure_failed(char const*, uintptr_t);
#define assure(expr) { if (__builtin_expect(!!!(expr), 0)) { driver_assure_failed(__FILE__, ((uintptr_t)(__LINE__))); } }

static void* memset(void* s, int c, size_t n)
{
  for (size_t i = 0; i < n; i++) {
    ((char*)(s))[i] = ((char)(c));
  }
  
  return s;
}

#if 0

static void* memcpy(void* dest, void const* src, size_t n)
{
  for (size_t i = 0; i < n; i++) {
    ((char*)(dest))[i] = ((char const*)(src))[i];
  }
  
  return dest;
}

#endif

static int memcmp(void const* s1, void const* s2, size_t n)
{
  for (size_t i = 0; i < n; i++) {
    char c1 = ((char const*)(s1))[i];
    char c2 = ((char const*)(s2))[i];
    
    if (c1 != c2) {
      return ((c1 < c2) ? (-1) : (+1));
    }
  }
  
  return 0;
}

#define HOST_IS_BARE_METAL

#include "wombat.include.c"

#include <stdarg.h>
#include <stddef.h>
#include <stdbool.h>
#include <inttypes.h>

#define UNUSED __attribute__((unused))
#define NOINLINE __attribute__((noinline))
#define COMPILER_BARRIER __asm__ __volatile__ ("" ::: "memory")

__attribute__((noreturn)) static void driver_exit(void)
{
  while (true);
}

__attribute__((noinline,noreturn)) static void wombat_panic(WombatExternal* wombat_external UNUSED, uintptr_t* bad UNUSED) {
  driver_exit();
  while (true);
}

__attribute__((noinline, noreturn)) static void driver_assure_failed(char const* file UNUSED, uintptr_t line UNUSED) {
  driver_exit();
  while (true);
}

#define NELM (4096/4)
static uintptr_t memory[NELM];
static uintptr_t bitmap[((NELM+((8*sizeof(uintptr_t))-1))/(8*sizeof(uintptr_t)))];
static uintptr_t ctrmap[(sizeof(bitmap)/sizeof(uintptr_t))];
#define STKMAPLEN 128
static uintptr_t stkmap[STKMAPLEN];

static void driver_main(void)
{
  CollectorExternal external;
  memset((&external), 0, sizeof(external));
  external.heap.bas = memory;
  external.heap.end = memory + (sizeof(memory) / sizeof(uintptr_t));
  external.heap.ptr = external.heap.end;
  external.bmap.bas = bitmap;
  external.cmap.bas = ctrmap;
  external.smap.bas = stkmap;
  external.smap.end = stkmap + (sizeof(stkmap) / sizeof(uintptr_t));
  
  collector_invoke((&external), ((void*)(wombat_defun_main)), NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  
  driver_exit();
}

extern uintptr_t _BSS_START;
extern uintptr_t _BSS_END;

int main(void) {
  for (uintptr_t* x = (&(_BSS_START)); x < (&(_BSS_END)); x++) {
    *x = 0;
  }
  COMPILER_BARRIER;
  driver_main();
  while (true);
}
