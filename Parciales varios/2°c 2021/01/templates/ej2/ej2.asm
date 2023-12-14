extern malloc
global filtro

;########### SECCION DE DATOS
section .data
MASK_SHUF1: db 0,1,4,5,8,9,12,13,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff 
MASK_MUL: dd 0.25,0.25,0.25,0.25
MASK_SHUF3 db 2,3,6,7,10,11,14,15,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
MASK_SHUF2: db 0,1,4,5,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
MASK_SHUF: db 0,1,4,5,8,9,12,13,2,3,6,7,10,11,14,15
MASK_SHUF4: db 0,1,4,5,8,9,12,13,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;int16_t* filtro (const int16_t* entrada, unsigned size)
;parametros rdi = entrada, rsi = size
filtro:
    ;prologo   
    push rbp
    mov rbp,rsp
    push r12
    push r13

    mov r12,rdi ; r12 = entrada
    mov r13,rsi ; r13 = size

    xor r8,r8
    xor r9,r9

    mov rdi,rsi ;lo muevo para calcular el espacio de memoria a retornar
    sub rdi,3   ;le resto 3 por los valores que no van a ir al retorno
    sal rdi,2   ;multiplico por dos por que voy a guardar 4 bytes 

    call malloc ;en rax tenemos el puntero a retornar  
    mov r9,rax

    ;movdqu xmm1,[MASK_SHUF]
    movdqu xmm1,[MASK_SHUF1]
    movdqu xmm2,[MASK_MUL]
    movdqu xmm3,[MASK_SHUF2]
    movdqu xmm4,[MASK_SHUF3]
    movdqu xmm6,[MASK_SHUF4]

    sub r13,3  ;en r13 llevo la cantidad de iteraciones
.ciclo:
    movdqu xmm0,[r12] ;|l3|r3|l2|r2|l1|r1|l0|r0|
    movdqu xmm5,xmm0

    pshufb xmm0,xmm1 ;|basura|r3|r2|r1|r0|
    pshufb xmm5,xmm4 ;|basura|l3|l2|l1|l0|

    pmovzxwd xmm0,xmm0 ; |rr3|r2|r1|r0|
    pmovzxwd xmm5,xmm5 ; |l3|l2|l1|l0|

    cvtdq2ps xmm0,xmm0
    cvtdq2ps xmm5,xmm5

    mulps xmm0,xmm2
    mulps xmm5,xmm2

    haddps xmm0,xmm0
    haddps xmm0,xmm0

    haddps xmm5,xmm5
    haddps xmm5,xmm5    

    cvttps2dq xmm0,xmm0
    cvttps2dq xmm5,xmm5

    ;pshufb xmm0,xmm6
    ;pshufb xmm5,xmm6

    ;phaddw xmm0,xmm0
    ;phaddw xmm0,xmm0

    ;phaddw xmm5,xmm5
    ;phaddw xmm5,xmm5

    pextrw r8d,xmm5,0
    pinsrw xmm0,r8w,1
    ;psraw xmm0, 2

    ;phaddsw xmm0,xmm0
    ;phaddsw xmm0,xmm0 ;|basura|l0+l1+l2+l3|r0+r1+r2+r3|

    ;pmovzxwd xmm0,xmm0 ;|basura|l0+l1+l2+l3 4bytes|r0+r1+r2+r3 4bytes|

    ;cvtdq2ps xmm0,xmm0 ;|basura|l0+l1+l2+l3 float|r0+r1+r2+r3 float|

    ;mulps xmm0,xmm2 ;|basura|(l0+l1+l2+l3)*1/4 float|(r0+r1+r2+r3)*1/4 float|

    ;cvttps2dq xmm0,xmm0 ;|basura|(l0+l1+l2+l3)*1/4 4bytes|(r0+r1+r2+r3)*1/4 4bytes|
    
    ;pshufb xmm0,xmm3

    movd r8d,xmm0
    mov dword [r9],r8d

    add r12,4
    add r9,4
    dec r13
    cmp r13,0
    jne .ciclo
    ;epilogo
    pop r13   
    pop r12
    pop rbp

    ret