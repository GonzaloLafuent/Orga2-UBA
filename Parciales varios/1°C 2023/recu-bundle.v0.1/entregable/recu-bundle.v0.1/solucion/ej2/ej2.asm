global maximosYMinimos_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;voy a trabajar 
mask_byte: db 0,4,8,15,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
;parametros:
;rdi = *src , rsi = *dst , rdx = width , rcx = height  
maximosYMinimos_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    ;inicializo registros que voy a usar en 0
    xor r8,r8
    xor r9,r9
    xor r10,r10
    xor r11,r11
    xor rax,rax
    ;calculo la cantidad de iteraciones
    mov r10,rdx
    imul r10,rcx

    ;r11 lo uso para ver si la fila es par o impar
    mov r11,1 

    dec rcx
    dec rdx
    .ciclo:
        ;carga el primer pixel de cada puntero
        pmovzxbd xmm0,[rdi]

        ;inicializaco registros en xmm en 0
        pxor xmm1,xmm1
        pxor xmm2,xmm2
        pxor xmm3,xmm3

        ;inserto cada valor de rgb en unn registro nuevo 
        pshufd xmm1,xmm0,0b00000000 ; xmm1 = |b|b|b|b|
        pshufd xmm2,xmm0,0b01010101 ; xmm1 = |r|r|r|r|
        pshufd xmm3,xmm0,0b10101010 ; xmm1 = |g|g|g|g|

        ;en r8 vamos a llevar el valor de la columna iterada
        ;en r9 vamos a llevar el valor de la fila iterada 
        ;para ver si es par o no, hacemos un and con 1
        ;si el and da 0 es que es par, si da 1 es impar
        
        ;veo si la columna es par
        and r11,r8  ;si no lo es salto a impar y calculo el valor de pixel
        cmp r11,0   ;r11 no permite ver si es par apartir de un and
        mov r11,1   ;como lo puedo perder lo vuelvo a reinciar en 1 para que no falle
        jne .impar
        .par:
            ;si es par calculo el maximo
            pmaxud xmm1,xmm2  ; xmm1 = |/|/|/|max(b,r)|
            pmaxud xmm1,xmm3  ; xmm1 = |/|/|/|max(b,r,g)|
            movd eax,xmm1
            jmp .cambio_filCol
        .impar:
            pminud xmm1,xmm2  ; xmm1 = |/|/|/|min(b,r)|
            pminud xmm1,xmm3  ; xmm1 = |/|/|/|min(b,r,g)|
        .cambio_filCol:
            ;veo si la cantidad de columnas que recorri es igual a width
            cmp r8,rdx ; si columnas recorridas = width
            je .cambioFila ;si ya recorri todas las columnas cambio de fila
            inc r8         ;incremento para pasar a la siguiente columna
            jmp .guarda
        .cambioFila
            inc r9  ;incremento el valor de la fila
            xor r8,r8 ;inicializo en 0 la cantidad de columnas
        ;guarda del ciclo
        .guarda:
            ;muevo el valor al destino
            pshufb xmm1,[mask_byte]
            movd [rsi],xmm1
            add rsi,4 ;paso al sigueinte pixel
            add rdi,4
            ;decremento el iterador    
            dec r10
            cmp r10,0
            jne .ciclo

    ;epilogo
    pop rbp

    ret