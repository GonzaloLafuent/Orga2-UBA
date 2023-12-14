extern malloc
extern free
extern fprintf
extern stack_snooper
extern stack_snooper_n

section .data
nullstr: DB "NULL\0"

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a[rdi], char* b[rsi])
strCmp:
	xor rax,rax
	xor rcx,rcx ;contador para iterar por los strings
	;R8 = caracter de a
	;R9 = caracter de b
strCmp_equal:
	;MOV R8, [rdi + RCX * 8]
	;MOV R9, [rsi + RCX * 8]
	movzx R8,byte [rdi + RCX]
	movzx R9,byte [rsi + RCX]

	CMP r8, r9
	JNE strCmp_notEqual
	;son iguales
	CMP R8, 0
	JE strCmp_end

	ADD RCX,1
	JMP strCmp_equal
strCmp_notEqual:
	JG strCmp_a_greater ; a > b
	MOV RAX, 1
	JMP strCmp_end
strCmp_a_greater:
	MOV RAX, -1
strCmp_end:
	ret

; char* strClone(char* a[rdi])
strClone:
	;prologo
	push rbp
	mov rbp , rsp

	; push 0xf
	push RDI
	; mov rdi, 1
	; call stack_snooper_n wrt ..plt


	call strLen

	mov rcx, rax ; RCX = largo del string
	mov RDI, 1 
	add rdi, rcx ;rdi = largo del string + 1
	push rcx
	call malloc WRT ..plt
	pop rcx
	pop rdi ; en rdi esta el puntero al string original
	; en rax esta el puntero al nuevo string
	; RCX tiene el largo del string a copiar
	add RCX, 1
strClone_loop:
	sub rcx, 1
	mov sil, [rdi + RCX]
	mov [rax + RCX], sil
    CMP RCX,0
    JNE strClone_loop
	
	; add rbp, 0x08
	pop rbp
	ret


; void strDelete(char* a[rdi])
strDelete:
	push rbp
	mov rbp , rsp
	call free WRT ..plt
	pop rbp
	ret

; void strPrint(char* a[rdi], FILE* pFile)
; fprint(file,format)
strPrint:
	; epilogo
	push rbp
	mov rbp, rsp

	; chequeo si streing es vacio
	; cmp [rdi], 0
	; jne .novacia
	; ;es string vacio
	; mov rdi, [nullstr]

	; .novacia:
	mov rcx,rdi
	mov rdi,rsi
	mov rdi,rcx 
	call fprintf WRT ..plt 

	pop rbp

	ret

; uint32_t strLen(char* a[rdi])
strLen:
	push rbp
	mov rbp, rsp
	push 0xf
	push rdi
	mov rdi, 2
	call stack_snooper_n wrt ..plt
	pop rdi
	;Un poco falopa pero funciona(Tiene algo de sentido)
    xor rax,rax
	;mov rsi,[rdi]
    movzx si,byte [rdi]
    CMP si,0
    ;test sil,0
    JE strLen_end
strLen_loop:
    add ax,1
	;mov rsi, [rdi+rax*8] 
    movzx si,byte [rdi+rax]
    CMP si,0
    ;test sil,0
    jne strLen_loop
strLen_end:
	add rsp, 0x8
	pop rbp
    ret

