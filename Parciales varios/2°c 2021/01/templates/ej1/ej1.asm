global agrupar

%define OFFSET_TEXT 0
%define OFFSET_TEXT_LEN 8
%define OFFSET_TAG 16
%define OFFSET_MSG 24

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
;rdi = msg_arr , rsi = array_len
section .text
agrupar:
    ;prologo
    push rbp
    mov rbp,rsp
.ciclo: 
    
    ;epilogo
    pop rbp

    ret


