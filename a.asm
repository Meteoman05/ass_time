include console.inc

.data
	nil equ 0
	save dw 3737
	
	node struc
		sym db 0
		next dd nil
		prev dd nil
	node ends
	
	L node <>
	
.code
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
	mov [eax].node.next, nil
	mov [eax].node.prev, ebx
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	mov esp, ebp
	pop ebp
	ret 6

append endp


check proc ; L
	push ebp
	mov ebp, esp
	
	push eax
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
	
	cmp ecx, 0
	jz ok
	outstr "Not ok"
	ok:
	outstr "Ok"
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
	mov esp, ebp
	pop ebp
	ret 4




check endp

start:
mov ebx, offset L
mov L.prev, ebx


inp:
	xor eax, eax
	inchar al
	cmp al, '.'
	je st2
	
	
	push ebx
	push ax
	call append
	jmp inp
st2:


outp:
	mov al, [ebx].node.sym
	outchar al
	
	mov eax, [ebx].node.next
	cmp eax, 0
	jz fin
	
	mov ebx, eax
	jmp outp
	

fin:


newline
mov ebx, offset L
push ebx
call check
newline



	
exit
end start
