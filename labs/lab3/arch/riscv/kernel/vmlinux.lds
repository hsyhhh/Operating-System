OUTPUT_ARCH( "riscv" )
ENTRY( _start )
BASE_ADDR = 0x80000000;
SECTIONS
{
  . = BASE_ADDR;
  .text : { 
		  *(.text.init) 
  		  *(.text.entry)
  		  *(.text)
  }
  .rodata : { *(.rodata) }
  __data_start = .;
  .data : { *(.sdata .sdata.*) *(.data .data.*) }
  __data_end = .;
  __bss_start = .;
  .bss : { *(.sbss .sbss.*) *(.bss .bss.*) }
  __bss_end = .;
  . += 0x8000;
  stack_top = .;
  _end = .;
}
