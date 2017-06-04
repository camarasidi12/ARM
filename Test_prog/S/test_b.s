/*----------------------------------------------------------------
//           Mon premier programme                              //
//           Test branch good                                   //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	_good
	nop

_bad :
	nop
	nop
_good :
	nop
	nop
