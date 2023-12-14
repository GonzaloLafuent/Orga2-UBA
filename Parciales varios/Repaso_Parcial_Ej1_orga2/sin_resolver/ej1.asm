global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;<<<REMOVE>>>
extern acumuladoPorCliente
extern en_blacklist
extern blacklistComercios
;<<<REMOVE END>>>

acumuladoPorCliente_asm:
;<<<REMOVE>>>
    jmp acumuladoPorCliente
;<<<REMOVE END>>>
	ret

en_blacklist_asm:
;<<<REMOVE>>>
    jmp en_blacklist
;<<<REMOVE END>>>
	ret

blacklistComercios_asm:
;<<<REMOVE>>>
    jmp blacklistComercios
;<<<REMOVE END>>>
	ret
