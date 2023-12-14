global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete
extern malloc
extern free
extern strlen
extern strcpy

section .data
%define OFFSET_SIZE 0
%define OFFSET_CAPACITY 1
%define OFFSET_DATA 8
%define SIZE_STR_ARRAY 16

section .text

; str_array_t* strArrayNew(uint8_t capacity)
; parametros: rdi = capacity
strArrayNew:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13

    mov r12,rdi ;guardo rdi para no perderlo en la llamada a malloc

    imul rdi,8  ;incializo data en base a capacidad, el tamaño va ser la capacidad por el tamaño de un puntero que son 8 bytes  
    call malloc

    mov r13,rax ;guardo data en r13
 
    mov rdi,16  ;llamo a malloc con el tamaño de bytes de str_array_t
                ;esa sera la cantidad de memoria que debo retornar

    call malloc ;recibo en rax el puntero a str_array_t

    mov byte [rax+OFFSET_CAPACITY],r12b ;inicializo la capacidad
    mov byte [rax+OFFSET_SIZE],0  ;inicializo size en 0
    mov [rax+OFFSET_DATA],r13 ;inicializo data con el puntero obtenido

    ;epilogo
    pop r13
    pop r12
    pop rbp
    ret
; uint8_t strArrayGetSize(str_array_t* a)
; parametros: rdi = a
strArrayGetSize:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov al, [rdi + OFFSET_SIZE]

    pop rbp
    ret

; void strArrayAddLast(str_array_t* a, char* data)
; parametros: rdi = a rsi = data
strArrayAddLast:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13
    push r14
    push r15

    ; Nos guardamos los argumentos en registros no volátiles.
    mov r12, rdi
    mov r13, rsi

    ; Cargamos size en un registro.
    xor r15, r15
    xor r14, r14
    mov r14b, byte [r12 + OFFSET_SIZE]
    mov r15b, byte [r12 + OFFSET_CAPACITY]

    ; Chequeamos si queda lugar para agregar el nuevo string.
    cmp r14b,r15b
    je .full ; sze == capacity

    ; Calculamos la longitud del string que vamos a agregar.
    mov rdi, r13
    call strlen
    mov r15, rax

    ; Le sumamos 1 para contemplar el NULL char.
    inc r15

    ; Pedimos memoria para el nuevo string.
    mov rdi, r15
    call malloc

    ; Guardamos el puntero al nuevo string en su lugar dentro de data.
    xor r8,r8
    mov r8, [r12 + OFFSET_DATA]
    mov [r8 + r14 * 8], rax

    ; Copiamos el string.
    mov rdi, rax
    mov rsi, r13
    call strcpy

    ; Incrementamos size en 1.
    inc byte [r12 + OFFSET_SIZE]
.full:
    xor rax,rax
.exit:
    ;epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret

; void strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; parametros: rdi = a rsi = i rdx = j
strArraySwap:
    ;prologo
    push rbp
    mov rbp,rsp

    xor r8,r8
    xor r9,r9
    xor r10,r10
    xor r11,r11

    mov r8b, byte [rdi + OFFSET_SIZE] ;obtengo el valor de size de data
    cmp rsi,r8 ;veo si i>size, si lo es salto al fin 
    jg .fin
    cmp rdx,r8 ;veo si j>size, si lo es salto al fin
    jg .fin

    mov r9,[rdi + OFFSET_DATA] ;obtengo el puntero de data

    mov r10,[r9 + 8*rsi] ; r10 = data[i]
    mov r11,[r9 + 8*rdx]  ; r11 = data[j]

    mov [r9 + 8*rsi],r11  ; data[i] = data[j]
    mov [r9 + 8*rdx],r10  ; data[j] = data[i]
.fin:
    ;epilogo   
    pop rbp

    ret

; void strArrayDelete(str_array_t* a)
; parametros: rdi = a
strArrayDelete:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13
    push r14
    push r15

    ;utilizo registros no volatiles para no perder estos valores en cada llamda a free
    mov r12,rdi ;r12 = a
    xor r14,r14
    mov r13,[rdi+OFFSET_DATA] ;r13 = data**
    mov r14b, byte [rdi+OFFSET_SIZE] ;r14 = size
.ciclo:
    cmp r14b,0
    je .sigo

    dec r14b   
    mov rdi,[r13 + r14*8] ; rdi = data[size]

    call free
    jmp .ciclo
.sigo:
    mov rdi,r13

    call free ; free del arreglo data

    mov rdi,r12 ; rdi = a 

    call free ;free de la estructura
    ;epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret