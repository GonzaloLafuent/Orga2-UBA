extern calloc
extern strcmp
global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern malloc

%define monto_offset 0
%define comercio_offset 8
%define cliente_offset 16
%define aprobado_offset 17
%define pago_offset 24
%define size_uint32 4
%define size_string 8
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;parametro rdi = cantidadDePagos rsi = arr_pagos
acumuladoPorCliente_asm:
	;prologo
	push rbp
	mov rbp,rsp

	push r12
	push r13

	;/////////
	mov r12,rdi ;los guardo para no perderlos en la llamda a calloc
	mov r13,rsi ; r12 = cantidad de pagos r13 = *arr_pagos

	mov rdi,10 ;cantidad de espacios de memeoria que quiero
	mov rsi,size_uint32 ;tamaño de espacios, 4 bytes por que son 32 bits
	call calloc	;luego de la llamada recibo en rax el puntero a devolver

	;inicializo estos registros en 0 temporales
	;en esta parte para borrar lo que pudo haber usado calloc
	xor r10,r10
	xor r11,r11
    xor r8,r8
.ciclo:

	mov r10b,byte[r13 + aprobado_offset] ; r10b = aprobado
	cmp r10b,1 ;veo si aprobado es verdadero, si no lo es salto a .sigo
	jne .sigo
	;cargo el monto en el array a devolver
	mov r10b,byte[r13 + monto_offset] ;r10b = el monton del array de pagos
	mov r11,[r13+comercio_offset]
	mov r11b,byte[r13 + cliente_offset] ;r11b = el cliente del array de pagos
	add [rax + r11*size_uint32],r10b ;en base al numero de cliente obtenido el monto, lo sumo a su respetiva posicion en el aray a devolver 
.sigo:
	;paso al siguiente elemento del array
	add r13,pago_offset
	;guarda del ciclo
	dec r12
	cmp r12,0
	jne .ciclo

	;epilogo
	pop r13
	pop r12
	pop rbp

	ret

;parametro: rdi = comercio, rsi = lista_comercio, rdx = n
en_blacklist_asm:
	;prologo
	push rbp
	mov rbp,rsp

	push r12
	push r13
	push r14
	push r15
	;/////////////
	xor r12,r12
	xor r13,r13
	xor r14,r14
	xor rax,rax

	mov r12,rdi ; r12 = comercio
	mov r13,rsi ; r13 = lista_comercion
	mov r14,rdx  ; r14 = n 

	cmp r14,0
	je .fin
	.ciclo:
		xor rdi,rdi
		xor rsi,rsi

		mov rdi,r12    
		mov rsi,[r13] ;obtenego el string en la lista
		call strcmp   ;llamo a strcmp con comercio y el elemento de apunta por el array
		
		cmp rax,0  ;si los string son iguales la strcmp da 0
		jne .sigo ;sino son iguales salto y sigo con el ciclo	
		mov rax,1 ;si fuesen iguales retorno 1 
		jmp .fin
	.sigo:	
		xor rax,rax
		add r13,size_string ;le sumo 8
		dec r14
		cmp r14,0
		jne .ciclo
		;epilogo
	.fin:	
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp	
		ret

;parametros dil = cantidad_agos
;			rsi = arr_pagos
;			rdx = arr_comercios
;			cl size_comercios
blacklistComercios_asm:
	;prologo
	push rbp
	mov rbp,rsp

	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp,8

	xor r15,r15
	xor r12,r12

	mov r12b,dil ; r12= cantidad_pagos
	mov r13,rsi ; r13= arr_pagos
	mov r14,rdx ; r14= arr_comercios
	mov r15b,cl ; rcx= size_comercios

	xor rbx,rbx, ;cantidad de pagos en comercios

	mov r8,r12 ;guarda del ciclo
	mov r9,r13 
	.ciclo_contador:
		mov rdi,[r9 + comercio_offset]
		mov rsi,r14
		mov dl,r15b

		push r8
		push r9

		call en_blacklist_asm

		pop r9
		pop r8

		cmp rax,1
		jne .sigo

		inc rbx

	.sigo:
		add r9,pago_offset
		dec r8
		cmp r8,0
		jne .ciclo_contador

	shl rbx,3 ; multiplica rbx por 8
	mov rdi,rbx
	call malloc
	mov rbx,rax

	xor r10,r10 ;proxima iteracion libre

	mov r8,r12 ;guarda del ciclo
	mov r9,r13 
	.ciclo:
		mov rdi,[r9 + comercio_offset]
		mov rsi,r14
		mov dl,r15b

		push r10
		push r8
		push r9
		sub rsp,8

		call en_blacklist_asm

		add rsp,8
		pop r9
		pop r8
		pop r10

		cmp rax,1
		jne .siguiente

		;aca esta la diferencia, donde lo que vamos a hacer es copiar el pago
		push r10
		push r8
		push r9	
		sub rsp,8

		mov rdi,pago_offset

		call malloc

		add rsp,8
		pop r9
		pop r8
		pop r10
		
		xor r11,r11

		mov r11b, byte [r9+monto_offset]
		mov [rax+monto_offset],r11b
		
		mov r11,[r9+comercio_offset]
		mov [rax+comercio_offset],r11

		mov r11b, byte [r9+cliente_offset]
		mov byte [rax+cliente_offset],r11b

		mov r11b, byte [r9+aprobado_offset]
		mov byte [rax+aprobado_offset],r11b

		mov [rbx+r10],rax
		add r10,8

		.siguiente:
		add r9,pago_offset
		dec r8
		cmp r8,0
		jne .ciclo

	;epilogo
	mov rax,rbx

	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp

	ret
