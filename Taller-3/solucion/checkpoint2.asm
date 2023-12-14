extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[RDI], x2[RSI], x3[RDX], x4[RCX]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp,rsp
	; COMPLETAR
	sub RDI,RSI
	add RDI,RDX
	sub RDI,RCX
	mov RAX,RDI
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	; COMPLETAR
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	push rcx
	push rdx

	;rdi = x1 , rsi = x2
	call restar_c
	mov rdi,rax
	pop rsi
	sub rsp, 0x08
	;rdi = x1-x2 rsi = x3
	call sumar_c
	add rsp, 0x08
	;rdi = x1-x2+x3
	mov rdi,rax
	pop rsi
	call restar_c
	;rdi = x1-x2+x3-x4
	; COMPLETAR

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	sub RDI,RSI
	add RDI,RDX
	sub RDI,RCX
	mov RAX,RDI
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp+0x18]
alternate_sum_8:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	; COMPLETAR
	sub RDI,RSI
	add RDI,RDX
	sub RDI,RCX
	add RDI,R8
	sub RDI,R9
	add RDI,[rbp+0x10]
	sub RDI,[rbp+0x18]

	mov RAX,RDI
	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[XMM0]
;product_2_f:
	;cvtSI2SS XMM1, RSI
	;MULSS XMM0, XMM1
	;cvtSS2SI RSI, XMM0
	;MOV [RDI], RSI
	;ret
product_2_f:
	;cvtsi2ss XMM1, RSI
	cvtsi2ss XMM1, ESI
	mulss XMM0, XMM1
	;cvttSS2SI
	;cvttss2si RSI, XMM0
	cvttss2si ESI, XMM0
	;mov [RDI], RSI
	mov [RDI], ESI
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[XMM0], x2[rdx], f2[XMM1], x3[rcx], f3[XMM2], x4[r8], f4[XMM3]
;	, x5[R9], f5[XMM4], x6[rbp+0x10], f6[XMM5], x7[rbp+0x18], f7[XMM6], x8[rbp+0x20], f8[XMM7],
;	, x9[rbp+0x28], f9[rbp+0x30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	cvtSS2SD XMM0, XMM0
	cvtSS2SD XMM1, XMM1
	cvtSS2SD XMM2, XMM2
	cvtSS2SD XMM3, XMM3
	cvtSS2SD XMM4, XMM4
	cvtSS2SD XMM5, XMM5
	cvtSS2SD XMM6, XMM6
	cvtSS2SD XMM7, XMM7

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	MULSD XMM0, XMM1
	MULSD XMM0, XMM2
	MULSD XMM0, XMM3
	MULSD XMM0, XMM4
	MULSD XMM0, XMM5
	MULSD XMM0, XMM6
	MULSD XMM0, XMM7
	MOVSS XMM1,dword [rbp+0x30]
	cvtSS2SD XMM1, XMM1
	MULSD XMM0, XMM1

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtSI2SD XMM1, RSI
	MULSD XMM0, XMM1
	cvtSI2SD XMM1, rdx
	MULSD XMM0, XMM1
	cvtSI2SD XMM1, rcx
	MULSD XMM0, XMM1
	cvtSI2SD XMM1, r8
	MULSD XMM0, XMM1
	cvtSI2SD XMM1, R9
	MULSD XMM0, XMM1

	MOV esi, dword[rbp+0x10]
	cvtSI2SD XMM1, esi
	MULSD XMM0, XMM1
	MOV esi, dword[rbp+0x18]
	cvtSI2SD XMM1, esi
	MULSD XMM0, XMM1
	MOV esi, dword[rbp+0x20]
	cvtSI2SD XMM1, esi
	MULSD XMM0, XMM1
	MOV esi, dword[rbp+0x28]
	cvtSI2SD XMM1, esi
	MULSD XMM0, XMM1
	
	movsd qword[RDI], XMM0

	; epilogo
	pop rbp
	ret


