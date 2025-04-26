include console.inc

.data
	stop dd '@%#%'
	slst struc
		s db 0
		next dd 0
	slst ends
	len dd 0
	lst dd ?
	
	
	

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
start:
push offset len
call init
mov lst, eax

push 'O'
push offset len
push lst
call append
outstrln 'OKEY'

push 'k'
push offset len
push lst
call append

push '.'
push offset len
push lst
call append

push lst
call outlst
newline
exit 0
end start