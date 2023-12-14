extern calloc
extern malloc

%define OFFSET_NEXT 0
%define OFFSET_SUM  8
%define OFFSET_SIZE 16
%define OFFSET_ARRAY 24
BITS 64

section .text


; uint32_t proyecto_mas_dificil(lista_t*)
;
; Dada una lista enlazada de proyectos devuelve el `sum` más grande de ésta.
;
; - El `sum` más grande de la lista vacía (`NULL`) es 0.
;

;parametro: rdi = lista_t*
global proyecto_mas_dificil
proyecto_mas_dificil:
	;prologo
	push rbp
	mov rbp,rsp

	;incializo registros en 0 que voy a usar
	xor r8,r8
	xor rax,rax

	cmp rdi,0 ;veo si la lista es null
	je .fin ;de ser null salto al fin para retornar 0
	.ciclo:
		mov r8d,dword[rdi+OFFSET_SUM] ;obtengo el valor de la sum
		cmp r8d,eax ;comparo el valor de sum de este proyecto con el almacenado 
		jle .guarda ;si sum_nuevo <= sum_guardado salto a la guarda, sino lo actualizo 
		mov eax,r8d ; rax = sum_nuevo , tal que sum_nuevo > sum_viejo
		;guarda del ciclo
		.guarda:	
			mov rdi,[rdi] ;paso al siguiente proyecto
			cmp rdi,0	;si es sero llegamos la final, por lo tanto salto fin
			jne .ciclo
	;epilogo
	.fin:	
		pop rbp

		ret

; void tarea_completada(lista_t*, size_t)
;
; Dada una lista enlazada de proyectos y un índice en ésta setea la i-ésima
; tarea en cero.
;
; - La implementación debe "saltearse" a los proyectos sin tareas
; - Se puede asumir que el índice siempre es válido
; - Se debe actualizar el `sum` del nodo actualizado de la lista
;
global marcar_tarea_completada
;parametros: rdi = lista_t , rsi = indice 
marcar_tarea_completada:
	;prologo
	push rbp
	mov rbp,rsp

	;incializo registros en 0 que voy a usar
	xor r8,r8
	xor r9,r9
	xor r10,r10
	xor r11,r11
	xor rax,rax

	cmp rdi,0 ;veo si la lista es null
	je .fin ;salto al fin
	;r8 voy a usarlos para guarda los valores de size de cada proyecto
	;r9 va llevar el conteo de en que indice de tarea estoy parado
	.ciclo:
		mov r8,[rdi+OFFSET_SIZE] ; r8 = size
		cmp r8,0 ;veo si el proyecto es vacio
		je .guarda
		;hago un ciclo por los valores del array
		mov r10,[rdi+OFFSET_ARRAY] ; r10 = *array
		xor r9,r9
 		.ciclo_tarea:
			mov r11d, dword [r10] ; veo la primer tarea de la lista
			cmp rsi,0 ;veo si el indice que recorro es igual al que busco
			jne .sigo
			sub [rdi+OFFSET_SUM],r11d ;si lo encontre resto el valor de sum
			mov dword [r10],0				  ;y lo pongo en 0 en la lista
			jmp .fin
			.sigo:
				add r10,4 ;paso al siguiente elemento del array
				dec rsi
				inc r9, ;aumento el indice en el que me muevo
				cmp r8,r9 ;veo si ya recorri todas las tareas de la lista
				je .guarda 
				jne .ciclo_tarea
		.guarda:	
			mov rdi,[rdi] ;paso al siguiente proyecto
			cmp rdi,0	;si es sero llegamos la final, por lo tanto salto fin
			jne .ciclo
	;epilogo
	.fin:	
		pop rbp
		ret

	ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;
; Dada una lista enlazada de proyectos se devuelve un array que cuenta
; cuántas tareas completadas tiene cada uno de ellos.
;
; - Si se provee a la lista vacía como parámetro (`NULL`) la respuesta puede
;   ser `NULL` o el resultado de `malloc(0)`
; - Los proyectos sin tareas tienen cero tareas completadas
; - Los proyectos sin tareas deben aparecer en el array resultante
; - Se provee una implementación esqueleto en C si se desea seguir el
;   esquema implementativo recomendado
;
global tareas_completadas_por_proyecto
;parametros rdi = lista_t*
tareas_completadas_por_proyecto:
	;prologo
	push rbp
	mov rbp,rsp

	push r12 
	push r13
	push r14
	push r15

	xor r8,r8 ;lo vamos a usar por movernos sobre el puntero a retornar

	mov r12,rdi ; guardo en r12 = *lista_ t para no perderlo

	call lista_len  ;llamo a lista len con lista_t*  
					;devuelve la longitud en rax
	cmp rax,0
	je .fin

	mov rdi,rax		 ;llamo a calloc con la longitud de la lista y el tamaño de 64 bits
	mov rsi, qword 8 ;rdi = lista_len y rsi = 8, 8 bytes
	call calloc		 ;en rax nos queda el puntero que vamos a devolver

	mov r13,rax      ;lo muevo a r13 para no perderlo
	mov r14,rax
	.ciclo:
		mov rdi,[r12+OFFSET_ARRAY] ;rdi = array*
		mov rsi,[r12+OFFSET_SIZE]  ;rsi = size
		call tareas_completadas    ;recibo en rax la cantidad de tareas completadas de array
		mov [r14],rax        ;guardo la cantidad de tareas completadas
		add r14,8

		mov r12,[r12]   ;paso al siguiente proyecto
		cmp r12,0
		jne .ciclo

	mov rax,r13

	;epilogo
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp

	ret
    .fin:
		mov rdi,0 
		call malloc 

		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp

		ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;
; - La longitud de `NULL` es 0
;
; parametros, rdi = lista_t*
lista_len:
	;prologo
	push rbp
	mov rbp,rsp

	xor rax,rax ;en rax voy a guardar la longitud
	cmp rdi,0 ;veo si la lista es null
	je .fin ;de ser null salto al fin para retornar 0
	.ciclo:
			inc rax   
		.guarda:	
			mov rdi,[rdi] ;paso al siguiente proyecto
			cmp rdi,0	;si es 0 llegamos la final, por lo tanto salto fin
			jne .ciclo
	;epilogo
	.fin:	
		pop rbp
		ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;
; - Un array de tamaño 0 tiene 0 ceros.
; parametros rdi = array, rsi = size
tareas_completadas:
	;prologo
	push rbp
	mov rbp,rsp

	xor rax,rax ; lo inicializo para usarlo como acumulador
	xor r8,r8 ;lo uso para guarda la tarea
	xor r9 ,r9 ;lo uso para ver en que indice estoy

	cmp rsi,0   ;veo si el size = 0, si lo es no tiene elemtentos
	je .fin
	.ciclo:
		mov r8d, dword [rdi] ;veo el elemento apuntado por rdi
		cmp r8d,0   ;si es 0 es por que lo completaron, entonces sumo 1 a la cantidad
		jne .guarda
		inc rax
		.guarda:	
			inc r9       ;aumento el indice en 1
			add rdi,4    ;paso a la siguiente tarea
			cmp r9,rsi   ;veo si size=indice, en ese caso ya vi todas las tareas
			jne .ciclo
	;epilogo
	.fin:	
		pop rbp
		ret	
