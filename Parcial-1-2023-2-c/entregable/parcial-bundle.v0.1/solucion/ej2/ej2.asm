global mezclarColores

section .data
mask_transparencia: dd 255,255,255,0  ;anula el valor de transparencia 

mask_retorno: db 0,4,8,12,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff ;me permite reordenar los bytes para que el pixel vuelva 
                                                                                      ;a tener todos sus componenetes del tamaño determinado  
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);

;parametros rdi = x, rsi = y , rdx = wdith , rcx = height

;voy a trabajar de a un pixel a la vez extendiendo cada valor a a 32 bits, por lo tanto la cantidad
;de iteraciones sera igual a height*width
mezclarColores:
    ;prologo
    push rbp
    mov rbp,rsp

    xor r8,r8        ;los inicializo en cero para no tener inconvenientes
    xor r9,r9        ;r8 lo voy usar para llevar a cabo el control de las iteraciones
                     ;mientras que r9 lo voy usar para llevar a cabo comparaciones 

    mov r8,rdx       ;r8 tiene la cantidad de iteraciones
    imul r8,rcx
    .ciclo:
        pmovzxbd xmm0,[rdi]            ;xmm0 = | a | r | g | b | 4 bytes cada uno
        pand xmm0,[mask_transparencia] ;anulo el valor de transparencia ;xmm0 = | 0 | r | g | b |

        movdqu xmm4,xmm0               ;lo guardo para para el modificarlo a la hora de retornar    

        pshufd xmm1,xmm0,0b0100 ;xmm1 = | x | x | g | b | 4 bytes cada uno
        pshufd xmm2,xmm0,0b1001 ;xmm2 = | x | x | r | g | 4 bytes cada uno 

        movdqu xmm3,xmm1    ;xmm3 = | x | x | g | b | 4 bytes cada uno

        pcmpgtd xmm1,xmm2  ;xmm1 = | x | x | g>r | b>g |   4 bytes cada uno

        phaddd xmm1,xmm1   ;xmm1 = | x | x | x |g>r+b>g|   4 bytes cada uno 
                           ;de ser verdadera la desigualdad planteada, el registro quedaria igual a
                           ;xmm1 = |x|x|-1|-1|, por lo que al hacer una suma horizontal obtengo
                           ;xmm1 = |x|x|x|-2|

        movd r9d,xmm1      ;lo uso para comparar, r9d tiene del dw menos significativo de xmm1
        cmp r9d,-2         ;si la desigualdad se cumple salto al caso 2
        je .caso2

        pcmpgtd xmm2,xmm3 ; xmm2 = | x | x | r>g | g>b | 4 bytes cada uno
                          ; de ser verdadera la desigualdad, el registro queda como
                          ; xmm2 = |x|x|-1|-1|, por lo que al hacer una suma horizontal obtengo
                          ; xmm2 = |x|x|x|-2|
        phaddd xmm2,xmm2
        movd r9d,xmm2     ;veo si la dw del xmm2 es igual a -2
        cmp r9d,-2        ;de serlo salto al caso 1
        je .caso1
      
        jmp .sigo
        ;caso 1 = r >g > b
        .caso1:
            pshufd xmm0,xmm4,0b001001  ; xmm0 = |0|b|r|g|, los ordeno de acuerdo a la condicion pedida
            jmp .sigo
        ;caso 2 = r > g > b
        .caso2:
            pshufd xmm0,xmm4,0b010010      ; xmm0 = |0|g|b|r|, con esto logro dejarlo ordenados de acuerdo a la condicion pedida
            jmp .sigo    
        .sigo:
            pand xmm0,[mask_transparencia]  ;anulo nuevamente la transparencia para que no me quede en el resultado
            pshufb xmm0,[mask_retorno]      ;xmm0 = |x|x|x|x|0rgb|, aplico un shuffle para volvfer a tener el pixel en su tamaño normal
            movd [rsi],xmm0                 ;donde cada componente ocupa un byte

            add rsi,4                       ;paso al siguiente tanto en x como en y
            add rdi,4

            dec r8                          ;decremento la cantidad de iteraciones y veo si llegue a la ultima o no
            cmp r8,0                        ;en caso de que no vuelvo al ciclo
            jne .ciclo

    ;epilogo
    pop rbp

    ret

