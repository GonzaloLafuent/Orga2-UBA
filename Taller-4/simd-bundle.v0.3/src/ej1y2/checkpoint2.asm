section .rodata
ocho: times 4 dd 8
section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)
; rdi = array, rsi = n

checksum_asm:
	push rbp
	mov rbp,rsp
	push rbx

	xor rax,rax
	mov rax,1

	movdqu xmm8,[ocho]
.ciclo:
	; a = (a0)xmm0 ° (a1)xmm1 
	pmovzxwd xmm0,[rdi]
	add rdi,8
	pmovzxwd xmm1,[rdi]
	add rdi,8
	;b = (b0)xmm2 ° (b1)xmm3
	pmovzxwd xmm2,[rdi]
	add rdi,8
	pmovzxwd xmm3,[rdi] 
	add rdi,8
	;c = (c0)xmm4 ° (c1)xmm5
	movdqu xmm4,[rdi]
	add rdi,16
	movdqu xmm5,[rdi] 
	add rdi,16

	; xmm0 = a0 + b0, a1 + b1, a2 + b2, a3 + b3
	paddd xmm0,xmm2
	; xmm1 = a4 + b4, a5 + b5, a6 + b6, a6 + b6
	paddd xmm1,xmm3

	pmulld xmm0,xmm8
	pmulld xmm1,xmm8
; salgo con xmm0 = xmm0*8 (cada valor)
; salgo con xmm1 = xmm1*8 (cada valor)(tengo que ver como usar la pmul)

; chequeo si (a+b)*8 de 0 a 3 = c de 0 a 3
	pcmpeqd xmm0,xmm4
; chequeo si (a+b)*8 de 4 a 7 = c de 4 a 7
	pcmpeqd xmm1,xmm5

	pand xmm0,xmm1
	phaddd xmm0,xmm0
	phaddd xmm0,xmm0
	movd ebx,xmm0
	cmp ebx,-4
	jne .fin 

	sub rsi,1
	cmp rsi,0
	jne .ciclo

	pop rbx
	pop rbp
	ret
.fin:
	pop rbx
	pop rbp
	xor rax,rax
	ret


