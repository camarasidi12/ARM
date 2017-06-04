/*----------------------------------------------------------------
//           Test mov                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0x69
	cmp r0, #0x69
	beq	_good

_bad :
	nop
	nop
_good :
	nop
	nop
