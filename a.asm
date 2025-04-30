include console.inc

.data
	stop dd '%#%@'
	bordword db "!?,;:'()[].", '"', 32, 9, 10, 13, 0 ; 16
	latin db "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",0
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
	
	wordlst wlst <>
	wlen dd 0
	
	

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


putw proc ; (link_lst, link_word) -> eax
	; eax - 1, if word was in list
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
		push edx
		mov edx, 0
		mov dl, byte ptr [esi]
		mov dh, byte ptr [edi]
		add dl, dh
		cmp dl, 0
		jz @f
		mov eax, 0
		@@:
		pop edx
		
		test eax, eax
		jnz old
		mov ebx, [ebx].next
		jmp lp
	old:
	inc dword ptr [ebx].freq
	mov eax, 1
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
	mov eax, 0
	
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


ispat proc ; (sym, pattern) -> eax
	push ebp
	mov ebp, esp
	
	push ebx
	push edi
	mov edx, 0
	cld
	
	mov ecx, 0
	mov ebx, [ebp+12]
	@@:
		cmp byte ptr [ebx+ecx], 0
		jz @f
		
		inc ecx
		jmp @b
	@@:
	

	mov edi, ebx
	mov eax, [ebp+8]
	repne scasb
	jnz @f
	mov edx, 1
	@@:
	mov eax, edx
	
	pop edi
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
ispat endp


find_pat proc ; (link_str, pattern) -> eax
	; eax - link to next sym after first sym
	push ebp
	mov ebp, esp
	
	push ebx
	
	mov eax, 0
	mov ebx, [ebp+8]
	mov ecx, 0
	L:
		mov edx, 0
		mov dl, [ebx+ecx]
		cmp dl, 0
		jz cont
		
		push ecx
		push [ebp+12]
		push edx
		call ispat
		pop ecx
		test eax, eax
		jnz found
		inc ecx
		jmp L
	found:
	add eax, ebx
	add eax, ecx
	cont:
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
find_pat endp


find_word proc ; (link_str) -> edx:eax
	; edx - link to next sym after word or 0 (if end of global string)
	; eax - link to word
	push ebp
	mov ebp, esp
	
	sub esp, 4
	loc_bool equ dword ptr [ebp-4]
	push ebx
	push esi
	
	mov ebx, [ebp+8]
	mov ecx, 0
	L:
		mov eax, 0
		mov al, [ebx+ecx]
		cmp al, 0
		jz null
		
		pushad
		push offset latin
		push eax
		call ispat
		mov loc_bool, eax
		popad
		
		cmp loc_bool, 0
		jz nxt
		
		inc ecx
		jmp L
	nxt:
	pushad
	push offset bordword
	push eax
	call ispat
	mov loc_bool, eax
	popad
	
	cmp loc_bool, 0
	jz garb
	
	cmp ecx, 0
	jz empty
	
	inc ecx
	new ecx
	dec ecx
	
	mov esi, ebx
	add esi, ecx
	mov byte ptr [eax+ecx], 0
	write:
		mov dl, [ebx+ecx-1]
		mov [eax+ecx-1], dl
		loop write
	mov edx, esi
	inc edx
	jmp fin
	
	garb:
	mov eax, 0
	mov edx, ebx
	add edx, ecx
	inc edx
	jmp fin
	
	empty:
	mov eax, -1
	mov edx, ebx
	add edx, ecx
	inc edx
	jmp fin
	
	null:
	mov eax, 0
	mov edx, 0
	
	fin:
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret 4
find_word endp


fwords proc ; (link_str, link_lst)
	push ebp
	mov ebp, esp
	
	sub esp, 4
	loc_b equ dword ptr [ebp-4]
	mov loc_b, 0
	push ebx
	
	mov ebx, [ebp+12]
	mov edx, [ebp+8]
	mov ecx, 0
	mov eax, 0
	L:
		inc ecx
		cmp eax, 0
		jz eax0
		
		cmp eax, -1
		je eaxm1
		
		pushad
		push eax
		push [ebp+12]
		call putw
		mov loc_b, eax
		popad
		
		cmp loc_b, 0
		jz @f
		dispose eax ; удаляем, если слово уже было в списке
		@@:
		jmp next_word
		
		eax0:
		
		cmp edx, 0
		jz fin
		
		push offset bordword
		push edx
		call find_pat
		cmp eax, 0
		jz fin
		mov edx, eax
		eaxm1:
		next_word:
		push edx
		call find_word
		jmp L
	fin:
	pop ebx
	mov esp, ebp
	pop ebp
	ret 2*4
fwords endp


cmpstr proc ; (link_str1, link_str2) -> eax
	; true, if str1 < str2
	push ebp
	mov ebp, esp
	
	push ebx
	
	mov ebx, [ebp+8]
	mov edx, [ebp+12]
	mov ecx, 0
	L:
		mov al, [ebx+ecx]
		cmp al, [edx+ecx]
		ja inv
		jb up
		
		inc ecx
		jmp L
	
	inv:
	mov eax, 0
	jmp fin
	up:
	mov eax, 1
	fin:
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 2*4
cmpstr endp


get_lenw proc ; (link_lst) -> eax
	push ebp
	mov ebp, esp
	
	push ebx
	
	assume ebx:ptr wlst
	mov eax, 0
	mov ebx, [ebp+8]
	L:
		cmp [ebx].wrd, 0
		jz fin
		
		inc eax
		mov ebx, [ebx].next
		jmp L
	fin:
	assume ebx:nothing
	pop ebx
	
	mov esp, ebp
	pop ebp
	ret 4
get_lenw endp


sort1 proc ; (link_lst, len)
	push ebp
	mov ebp, esp
	
	sub esp, 4
	sort1_a equ dword ptr [ebp-4]
	mov sort1_a, 0
	push ebx
	
	assume ebx:ptr wlst
	assume edx:ptr wlst
	mov eax, 0
	mov ebx, [ebp+8]
	mov edx, [ebx].next
	mov ecx, [ebp+12]
	dec ecx
	L:
		cmp ecx, 0
		jle fin
		
		mov eax, [ebx].freq
		cmp eax, [edx].freq
		ja swap
		jb cont
		
		pushad
		push [edx].wrd
		push [ebx].wrd
		assume ebx:nothing
		assume edx:nothing
		call cmpstr
		assume ebx:ptr wlst
		assume edx:ptr wlst
		mov sort1_a, eax
		popad
		
		cmp sort1_a, 0
		je swap
		jmp cont
		swap:
		mov eax, [ebx].wrd
		xchg eax, [edx].wrd
		mov [ebx].wrd, eax
		
		mov eax, [ebx].freq
		xchg eax, [edx].freq
		mov [ebx].freq, eax
		
		cont:
		mov ebx, edx
		mov edx, [ebx].next
		dec ecx
		jmp L
	fin:
	assume ebx:nothing
	assume edx:nothing
	pop ebx
	mov esp, ebp
	pop ebp
	ret 2*4
sort1 endp 
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

push arr
call print
newline
newline

push offset wordlst
push arr
call fwords

;push offset wordlst
;call outwlst
;newline
;outstrln "==============="
;newline

push offset wordlst
call get_lenw
mov wlen, eax

mov ecx, wlen
@@:
	push ecx
	push wlen
	push offset wordlst
	call sort1
	
	;push offset wordlst
	;call outwlst
	;newline
	;outstrln "------------"
	
	pop ecx
	dec ecx
	cmp ecx, 0
	jnz @b

push offset wordlst
call outwlst
newline


outstrln 'All is ok'
exit 0
ERR:
	outstrln 'Illegal input!!!'
	exit -1
end start