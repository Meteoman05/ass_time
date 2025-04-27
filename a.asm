include console.inc

.data
	stop dd '%#%@'
	bordword db "!?,;:'()[].", '"', 32, 9, 10, 13 ; 16
	slst struc
		s db 0
		next dd 0
	slst ends
	
	len dd 0
	lst dd ?
	arr dd ?
	
	wlst struc
		wrd dd 0
		freq dd 0
		next dd 0
		prev dd 0
	wlst ends
	
	

.code
inits proc ;(link_len_lst) -> eax
	push ebp
	mov ebp, esp
	mov edx, [ebp+8]
	new sizeof slst
	mov dword ptr [edx], 0
	mov esp, ebp
	pop ebp
	ret 4
inits endp

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
		cmp ebx, 0
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
		cmp ebx, 0
		jnz @b
	dispose ebx
	assume ebx:nothing
	pop esi
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
lst_to_arr endp

print proc ; (link_str)
	; normal variant of OUTSTR
	push ebp
	mov ebp, esp
	
	mov eax, [ebp+8]
	mov ecx, 0
	@@:
		mov dl, [eax+ecx]
		cmp dl, 0
		jz @f
		
		outchar dl
		inc ecx
		jmp @b
	@@:
	
	mov esp, ebp
	pop ebp
	ret 4
print endp

putw proc ; (link_lst, link_word)
	push ebp
	mov ebp, esp
	
	push ebx
	push esi
	push edi
	cld
	
	assume ebx:ptr wlst
	mov ebx, [ebp+8]
	mov edx, [ebp+12]
	lp:
		cmp [ebx].wrd, 0
		jz new_word
		
		mov esi, edx
		mov edi, [ebx].wrd
		
		mov eax, 1
		check:
			cmp byte ptr [esi], 0
			jz cont
			cmp byte ptr [edi], 0
			jz cont
			
			cmpsb
			jz check
			mov eax, 0
		cont:
		test eax, eax
		jnz old
		mov ebx, [ebx].next
		jmp lp
	old:
	inc dword ptr [ebx].freq
	jmp fin
	new_word:
	mov [ebx].wrd, edx
	mov [ebx].freq, 1
	
	new sizeof wlst
	mov [ebx].next, eax
	mov [eax].wlst.prev, ebx
	mov [eax].wlst.next, 0
	mov [eax].wlst.wrd, 0
	mov [eax].wlst.freq, 0
	
	fin:
	assume ebx:nothing
	pop edi
	pop esi
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
putw endp

outwlst proc ; (link_lst)
	push ebp
	mov ebp, esp
	
	push ebx
	assume ebx:ptr wlst
	mov ebx, [ebp+8]
	mov ecx, 0
	@@:
		cmp [ebx].wrd, 0
		jz @f
		
		outu dword ptr [ebx].freq
		outchar ' '
		push [ebx].wrd
		call print
		newline
		
		mov ebx, [ebx].next
		jmp @b
	@@:
	assume ebx:nothing
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 4
outwlst endp


isbord proc ; (sym) -> eax
	push ebp
	mov ebp, esp
	
	push edi
	mov edx, 0
	cld
	lea edi, bordword
	mov eax, [ebp+8]
	mov ecx, 16
	repne scasb
	jnz @f
	mov edx, 1
	@@:
	mov eax, edx
	
	pop edi
	
	mov esp, ebp
	pop ebp
	ret 4
isbord endp

find_word proc ; (link_str) -> edx:eax
	; edx - link to next sym after word or 0 (if end of global string)
	; eax - link to word
	push ebp
	mov ebp, esp
	
	push ebx
	
	mov ebx, [ebp+8]
	@@:
		movzx eax, [ebx]
		push eax
		call isbord
		


find_word endp
start:
push offset len
call inits
mov lst, eax

push offset len
push lst
call input

mov eax, lst
mov al, [eax].slst.s
test al, al
jz ERR

newline
newline
push lst
call outlst
newline
newline
push len
push lst
call lst_to_arr
mov arr, eax

push arr
call print

newline
outstrln 'All is ok'
exit 0
ERR:
	outstrln 'Illegal input!!!'
	exit -1
end start