

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
LONGITUD_OFFSET	EQU	24

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos:
	mov rax,0
	mov rdi, [rdi] ; primer nodo
cantidad_total_de_elementos_loop:
	add rax, [rdi + LONGITUD_OFFSET]
	mov rdi, [rdi] ; nodo siguiente
	cmp rdi, 0
	JNE cantidad_total_de_elementos_loop
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[RDI]
cantidad_total_de_elementos_packed:
	xor rax,rax
	mov rdi,[rdi] ; primer nodo
cantidad_total_de_elementos_packed_loop:
	add eax,dword[rdi + PACKED_LONGITUD_OFFSET]
	mov edi,dword [rdi] ; nodo siguiente
	cmp edi, 0
	JNE cantidad_total_de_elementos_packed_loop
	ret
