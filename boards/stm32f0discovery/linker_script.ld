MEMORY
{
  flash : org = 0x08000000, len = 64k
  ram   : org = 0x20000000, len = 8k
}

SECTIONS
{
  . = ORIGIN(flash);
  .text : {
    startup.o (.text)
    *(.text)
    *(.text.startup)
    *(.rodata)
  } >flash
  . = ORIGIN(ram);
  _BSS_START = .;
  .bss : {
    *(.bss)
  } >ram
  _BSS_END = .;
}
