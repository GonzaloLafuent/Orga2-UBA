extern malloc
global filtro

;########### SECCION DE DATOS
section .rodata
mask_shuf2: db 14,15,12,13,10,11,8,9,14,15,12,13,10,11,8,9

mask_shuf1: db 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
mask_shuf3: db 8,9,10,11,12,13,14,15,8,9,10,11,12,13,14,15

mask_mul1: dw -1,-1,-1,-1,1,1,1,1

mask_mul2: dw 1,1,1,1,-1,-1,-1,-1
;########### SECCION DE TEXTO (PROGRAMA)
section .text
;tengo que devolver un puntero con la misma cantidad de elemento que el de entrada
;int16_t* operaciones_asm (const int16_t* entrada, unsigned size)
;parametros: rdi = int16_t* , rsi = size  
filtro:
    ;prologo
    push rbp
    mov rbp,rsp 

    push r12
    push r13

    mov r12,rdi ;guardo en r1= int16_t* en r13 size
    mov r13,rsi ;para no perderlos en la llamada a malloc

    shr r13,3

    mov rdi,rsi ;le asigno a rdi la cantidad de elementos del arreglo del parametro
    imul rdi,2 ;lo multplico por el tamaño del dato, en este caso 2 bytes(16 bits)
    call malloc ;recibo en rax el puntero que voy a devolver 

    movdqu xmm4,[mask_shuf1]
    movdqu xmm5,[mask_shuf2]
    movdqu xmm6,[mask_shuf3]
    movdqu xmm7,[mask_mul1]
    movdqu xmm8,[mask_mul2]

    xor r8,r8 ;guardo el puntero en r8 para poder iterar sobre el sin modificar su direccion de salida  
    mov r8,rax
.ciclo:
    movdqu xmm0,[r12] ; xmm0 = |e[7]|e[6]|e[5]|e[4]||e[3]|e[2]|e[1]|e[0]|, cada espacio son 4 bytes
    movdqu xmm1,xmm0 ; xmm1 = xmm0
    movdqu xmm2,xmm0 ; xmm2 = xmm0

    pshufb xmm0,xmm4 ; xmm0 = |e[3]|e[2]|e[1]|e[0]|e[3]|e[2]|e[1]|e[0]|
    movdqu xmm3,xmm0 ; xmm3 = |e[3]|e[2]|e[1]|e[0]|e[3]|e[2]|e[1]|e[0]|
    pshufb xmm1,xmm5 ; xmm1 = |e[4]|e[5]|e[6]|e[7]|e[4]|e[5]|e[6]|e[7]|                                           
    pshufb xmm2,xmm6 ; xmm2 = |e[7]|e[6]|e[5]|e[4]|e[7]|e[6]|e[5]|e[4]|
    
    pmullw xmm2,xmm7  ; xmm2 = |e[7]|e[6]|e[5]|e[4]|-e[7]|-e[6]|-e[5]|-e[4]|
    pmullw xmm1,xmm8  ; xmm1 = |-e[4]|-e[5]|-e[6]|-e[7]|e[4]|e[5]|e[6]|e[7]|

    paddw xmm0,xmm1 ; xmm0 = |e[3]-e[4]|e[2]-e[5]|e[1]-e[6]|e[0]-e[7]|e[3]+e[4]|e[2]+e[5]|e[1]+e[6]|e[0]+e[7]|
    paddw xmm3,xmm2 ; xmm1 = |e[3]+e[7]|e[2]+e[6]|e[1]+e[5]|e[0]+e[4]|e[3]-e[7]|e[2]-e[6]|e[1]-e[5]|e[0]-e[4]|

    pmullw xmm0,xmm3 

    movdqu [r8],xmm0
    add r8,16
    add r12,16
    
    dec r13
    cmp r13,0
    jne .ciclo

    ;epilogo
    pop r13
    pop r12
    pop rbp

    ret