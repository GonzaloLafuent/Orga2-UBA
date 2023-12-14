extern malloc
global templosClasicos
global cuantosTemplosClasicos
 
%define col_corta_offset 16
%define col_larga_offset 0 
%define nombre_offset 8
%define templo_offset 24
;########### SECCION DE TEXTO (PROGRAMA)
section .text
;parametro rdi = *temploArr, rsi  = temploArr_len 
templosClasicos:
    ;prologo 
    push rbp
    mov rbp,rsp

    push r14
    push r12
    push r13
    push r15
    ;fin prologo

    mov r12,rdi ; r12 = *temploArr
    mov r13,rsi ; r13 = *temploArr_length

    call cuantosTemplosClasicos ; en rax voy a obtener la cantidad de templos clasicos
    mov r15d, dword eax ; r15 = cantidad de templos clasicos

    mov edi, dword eax ;guardo la cantidad de clasicos para pasarselo a malloc 
    imul rdi,templo_offset ;lo multiplico por el tamaño de cada templo
    ;llamo a malloc para obtener el arreglo con el tamaño de memoria que quiero obtener
    call malloc ;recibo en rax el puntero que voy a retornar
    
    mov r14,rax ;para modificar la referencia inicial y no modificarla
.ciclo:
    xor r8,r8 ;los inicializo en 0 en cada iteracion para no tener conflictos con la comparacion
    xor r9,r9 

    mov r8b,byte [r12+col_corta_offset] ;guardo el valor de la columan corta en r8
    mov r9b,byte [r12+col_larga_offset] ; guardo el valor de columna larga en r9

    imul r8d,2 ; r8d = 2*n (r8d contiene la columna corta por dos)
    inc r8d ; r8d = 2*n+1 (r8d contiene la columna corta por dos mas 1)
    cmp r8d,r9d ; comparao 2*n + 1 = m
    jne .noCumple 
        ;tenemos que insertar el templo que cumple en el arreglo
        mov r11,[r12 + col_larga_offset]
        mov [r14 + col_larga_offset],r11

        mov r11,[r12 + nombre_offset]
        mov [r14 + nombre_offset],r11

        mov r11,[r12 + col_corta_offset]
        mov [r14 + col_corta_offset],r11
        add r14, templo_offset
    
.noCumple:
    add r12,templo_offset    
    dec r13b
    cmp r13b,0
    jne .ciclo


    ;epilogo
    pop r15
    pop r13
    pop r12
    pop r14
    pop rbp

    ret

;parametro rdi = *temploArr, rsi  = temploArr_len 
cuantosTemplosClasicos:
    ;prologo
    push rbp
    mov rbp,rsp

    ;inicializo registro que voy a usar en 0
    xor rax,rax ;lo usare de acumulador para luego retornar el resultado
.ciclo:
    xor r8,r8 ;los inicializo en 0 en cada iteracion para no tener conflictos con la comparacion
    xor r9,r9

    mov r8b,byte [rdi+col_corta_offset] ;guardo el valor de la columan corta en r8
    mov r9b,byte [rdi+col_larga_offset] ; guardo el valor de columna larga en r9

    imul r8d,2 ; r8d = 2*n (r8d contiene la columna corta por dos)
    inc r8d ; r8d = 2*n+1 (r8d contiene la columna corta por dos mas 1)
    cmp r8d,r9d ; comparao 2*n + 1 = m
    jne .noCumple 
    inc eax

.noCumple:

    add rdi,templo_offset    
    dec sil
    cmp sil,0
    jne .ciclo

    ;epilogo
    pop rbp
    ret

