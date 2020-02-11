/* copyright (c) 2020 by Andrei Borac */

#include <inttypes.h>

static void driver_fdprintf(uintptr_t fd, char const* fmt, ...);

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

static void* memcpy(void* dest, void const* src, size_t n)
{
  for (size_t i = 0; i < n; i++) {
    ((char*)(dest))[i] = ((char const*)(src))[i];
  }
  
  return dest;
}

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

uintptr_t sy6(uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t arg4, uintptr_t arg5, uintptr_t arg6, uintptr_t arg0);

#ifdef UDRIVER_ARCH_X86_64_LINUX

asm(".text\n"
    ".align 16\n"
    ".global sy6\n"
    "sy6:\n"
    "movq %rcx, %r10\n"
    "movq 8(%rsp), %rax\n"
    "syscall\n"
    "retq\n");

#define SYS_exit 60
#define SYS_read 0
#define SYS_write 1
#define SYS_mmap 9

#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_SHARED 1
#define MAP_ANONYMOUS 32

#endif

#ifdef UDRIVER_ARCH_MIPSEL_LINUX_O32

asm(".text\n"
    ".set reorder\n"
    ".align 2\n"
    ".globl sy6\n"
    "sy6:\n"
    "lw $v0, 6*4($sp)\n"
    "syscall\n"
    "jr $ra\n");

#define SYS_exit 4001
#define SYS_read 4003
#define SYS_write 4004
#define SYS_mmap 4210 // use mmap2

#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_SHARED 1
#define MAP_ANONYMOUS 2048

#endif

#ifdef UDRIVER_ARCH_ARM_LINUX_EABI_THUMB

asm(".text\n"
    ".global sy6\n"
    ".thumb_func\n"
    "sy6:\n"
    "push {r4, r5, r7, lr}\n"
    "add r4, sp, #16\n"
    "ldmia r4, {r4, r5, r7}\n"
    "svc 0\n"
    "pop {r4, r5, r7, pc}\n");

#define SYS_exit 1
#define SYS_read 3
#define SYS_write 4
#define SYS_mmap 192 // use mmap2

#define PROT_READ 1
#define PROT_WRITE 2
#define MAP_SHARED 1
#define MAP_ANONYMOUS 32

#endif

#define HOST_IS_LINUX
#define DRIVER_ABORT_FUNC driver_abort

__attribute__((noreturn)) static void driver_exit(uintptr_t code)
{
  sy6(code, 0, 0, 0, 0, 0, SYS_exit);
  while (1);
}

__attribute__((unused)) static void driver_abort(void)
{
  driver_exit(2);
}

#include "wombat.include.c"

#include <stdarg.h>
#include <stddef.h>
#include <stdbool.h>
#include <inttypes.h>

#define UNUSED __attribute__((unused))
#define NOINLINE __attribute__((noinline))

static void driver_write_fully_ignore(uintptr_t fd, void const* mem, uintptr_t len)
{
  while (len > 0) {
    intptr_t amt = ((intptr_t)(sy6(fd, ((uintptr_t)(mem)), len, 0, 0, 0, SYS_write)));
    
    if (amt < 0) {
      return; // ignore errors
    }
    
    uintptr_t uamt = ((uintptr_t)(amt));
    
    mem = ((void const*)(((uint8_t const*)(mem)) + uamt));
    len -= uamt;
  }
}

static uintptr_t driver_strlen(char const* x)
{
  char const* begin = x;
  
  while (*x) x++;
  
  return ((uintptr_t)(x - begin));
}

#ifdef UDRIVER_ARCH_ARM_LINUX_EABI_THUMB

static void driver_divmod10(uintptr_t x, uintptr_t* q, uintptr_t* r)
{
  uintptr_t o = 0;
  
  while (x >= 1000000000) { o += 100000000; x -= 1000000000; }
  while (x >=  100000000) { o +=  10000000; x -=  100000000; }
  while (x >=   10000000) { o +=   1000000; x -=   10000000; }
  while (x >=    1000000) { o +=    100000; x -=    1000000; }
  while (x >=     100000) { o +=     10000; x -=     100000; }
  while (x >=      10000) { o +=      1000; x -=      10000; }
  while (x >=       1000) { o +=       100; x -=       1000; }
  while (x >=        100) { o +=        10; x -=        100; }
  while (x >=         10) { o +=         1; x -=         10; }
  
  *q = o;
  *r = x;
}

#else

static void driver_divmod10(uintptr_t x, uintptr_t* q, uintptr_t* r)
{
  *q = (x / 10);
  *r = (x % 10);
}

#endif

static char const* driver_utoa(uintptr_t x)
{
  static char buf[21]; // 64 bit maximum
  
  char* end = &(buf[22]);
  
  *(--end) = '\0';
  
  if (x == 0) {
    *(--end) = '0';
  } else {
    while (x) {
      uintptr_t q, r;
      driver_divmod10(x, &q, &r);
      x = q;
      *(--end) = ((char)(r + '0'));
    }
  }
  
  return end;
}

