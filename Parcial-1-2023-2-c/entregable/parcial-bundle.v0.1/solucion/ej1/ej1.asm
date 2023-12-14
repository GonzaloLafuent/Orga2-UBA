section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp
;struct pago_t:
; |monto|aprobado | - | - | - |- | - | - |  (-=indica padding) 
; |       pagador                         | (pago_t = 24 bytes)
; |       cobrador                        | 
%define OFFSET_MONTO 0                  
%define OFFSET_APROBADO 1               
%define OFFSET_PAGADOR 8
%define OFFSET_COBRADOR 16
%define SIZE_PAGO 24

;struct pagoSplitted_t:
; |cant_probados|cant_rechazados| - | - | - |- | - | - |  (-=indica padding) 
; |       aprobados                                    |   (pago_spltted = 24 bytes)
; |       rechazados                                   | 
%define OFFSET_CANT_APROBADOS 0
%define OFFSET_CANT_RECHAZADOS 1
%define OFFSET_APROBADOS 8
%define OFFSET_RECHAZADOS 16
%define SIZE_SPLITTED 24

;extra:
%define SIZE_POINTER 8
;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; parametros: rdi = plist, rsi = usuario
contar_pagos_aprobados_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12    ;los pusheo para preservalos    
    push r13
    push r14
    push r15

    mov r12,rdi ; r12 = plist 
    mov r13,rsi ; r13 = usuario
                ; los guardo aca para no perderlos frente a las llamdas a strcmp que voy hacer
                ; mas adelantee

    ;incializo registros temporales en 0 para usarlos comno temporales            
    xor r10,r10 ; r10 = guarda pago en cada iteracion  
    xor r8,r8   ; r8 = guarda el valor de aprobaddo en cada iteracion
    xor r14,r14 ; r14 = contador de pagos aprobados 

    mov r12,[r12] ;accedo a first de la lista
    .ciclo:
        mov r10,[r12] ; r10 = pago

        mov r8b, byte [r10 + OFFSET_APROBADO]   ;veo si el pago es aprobado
        cmp r8,1                                ;si lo es, veo si el cobrador es igual al pasado por parametro
        jne .sigo                               ;sino sigo

        mov rdi,[r10+OFFSET_COBRADOR]           ;obtengo el cobrador y lo paso a rdi, 
        mov rsi,r13                             ;paso el usario a rsi para poder llamar a strcmp con los parmetros ordenados 
        call strcmp                             ;veo si el cobrador es igual usuario pasado por parametro

        cmp al,0                                ;si strcmp es igual a cero los string son iguales, por lo tanto es el usuario que buscabamos
        jne .sigo                               ;sino sigo con el ciclo
        inc r14  
        .sigo:
            mov r12,[r12 + 8]                  ;paso al siguiente pago
            cmp r12,0                          ;si el pago siguiente es null o 0 ya no tengo mas que recorrer,por lo tanto salgo del ciclo
            jne .ciclo

    mov rax,r14 ;muevo la cantidad de pagos aprobados al registro de retorno
    ;epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13
    push r14
    push r15
    ;///////////////////

    mov r12,rdi ; r12 = plist
    mov r13,rsi ; r13 = usuario para no perderlo frente a la llamda de strcmp

    xor r10,r10 ; r10 lo voy usar para recibir el pago 
    xor r8,r8   ; r8 recibe el valor de aprobado de determinado pago
    xor r14,r14 ; r14 = contador de pagos aprobados 

    mov r12,[r12] ;accedo a first de la lista
    .ciclo:
        mov r10,[r12] ; r10 = pago

        mov r8b, byte [r10 + OFFSET_APROBADO]   ;veo si el pago es no esta aprobado
        cmp r8,0                                ;si lo es veo si el cobrador es igual al pasado por parametro
        jne .sigo                               ;sino sigo

        mov rdi,[r10+OFFSET_COBRADOR]           ;obtengo el cobrador y lo paso a rdi
        mov rsi,r13                             ;paso el usario a rsi para llamar a strcmp con el usuario dado y el cobrado de ese pago
        call strcmp                             ;veo si el cobrador es igual usuario pasado por parametro

        cmp al,0                                ;si strcmp es igual a cero los string son iguales
        jne .sigo                               ;sino sigo con el ciclo
        inc r14  
        .sigo:
            mov r12,[r12 + 8]                  ;paso al siguiente pago
            cmp r12,0                          ;si el pago siguiente es null o 0 ya no tengo mas que recorrer
            jne .ciclo

    mov rax,r14                               ;muevo el valor del contador a el registro de salida
    ;epilogo

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
; parametros rdi = pList  , rsi = usuario
split_pagos_usuario_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13
    push r14
    push r15 
    push rbx
    sub rsp,8
    ;//////////////////////////////////////////////

    mov r12,rdi ; r12 = plist  para no perderlos en llamadas a funciones externas
    mov r13,rsi ; r13 = usuario

    xor rdi,rdi
    mov rdi,SIZE_SPLITTED  ;llamo a malloc con el tamaño de el pago splitted, para reservar memoria para el puntero a retornar
    call malloc
    mov r14,rax            ;guardo el puntero de del pago splitted en r14 para no perderlo por llamadas a funciones externas

    mov rdi,r12          ; rdi = plist                      
    mov rsi,r13          ; rsi = usuario, para ver la cantidad de pagos aprobados en la lista por ese cobrador

    call contar_pagos_aprobados_asm                 ;veo los pagos aprobado de ese cobrador en esa lista
    mov byte [r14 + OFFSET_CANT_APROBADOS], al      ;inserto la cantidad en el pago splited declarado

    xor rdi,rdi
    mov dil,al                 ;pongo en rdi la cantidad de aprobado y lo mulplico por el tamaño del puntero
    imul rdi,SIZE_POINTER      ;para obtener la cantidad de memoria necesaria para guardar el puntero de pagos aprobados
    call malloc                ;apartir de la llamada a malloc

    mov [r14 + OFFSET_APROBADOS],rax   ;guardo el puntero de pagos aprobados en el splitted

    mov rdi,r12         ;rdi = plist
    mov rsi,r13         ;rsi = usuario, para llamar a la funciones de cantidad de pagos rechazados con esa lista y ese usuario
    call contar_pagos_rechazados_asm                        ;veo los pagos rechazados de ese cobrador en esa lista
    mov byte [r14 + OFFSET_CANT_RECHAZADOS], al             ;inserto la cantidad en el pago splited declarado

    xor rdi,rdi
    mov dil,al                 ;pongo en rsi la cantidad de rechazados y lo mulplico por el tamaño del puntero
    imul rdi,SIZE_POINTER      ;para obtener loa cantidad de memoria necesaria para guardar el puntero pagos rechazados
    call malloc

    mov [r14 + OFFSET_RECHAZADOS],rax   ;guardo el puntero de pagos aprobados en el splitted

    ;hasta este punto tengo definido mi puntero a pago splitted con la cantidad de pagos aprobados, la cantidad de pagos rechazados
    ;el puntero a los pagos aprobados y al de pagos rechazados, ahora nos quedaria pasar cada pago aprobado o rechazado en el pago splitted

    ;incializo estos registros en cero para no tener inconvenientes
    xor r8,r8    ; r8 = recibe si el pago esta aprobado o no
    xor r9,r9    ; r9 = lo uso para obtener el puntero a los apgos rechazados o aprobados
    xor r10,r10  ; r10 = recibe el pago en cada iteracion

    xor r15,r15  ; r15 = lo uso para moverme en el array de pagos rechazados
    xor rbx,rbx  ; rbx = lo uso para movermee en el array de pagos aprobados


    mov r12,[r12] ;accedo a first de la lista
    .ciclo_split:
        mov r10,[r12] ; r10 = pago

        mov rdi,[r10 + OFFSET_COBRADOR]         ; obtengo el cobrador
        mov rsi,r13                             ; paso el usario a rsi
        call strcmp                             ; veo si el cobrador del pago de la lista es similar al pasado por parametro
        cmp al,0                                ; si los string no son iguales paso al proximo pago
        jne .sigo_split

        mov r8b, byte [r10 + OFFSET_APROBADO]   ;si el cobrado es igual al usuario sigo por aca
                                                ;veo si el pago es rechazado o aprobado
        cmp r8b,0                               ;si da 1 voy a .aprobado, sino a .rechazado para ver en que puntero inserto el pago
        jne .aprobado
        .rechazado:
            mov r9,[r14 + OFFSET_RECHAZADOS]    ;obtengo el puntero de rechazados
            mov [r9 + r15*SIZE_POINTER],r10     ;guardo el pago en el array
            inc r15                             ;uso r15 para irme moviendo dentro del puntero de rechazados
            jmp .sigo_split
        .aprobado:
            mov r9,[r14 + OFFSET_APROBADOS]    ;obtengo el puntero de aprobados
            mov [r9 + rbx*SIZE_POINTER],r10    ;guardo el pago en el array
            inc rbx                            ;uso rbx para irme moviendo dentro del puntero de aprobados
        .sigo_split:
            mov r12,[r12 + 8]                  ;paso al siguiente pago
            cmp r12,0                          ;si el pago siguiente es null o 0 ya no tengo mas que recorrer
            jne .ciclo_split                   ;salgo del ciclo

    mov rax,r14      ;devuelvo el puntero a pago splited

    ;epilogo
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret

