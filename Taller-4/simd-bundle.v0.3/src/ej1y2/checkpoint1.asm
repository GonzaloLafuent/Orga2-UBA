
section .text

global invertirQW_asm

; void invertirQW_asm(uint64_t* p)

invertirQW_asm:
	xorpd xmm2,xmm2 
	xorpd xmm1,xmm1
	movdqu xmm2,[rdi] ;  
	;tomas los primeros 64 de xmm1 y los primeros 64 de xmm2
	shufpd xmm1,xmm2,00
	;tomas los segundos 64 de xmm2 y los primeros 64 de xmm1
	shufpd xmm2, xmm1,01
	paddq xmm2,xmm1 
	movdqu [rdi],xmm2
	ret