static void driver_fdprintf(uintptr_t fd, char const* fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);
  
  char code;
  
  while ((code = *(fmt++)) != '\0') {
    switch (code) {
    case 's':
      {
        char const* s = va_arg(ap, char const*);
        driver_write_fully_ignore(fd, s, driver_strlen(s));
        break;
      }
      
    case 'u':
      {
        uintptr_t u = va_arg(ap, uintptr_t);
        char const*s = driver_utoa(u);
        driver_write_fully_ignore(fd, s, driver_strlen(s));
        break;
      }
    }
  }
}

__attribute__((noinline,noreturn)) static void wombat_panic(WombatExternal* wombat_external UNUSED, uintptr_t* bad) {
  driver_fdprintf(2, "sus", "wombat_panic: ", ((uintptr_t)(bad)), "\n");
  driver_exit(1);
  while (1);
}

__attribute__((noinline, noreturn)) static void driver_assure_failed(char const* file, uintptr_t line) {
  driver_fdprintf(2, "sssus", "assure failed in ", file, " on line ", line, "\n");
  driver_exit(1);
  while (1);
}

static bool driver_starts_with(char const* corpus, char const* prefix)
{
  while ((*corpus) && (*prefix)) {
    if ((*corpus) != (*prefix)) {
      return false;
    }
    
    corpus++;
    prefix++;
  }
  
  return (!(*prefix));
}

static char const* driver_getenv(char const* const* envp, char const* key)
{
  uintptr_t keylen = driver_strlen(key);
  
  for (char const* const* envv = envp; *envv != NULL; envv++) {
    if (driver_starts_with(*envv, key)) {
      if ((*envv)[keylen] == '=') {
        return ((*envv) + keylen + 1);
      }
    }
  }
  
  return NULL;
}

static uintptr_t driver_atoi(char const* str)
{
  uintptr_t out = 0;
  
  while (('0' <= (*str)) && ((*str) <= '9')) {
    out = ((out << 3) + (out << 1));
    out += ((uintptr_t)((*str) - '0'));
    str++;
  }
  
  return out;
}

static char const* driver_strchr(char const* str, char x)
{
  while (*str) {
    if (*str == x) {
      return str;
    }

    str++;
  }
  
  return NULL;
}

static void driver_main(uintptr_t argc, char const* const* argv, char const* const* envp)
{
#ifndef UDRIVER_MEMORY_LIMIT
#define UDRIVER_MEMORY_LIMIT (1024*1024)
#endif
  
  uintptr_t sz_memory = UDRIVER_MEMORY_LIMIT;
  
  {
    char const* val;
    
    if ((val = driver_getenv(envp, "UDRIVER_MEMORY_LIMIT")) != NULL) {
      sz_memory = driver_atoi(val);
    }
  }
  
  sz_memory = (((sz_memory + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t)) * sizeof(uintptr_t));
  
  uintptr_t sz_bitmap = (sz_memory / sizeof(uintptr_t));
  uintptr_t sz_ctrmap = sz_bitmap;
  
#ifndef UDRIVER_STKMAP_LIMIT
#define UDRIVER_STKMAP_LIMIT 1024
#endif
  
  uintptr_t sz_stkmap = UDRIVER_STKMAP_LIMIT;
  
  {
    char const* val;
    
    if ((val = driver_getenv(envp, "UDRIVER_STKMAP_LIMIT")) != NULL) {
      sz_stkmap = driver_atoi(val);
    }
  }
  
  sz_stkmap = (((sz_stkmap + (sizeof(uintptr_t) - 1)) / sizeof(uintptr_t)) * sizeof(uintptr_t));
  
  uintptr_t memory_addr = sy6(0, sz_memory, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), ((uintptr_t)(-1)), 0, SYS_mmap);
  assure(memory_addr != ((uintptr_t)(-1)));
  uintptr_t* memory = ((uintptr_t*)(memory_addr));
  
  uintptr_t bitmap_addr = sy6(0, sz_bitmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), ((uintptr_t)(-1)), 0, SYS_mmap);
  assure(bitmap_addr != ((uintptr_t)(-1)));
  uintptr_t* bitmap = ((uintptr_t*)(bitmap_addr));
  
  uintptr_t ctrmap_addr = sy6(0, sz_ctrmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), ((uintptr_t)(-1)), 0, SYS_mmap);
  assure(ctrmap_addr != ((uintptr_t)(-1)));
  uintptr_t* ctrmap = ((uintptr_t*)(ctrmap_addr));
  
  uintptr_t stkmap_addr = sy6(0, sz_stkmap, (PROT_READ | PROT_WRITE), (MAP_SHARED | MAP_ANONYMOUS), ((uintptr_t)(-1)), 0, SYS_mmap);
  assure(stkmap_addr != ((uintptr_t)(-1)));
  uintptr_t* stkmap = ((uintptr_t*)(stkmap_addr));
  
  CollectorExternal external;
  memset((&external), 0, sizeof(external));
  external.heap.bas = memory;
  external.heap.end = memory + (sz_memory / sizeof(uintptr_t));
  external.heap.ptr = external.heap.end;
  external.bmap.bas = bitmap;
  external.cmap.bas = ctrmap;
  external.smap.bas = stkmap;
  external.smap.end = stkmap + (sz_stkmap / sizeof(uintptr_t));
  
