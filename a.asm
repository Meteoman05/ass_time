include console.inc

.data
	nil equ 0
	save dw 3737
	
	node struc
		sym db 0
		next dd nil
		prev dd nil
	node ends
	
	beg dd ?
	
.code

init proc ; eax на выход
	push ebp
	mov ebp, esp
	
	new sizeof node
	
	
	mov [eax].node.sym, 0
	mov [eax].node.prev, eax
	mov [eax].node.next, eax
	
	mov esp, ebp
	pop ebp
	ret

init endp



append proc ; L, el
	push ebp
	mov ebp, esp
	
	push eax
	push ebx
	push ecx
	push edx
	
	mov ecx, [ebp+10]
	mov ebx, [ecx].node.prev

	new sizeof node
	mov [ecx].node.prev, eax
	mov [ebx].node.next, eax
	mov dl, [ebp+8]
	mov [eax].node.sym, dl
	mov [eax].node.next, ecx
	mov [eax].node.prev, ebx
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	mov esp, ebp
	pop ebp
	ret 6

append endp


check proc ; L; res in eax
	push ebp
	mov ebp, esp
	
	push ebx
	push ecx
	push edx
	
	mov ebx, [ebp+8]
	mov ebx, [ebx].node.prev
	mov ecx, 5
	
	long:
		mov al, [ebx].node.sym
		cmp al, 0
		jz skp
		
		mov ebx, [ebx].node.prev
		loop long
	skp:
	
	mov eax, 0
	cmp ecx, 0
	jnz cont
	
	; начинаем проверять последние элементы на признак останова
	mov ebx, [ebp+8]
	mov ebx, [ebx].node.prev ; в ebx ссылка на последний элемент
	
	mov dl, [ebx].node.sym
	cmp dl, '@'
	je @F
	jmp cont
	
	@@:
	mov ebx, [ebx].node.prev
	mov dl, [ebx].node.sym
	cmp dl, '%'
	je @F
	jmp cont
	
	@@:
	mov ebx, [ebx].node.prev
	mov dl, [ebx].node.sym
	cmp dl, '#'
	je @F
	jmp cont
	
	@@:
	mov ebx, [ebx].node.prev
	mov dl, [ebx].node.sym
	cmp dl, '%'
	je @F
	jmp cont
	
	@@:
	mov ebx, [ebx].node.prev
	mov dl, [ebx].node.sym
	cmp dl, '@'
	je @F
	jmp cont
	
	@@:
	mov eax, 1 ; по умолчанию случился останов
	slash:
	mov ebx, [ebx].node.prev
	mov dl, [ebx].node.sym
	cmp dl, '\'
	jne cont
	
	xor eax, 1
	jmp slash
	
	cont:
	
	pop edx
	pop ecx
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 4




check endp


del proc ; eax - адрес звена, которое надо удалить
	push ebp
	mov ebp, esp
	
	push ebx
	push ecx
	push edx
	
	
	mov ebx, [eax].node.prev
	mov ecx, [eax].node.next
	
	dispose eax
	mov [ebx].node.next, ecx
	mov [ecx].node.prev, ebx
	
	
	
	pop edx
	pop ecx
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret


del endp

clear proc ; eax - адрес начала списка
	push ebp
	mov ebp, esp
	
	push ebx
	push ecx
	push edx
	
	mov edx, eax
	mov ecx, 5
	lp:
		mov eax, [edx].node.prev
		call del
		dec ecx
		cmp ecx, 0
		jnz lp
	
	

	pop edx
	pop ecx
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret

clear endp

start:
call init
mov ebx, eax

inp:
	push ebx
	call check
	cmp eax, 1
	je st2
	
	xor eax, eax
	inchar al
	push ebx
	push ax
	call append
	jmp inp
st2:

mov ecx, 5
mov beg, ebx
mov eax, beg
call clear




mov beg, ebx
mov ebx, [ebx].node.next
outp:
	mov al, [ebx].node.sym
	cmp al, 0
	jz fin
	outchar al
	
	mov ebx, [ebx].node.next
	jmp outp
	

fin:


newline
mov ebx, beg
push ebx
TotalHeapAllocated
outu eax
newline



	
exit
end start
