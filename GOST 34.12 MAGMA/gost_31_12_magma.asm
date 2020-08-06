;GOST 34.12-2015 'MAGMA' FOR X86 CPU
.686
.model flat, C
.stack 32

.data
	pi0		db 12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 7, 0, 3, 15, 1
	pi1		db 6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15
	pi2		db 11, 3, 5, 8, 2, 15, 10, 13, 14, 1, 7, 4, 12, 9, 6, 0
	pi3		db 12, 8, 2, 1, 13, 4, 15, 6, 7, 0, 10, 5, 3, 14, 9, 11
	pi4		db 7, 15, 5, 10, 8, 1, 6, 13, 0, 9, 3, 14, 11, 4, 2, 12
	pi5		db 5, 13, 15, 6, 9, 2, 12, 10, 11, 7, 8, 1, 4, 3, 14, 0
	pi6		db 8, 14, 2, 5, 6, 9, 1, 12, 15, 4, 11, 0, 13, 10, 3, 7
	pi7		db 1, 7, 14, 13, 0, 5, 8, 3, 4, 15, 10, 6, 9, 12, 11, 2

	dwT		dd 0
	dwTRKey	dd 0

.code 
	
	;t-transmission function
	_t_proc		proc C, dwA: dword
				mov eax, 0000000fh
				mov ebx, dwA
				and eax, ebx
				xor edx, edx
				mov dl, ds: [pi0] + eax
				xor ds:[dwT], edx

				mov eax, 000000f0h
				and eax, ebx
				ror al, 4
				xor edx, edx
				mov dl, ds: [pi1] + eax
				rol dl, 4
				xor ds:[dwT], edx

				mov eax, 00000f00h
				and eax, ebx
				ror ax, 8
				xor edx, edx
				mov dl, ds: [pi2] + eax
				rol dx, 8
				xor ds:[dwT], edx

				mov eax, 0000f000h
				and eax, ebx
				ror ax, 12
				xor edx, edx
				mov dl, ds: [pi3] + eax
				rol dx, 12
				xor ds:[dwT], edx

				mov eax, 000f0000h
				and eax, ebx
				ror eax, 16
				xor edx, edx
				mov dl, ds: [pi4] + eax
				rol edx, 16
				xor ds:[dwT], edx

				mov eax, 00f00000h
				and eax, ebx
				rol eax, 12
				xor edx, edx
				mov dl, ds: [pi5] + eax
				ror edx, 12
				xor ds:[dwT], edx

				mov eax, 0f000000h
				and eax, ebx
				rol eax, 8
				xor edx, edx
				mov dl, ds: [pi6] + eax
				ror edx, 8
				xor ds:[dwT], edx

				mov eax, 0f0000000h
				and eax, ebx
				rol eax, 4
				xor edx, edx
				mov dl, ds: [pi7] + eax
				ror edx, 4
				xor ds:[dwT], edx

				mov eax, ds:[dwT]
				mov ds:[dwT], 0
				ret
	_t_proc		endp

	;g-shift function
	_g_proc		proc C, dwK: dword, dwA: dword
				mov eax, dwK
				mov ebx, dwA
				add eax, ebx
				push eax
				call _t_proc
				add sp, 4
				rol eax, 11
				ret
	_g_proc		endp

	;G1-linear function
	_G1_proc	proc C, dwK: dword, dwA1: dword, dwA0: dword
				mov esi, dwA0
				push [esi]
				push dwK
				call _g_proc
				add sp, 8
				mov esi, dwA1
				xor eax, [esi]
				mov esi, dwA0
				mov ebx, [esi]
				mov esi, dwA1
				mov [esi], ebx
				mov esi, dwA0
				mov [esi], eax
				ret
	_G1_proc	endp

	;G2-inversion G1 linear function
	_G2_proc	proc C, dwK: dword, dwA1: dword, dwA0: dword
				mov esi, dwA0
				push [esi]
				push dwK
				call _g_proc
				add sp, 8
				mov esi, dwA1
				xor eax, [esi]
				mov [esi], eax
				ret
	_G2_proc	endp

	;RKey-primary key expantion function
	_RKey_proc	proc C, byPKey: dword, byRNum: byte, dwRKey: dword
				xor eax, eax
				xor ebx, ebx
				mov al, byRNum
				xor edx, edx
				mov ebx, 8
				div ebx	
				cmp byRNum, 24
				jle RKey_1_24		
				cmp edx, 0
				cmove edx, ebx
				mov ebx, edx			
				jmp RKey_1_32
	RKey_1_24:	sub ebx, edx
				xor eax, eax
				cmp edx, 0
				cmove ebx, eax
				inc ebx
	RKey_1_32:	dec ebx
				mov eax, byPKey
				mov esi, eax
				mov eax, [esi+4*ebx]
				mov esi, dwRKey
				mov [esi], eax
				xor eax, eax
				ret
	_RKey_proc	endp

	;GOST_encr-encryption block function
	_GOST_encr	proc C, byPKey: dword, dwA1: dword, dwA0: dword
				mov ecx, 1 
	round_func: lea esi, dwTRKey
				push esi
				push ecx
				push byPKey
				call _RKey_proc
				add sp, 12
				mov esi, dwA0
				push esi
				mov esi, dwA1
				push esi
				lea esi, dwTRKey
				push [esi]
				call _G1_proc
				add sp, 12
				inc ecx
				cmp ecx, 31 
				jle round_func

				lea esi, dwTRKey
				push esi
				push ecx
				push byPKey
				call _RKey_proc
				add sp, 12
				mov esi, dwA0
				push esi
				mov esi, dwA1
				push esi
				lea esi, dwTRKey
				push [esi]
				call _G2_proc
				add sp, 12

				mov ds:[dwTRKey], 0
				xor eax, eax
				xor ebx, ebx
				xor edx, edx
				xor ecx, ecx
				ret
	_GOST_encr	endp		

	;GOST_encr-decryption block function
	_GOST_decr	proc C, byPKey: dword, dwA1: dword, dwA0: dword
				mov ecx, 32 
	round_func:	lea esi, dwTRKey
				push esi
				push ecx
				push byPKey
				call _RKey_proc
				add sp, 12
				mov esi, dwA0
				push esi
				mov esi, dwA1
				push esi
				lea esi, dwTRKey
				push [esi]
				call _G1_proc
				add sp, 12
				dec ecx
				cmp ecx, 2
				jge round_func

				lea esi, dwTRKey
				push esi
				push ecx
				push byPKey
				call _RKey_proc
				add sp, 12
				mov esi, dwA0
				push esi
				mov esi, dwA1
				push esi
				lea esi, dwTRKey
				push [esi]
				call _G2_proc
				add sp, 12

				mov ds:[dwTRKey], 0
				xor eax, eax
				xor ebx, ebx
				xor edx, edx
				xor ecx, ecx				
				ret
	_GOST_decr	endp	
END