#define wombat_construct_blob(what_bas, what_len)                       \
  ({                                                                    \
    char const* bas = (what_bas);                                       \
    uintptr_t len = (what_len);                                         \
    uintptr_t amt = (1 + ((len + sizeof(uintptr_t) - 1) / sizeof(uintptr_t))); \
    uintptr_t* out = wombat_malloc(&(external.wombat), amt);            \
    uintptr_t bit = (1UL << ((8*sizeof(uintptr_t))-1));                 \
    out[0] = (bit | len);                                               \
    memcpy((&(out[1])), bas, len);                                      \
    out;                                                                \
  })
  
  uintptr_t* nocaml_argv = ((uintptr_t*)(wombat_primordial_list_minus_fini));
  
  // populate nocaml_argv
  {
    for (uintptr_t i = argc; i > 0; i--) {
      uintptr_t j = (i - 1);
      
      uintptr_t* nocaml_argj = wombat_construct_blob(argv[j], driver_strlen(argv[j]));
      
      nocaml_argv = wombat_constructor_3(&(external.wombat), WOMBAT_CONSTRUCTOR_ListCons, nocaml_argj, nocaml_argv);
    }
  }
  
  uintptr_t* nocaml_envp = ((uintptr_t*)(wombat_primordial_list_minus_fini));
  
  // populate nocaml_envp
  {
    uintptr_t envc = 0;
    
    {
      char const* const* walk = envp;
      
      while (*walk) {
        envc++;
        walk++;
      }
    }
    
    for (uintptr_t i = envc; i > 0; i--) {
      uintptr_t j = (i - 1);
      
      char const* envvar = envp[j];
      
      char const* enveq = driver_strchr(envvar, '=');
      
      assure((enveq != NULL));
      
      uintptr_t* nocaml_key = wombat_construct_blob(envvar, ((uintptr_t)(enveq - envvar)));
      uintptr_t* nocaml_val = wombat_construct_blob((enveq + 1), ((uintptr_t)(driver_strlen(enveq) - 1)));
      
      uintptr_t* nocaml_ent = wombat_constructor_3(&(external.wombat), WOMBAT_CONSTRUCTOR_Pair, nocaml_key, nocaml_val);
      
      nocaml_envp = wombat_constructor_3(&(external.wombat), WOMBAT_CONSTRUCTOR_ListCons, nocaml_ent, nocaml_envp);
    }
  }
  
  uintptr_t* nocaml_retv = collector_invoke((&external), ((void*)(wombat_defun_main)), NULL, nocaml_argv, nocaml_envp, NULL, NULL, NULL, NULL);
  
  assure(nocaml_retv[0] == WOMBAT_NATIVE_CONSTRUCTOR_Integer);
  
  driver_exit(nocaml_retv[1]);
}

void shim(uintptr_t* sp)
{
  uintptr_t argc = *sp;
  
  assure(argc <= (1UL << 16));
  
  char const* const* argv = ((char const* const*)(sp + 1));
  
  assure((*(sp + 1 + argc)) == 0);
  
  char const* const* envp = ((char const* const*)(sp + 1 + argc + 1));
  
  driver_main(argc, argv, envp);
}

#ifdef UDRIVER_ARCH_X86_64_LINUX

asm(".text\n"
    ".global _start\n"
    "_start:\n"
    "movq %rsp, %rdi\n"
    "callq shim\n"
    "end:\n"
    "jmp end\n");

#endif

#ifdef UDRIVER_ARCH_MIPSEL_LINUX_O32

asm(".text\n"
    ".global __start\n"
    ".set noat\n"
    ".set noreorder\n"
    "__start:\n"
    "move $a0, $sp\n"
    "bal __start_helper\n"
    "nop\n"
    "__start_helper:\n"
    ".cpload $31\n"
    "la $t9, shim\n"
    "addiu $sp, $sp, -4*4\n"
    "jalr $t9\n"
    "nop\n"
    "end:\n"
    "j end\n");

#endif

#ifdef UDRIVER_ARCH_ARM_LINUX_EABI_THUMB

asm(".text\n"
    ".global _start\n"
    ".thumb_func\n"
    "_start:\n"
    "mov r0, sp\n"
    "bl shim\n"
    "end:\n"
    "b end\n");

#endif
