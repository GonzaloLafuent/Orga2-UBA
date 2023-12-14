global miraQueCoincidencia

.rodata:
mask_mul: dd 0.114,0.587,0.299,0.0
mask_transparencia: dd 255,255,255,0

;########### SECCION DE TEXTO (PROGRAMA)
section .text
; rdi = *a , rsi = *b , rdx = n , rcx = *lacoindiencia 
miraQueCoincidencia:
    ;prologo
    push rbp
    mov rbp,rsp

    xor r10,r10
    imul rdx,rdx ; rdx = n*n cantidad de iteraciones

    .ciclo:
        ;inicializo los registros xmm que voy usar en 0
        pmovzxbd xmm0,[rdi] ;|a0 dd|b0 dd|g0 dd|b0 dd|                  
        pmovzxbd xmm1,[rsi] ;|a0' dd|b0' dd|g0' dd|b0' dd|

        pand xmm0,[mask_transparencia]
        pand xmm1,[mask_transparencia]

        movdqu xmm2,xmm0 ;lo guardo para no perderlo en la comparacion

        pcmpeqd xmm0,xmm1 ;xmm0 va la comparacion de 

        phaddd xmm0,xmm0 ;si cada valor b r g a son iguales,cada dd va dar -1 
        phaddd xmm0,xmm0 ;al a aplicar la suma horizontal dos veces nos va quedar la suma de esa comparacion
                          ;en el primer dd de xmm0, siendo igual a -4 si todos fueron iguales                         
        movd r10d,xmm0

        cmp r10d,-4   ;si fuera igual a 4 los valores b,g,r son iguales
        jne .blanco

        cvtdq2ps xmm2,xmm2 ;|a0 f|b0 f|g0 f|b0 f|

        mulps xmm2,[mask_mul] ;|0 f|b0*0.299 f|g0*0.587 f|b0*0.114 f| multiplicado por su respectivo valor

        haddps xmm2,xmm2
        haddps xmm2,xmm2  ;|basura|basura|basura|b0*0.299 f+g0*0.587 f+b0*0.114 f| 

        cvttps2dq xmm2,xmm2 ;|basura|basura|basura|b0*0.299 dd+g0*0.587 dd+b0*0.114 dd|
        movd r10d,xmm2     ; r10d =  b0*0.299 dd+g0*0.587 dd+b0*0.114 dd

        jmp .fin
    .blanco:
        mov r10b,byte 255
        jmp .fin
    .fin:
        mov [rcx],byte r10b  ;muevo el el pixel a coincidencia

        add rcx,1 ;paso al siguiente pixel

        add rdi,4 ;paso al siguiente pixel
        add rsi,4 ;paso al siguiente pixel

        dec rdx
        cmp rdx,0
        jne .ciclo

    ;epilogo
    pop rbp

    ret
