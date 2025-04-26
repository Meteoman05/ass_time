include console.inc

.data
	stop dd '%#%@'
	slst struc
		s db 0
		next dd 0
	slst ends
	len dd 0
	lst dd ?
	arr dd ?
	
	

.code
init proc ;(link_len_lst) -> eax
	push ebp
	mov ebp, esp
	mov edx, [ebp+8]
	new sizeof slst
	mov dword ptr [edx], 0
	mov esp, ebp
	pop ebp
	ret 4
init endp

append proc ;(link_lst, link_len_lst, sym)
	push ebp
	mov ebp, esp
	
	push ebx
	
	mov ebx, [ebp+8]
	mov ecx, [ebp+12]
	mov ecx, [ecx]
	assume ebx:ptr slst
	jecxz skp
	@@:
		mov ebx, [ebx].next
		dec ecx
		cmp ecx, 0
		jnz @b
	skp:
	mov edx, [ebp+16]
	mov [ebx].s, dl
	new sizeof slst
	mov [ebx].next, eax
	
	mov ecx, [ebp+12]
	inc dword ptr [ecx]
	
	assume ebx:nothing
	pop ebx
	mov esp, ebp
	pop ebp
	ret 3*4
append endp

outlst proc ;(link_lst)
	push ebp
	mov ebp, esp
	
	push ebx
	
	mov ebx, [ebp+8]
	
	assume ebx:ptr slst
	@@:
		mov al, [ebx].s
		outchar al
		mov ebx, [ebx].next
		cmp [ebx].next, 0
		jnz @b
	
	assume ebx:nothing
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 4
outlst endp

readi proc ;(buffer1, buffer2) -> edx:eax
	push ebp
	mov ebp, esp
	push ebx
	
	mov eax, [ebp+8]
	mov edx, [ebp+12]
	
	shld edx, eax, 8
	and edx, 0FFFFh
	shl eax, 8
	inchar al
	
	cmp dl, '@'
	je sus
	jmp @f
	sus:
	cmp eax, stop
	je amogus
	jmp @f
	amogus:
	cmp dh, '\'
	je psi
	xor eax, eax
	mov al, dh
	mov edx, 080000000h
	jmp fin
	
	psi:
	mov edx, 07FFFFFFFh
	jmp fin
	
	@@:
	cmp ax, '\\'
	jne fin
	mov al, 0
	
	fin:
	xor ebx, ebx
	shld ebx, eax, 16

	pop ebx
	mov esp, ebp
	pop ebp
	ret 2*4
readi endp

input proc ; (link_lst, link_len_lst)
	push ebp
	mov ebp, esp
	
	push ebx
	push esi
	
	mov eax, 0
	mov ebx, [ebp+8]
	mov ecx, 0
	mov edx, 0
	
	inp:
		push edx
		push eax
		call readi
		
		cmp edx, 080000000h
		je final
		
		cmp edx, 07FFFFFFFh
		je psfin
		
		cmp dh, 0
		jz cont
		
		movzx esi, dh
		push eax
		push edx
		push esi
		push [ebp+12]
		push [ebp+8]
		call append
		pop edx
		pop eax
		inc ecx
		jmp cont
		
		psfin:
		mov esi, '@'
		push esi
		push [ebp+12]
		push [ebp+8]
		call append
		mov esi, '%'
		push esi
		push [ebp+12]
		push [ebp+8]
		call append
		mov esi, '#'
		push esi
		push [ebp+12]
		push [ebp+8]
		call append
		mov esi, '%'
		push esi
		push [ebp+12]
		push [ebp+8]
		call append
		mov esi, '@'
		push esi
		push [ebp+12]
		push [ebp+8]
		call append

		
		mov eax, 0
		mov edx, 0
		
		cont:
		jmp inp
	
	final:
	cmp al, 0
	jz @f
	
	movzx esi, al
	push esi
	push [ebp+12]
	push [ebp+8]
	call append
	
	@@:
	pop esi
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
input endp

lst_to_arr proc ;(link_lst, len_lst) -> eax
	push ebp
	mov ebp, esp
	
	push ebx
	push esi
	
	mov esi, 0
	mov ebx, [ebp+8]
	mov ecx, [ebp+12]
	inc ecx
	new ecx
	mov ecx, 0
	
	
	assume ebx:ptr slst
	@@:
		mov dl, [ebx].s
		mov [eax+ecx], dl
		mov esi, [ebx].next
		dispose ebx
		mov ebx, esi
		inc ecx
		cmp [ebx].next, 0
		jnz @b
	dispose ebx
	assume ebx:nothing
	pop esi
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
lst_to_arr endp
start:
push offset len
call init
mov lst, eax


push offset len
push lst
call input

push lst
call outlst
newline

push len
push lst
call lst_to_arr

outstr eax
newline
exit 0
end start