global temperature_asm

section .rodata

mask_a: dw -1,-1,-1,0,-1,-1,-1,0
coeficientes: dw 0

tres: dw 3,3,3,3

cuatro: dd 4,4,4,4

maskByte: db 255,255,255,255

mask128: dd 0,0,128,128

mask4: dd 0,0,4,4
section .text
;void temperature_asm(unsigned char *src [rdi],
;              unsigned char *dst [rsi],
;              int width [rdx],
;              int height [rcx],
;              int src_row_size [r8],
            ;  int dst_row_size [r9];

temperature_asm:
    ;prologo
	push rbp
	mov rbp,rsp
    
	xor r10, r10
	mov r10,rdx	 ; r10 = width
	imul r10,rcx ;obtengo la cantidad de pixeles = width * height = tamaño de la matriz
	shr r10,1   ;r10 contiene cantidad de iteraciones TOTALES de la imagen procesando de a 2 pixeles

    movq xmm2,[mask_a] ;xmm2 = tiene la mascara que anula la transparencia
    movq xmm1,[tres]
    ;xmm1=
    ;| 3[4bytes] | 3[4bytes] | 3[4bytes] | 3[4bytes] |
    cvtdq2ps xmm1, xmm1
    ;xmm1=
    ;| 3[4bytes/float] | 3[4bytes/float] | 3[4bytes/float] | 3[4bytes/float] |

.ciclo:

    movq xmm0,[rdi] ; traigo a xmm0 los primeros dos pixeles (8 bytes)

    pmovzxbw xmm0, xmm0 ; extiendo los 8 datos en byte a word
    ;xmm0=
    ;| B0[2bytes] | G0[2bytes] | R0[2bytes] | A0[2bytes] |
    ;| B1[2bytes] | G1[2bytes] | R1[2bytes] | A1[2bytes] | 
    pand xmm0,xmm2
    ;xmm0=
    ;| B0[2bytes] | G0[2bytes] | R0[2bytes] | 0 |
    ;| B1[2bytes] | G1[2bytes] | R1[2bytes] | 0 | 
    phaddw xmm0, xmm0
    ;xmm0=
    ;| (B0 + G0)[2bytes] | R0[2bytes] | (B1 + G1)[2bytes] | R1[2bytes] |
    ;| resto del registro = basura | 
    phaddw xmm0, xmm0
    ;xmm0=
    ;| (B0 + G0 + R0)[2bytes] | (B1 + G1 + R1)[2bytes] |
    ;| resto del registro = basura | 
    pmovzxbw xmm0, xmm0 ; extiendo los 2 datos en word a double word
    ;xmm0=
    ;| (B0 + G0 + R0)[4bytes/dword] | (B1 + G1 + R1)[dword/dword] |
    ;| resto del registro = basura | 
    cvtdq2ps xmm0, xmm0 ; convierto los valores dword a single precision float
    ;xmm0=
    ;| (B0 + G0 + R0)[4bytes/float] | (B1 + G1 + R1)[4bytes/float] |
    ;| resto del registro = basura | 
    divps xmm0, xmm1
    ;xmm0=
    ;| (B0 + G0 + R0)/3[4bytes/float] | (B1 + G1 + R1)/3[4bytes/float] |
    ;| resto del registro = basura | 

    call compare_t
    ;xmm0=
    ;| B0[1byte] | G0[1byte] | R0[1byte] | 255[1byte] |
    ;| B1[1byte] | G1[1byte] | R1[1byte] | 255[1byte] | 
    movq [rsi],xmm0 ; muevo 8 bytes al destino

    add rsi,8
    add rdi,8

    dec r10
    cmp r10,0
    jne .ciclo

    ;epilogo
    pop rbp

    ret

compare_t:
    ; ;xmm0=
    ; ;| (B0 + G0 + R0)/3[4bytes/dword] | (B1 + G1 + R1)/3[4bytes/dword] |
    ; ;| resto del registro = basura | 
    ; PEXTRD rax, xmm0, 0
    ; mov r11, 32
    ; ; r11 = (B0 + G0 + R0)/3 = tmp
    ; div r11
    
    ret
