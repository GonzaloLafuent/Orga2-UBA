section .data
blanco: times 16 db 255
negro: times 16 db 0
mascara_1: dq 0
mascara_2: dq -1
mascara_3: dq 0
section .text

global Pintar_asm

;void Pintar_asm(unsigned char *src [rdi],
;              unsigned char *dst [rsi],
;              int width  [rdx],
;              int height [rcx],
;              int src_row_size [r8],
;              int dst_row_size [r9];


Pintar_asm:
	push rbp
	mov rbp,rsp

	movdqu xmm1,[blanco] ;hago un registros que tenga bytes de 255 en cada valor
	movdqu xmm2,[negro]

	movdqu xmm3, [mascara_1] ; mascara de inicio
	movdqu xmm4, [mascara_2] ; mascara de fin
	
	xor r10, r10
	; TODO: esto anda pero se puede hacer mas bonito con una mascara con
	; una operacion de esas locas de simd
	pinsrb xmm1,r10b,3  ;Inserto cero en cada byte correspondiente a la transparencia
	pinsrb xmm1,r10b,7
	pinsrb xmm1,r10b,11
	pinsrb xmm1,r10b,15 
	mov r10,rdx	 ; r10 = width
	imul r10,rcx ;obtengo la cantidad de pixeles = width * height = tamaño de la matriz
	shr r10,2   ;r10 contiene cantidad de iteraciones TOTALES de la imagen

	sub r10, rdx
	shr rdx, 1
	mov r8, rdx ; rdx = r8 = ancho de la imagen
	shr r8, 1
	push rdx
	
.ciclo_borde_superior_negro:
	movdqu [rsi],xmm2 ;guardo el valor de blanco obtenido en la direccion destino
	add rsi,16
	
	dec rdx
	cmp rdx,0
	jne .ciclo_borde_superior_negro

	mov rdx, r8 ; rdx = r8

.ciclo_centro: ; el ciclo pone todo en blanco
	movdqu xmm5, xmm1

	cmp rdx, r8 
	je .ciclo_centro_inicio_imagen

	cmp rdx, 1 
	je .ciclo_centro_fin_imagen

	sub rdx, 1
	jmp .ciclo_centro_fin

	.ciclo_centro_inicio_imagen:
		sub rdx, 1
		pand xmm5, xmm3
		jmp .ciclo_centro_fin

	.ciclo_centro_fin_imagen:
		mov rdx, r8 ; rdx = r8 = ancho de la imagen
		pand xmm5, xmm4

.ciclo_centro_fin:
	movdqu [rsi],xmm5 ;guardo el valor de blanco obtenido en la direccion destino
	add rsi,16

	; fin de ciclo 
	dec r10
	cmp r10,0
	jne .ciclo_centro

	pop rdx
.ciclo_borde_inferior_negro:
	movdqu [rsi],xmm2 ;guardo el valor de blanco obtenido en la direccion destino
	add rsi,16
	
	dec rdx
	cmp rdx,0
	jne .ciclo_borde_inferior_negro

	pop rbp
	ret
	


