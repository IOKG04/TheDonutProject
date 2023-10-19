section .text
 global _start
 extern malloc, free, sin, cos, memset, printf, putchar

section .data
 ; constants
 ; code for clearing screen
 msg_clear	db 0x1b, '[2J'
 msg_clear_len	equ $ - msg_clear
 ; code for going to top of screen
 msg_top	db 0x1b, '[d'
 msg_top_len	equ $ - msg_top
 ; character array
 char_array	db '.,-~:;=!*#$@'
 ; sizes for malloc calls
 z_size		dq 14080
 b_size		dq 1760
 ; constants needed for floating point operations
 fp_0_0		dq 0.0
 fp_0_002	dq 0.002
 fp_0_004	dq 0.004
 fp_0_02	dq 0.02
 fp_0_04	dq 0.04
 fp_0_07	dq 0.07
 fp_1_0		dq 1.0
 fp_2_0		dq 2.0
 fp_5_0		dq 5.0
 fp_6_28	dq 6.28
 fp_8_0		dq 8.0
 fp_12_0	dq 12.0
 fp_15_0	dq 15.0
 fp_30_0	dq 30.0
 fp_40_0	dq 40.0

 ; variables
 ; ints
 k		dq 0
 x		dq 0
 y		dq 0
 o		dq 0
 N		dq 0
 ; floats
 A		dq 0
 B		dq 0
 i		dq 0
 j		dq 0
 sini		dq 0
 cosj		dq 0
 sinA		dq 0
 sinj		dq 0
 cosA		dq 0
 cosj2		dq 0
 mess		dq 0
 cosi		dq 0
 cosB		dq 0
 sinB		dq 0
 t		dq 0
 ; pointers, allocated at start (hopefully) and freed at end (even more hopefully)
 z		dq 0
 b		dq 0

 db_f		db 'x: %i y: %i mess: %f z[o]: %f', 10, 0

section .text
 ; start of the program
 _start:
  ; malloc z
  mov rdi, [z_size]
  call malloc
  mov [z], rax
  test rax, rax			; test for success
  jz _exit_malloc_z_fail

  ; malloc b
  mov rdi, [b_size]
  call malloc
  mov [b], rax
  test rax, rax			; test for success
  jz _exit_malloc_b_fail

  ; initialize A and B (line 4)
  mov rax, [fp_0_0]
  mov [A], rax
  mov [B], rax

  ; clear screen (line 6)
  call _screen_clear

  ; execution loop
  _loop_exec:
   ; initialize z and b (lines 8, 9)
   mov rdi, [z]			; init z
   mov rsi, [fp_0_0]
   mov rdx, [z_size]
   call memset
   mov rdi, [b]			; init b
   mov rsi, ' '
   mov rdx, [b_size]
   call memset

   ; for j loop (line 10)
   mov rax, [fp_0_0]		; init j
   mov [j], rax
   _loop_j:
    ; for i loop (line 11)
    mov rax, [fp_0_0]		; init i
    mov [i], rax
    _loop_i:
     ; code inside j and i loop (lines 12 - 30)
     movsd xmm0, qword [i]	; sini = sin(i) (line 12)
     call sin
     movsd qword [sini], xmm0
     movsd xmm0, qword [j]	; cosj = cos(j) (line 13)
     call cos
     movsd qword [cosj], xmm0
     movsd xmm0, qword [A]	; sinA = sin(A) (line 14)
     call sin
     movsd qword [sinA], xmm0
     movsd xmm0, qword [j]	; sinj = sin(j) (line 15)
     call sin
     movsd qword [sinj], xmm0
     movsd xmm0, qword [A]	; cosA = cos(A) (line 16)
     call cos
     movsd qword [cosA], xmm0
     fld qword [cosj]		; cosj2 = cosj + 2 (line 17)
     fld qword [fp_2_0]
     fadd
     fstp qword [cosj2]
     fld qword [sini]		; mess = 1 / (sini*cosj2*sinA + sinj*cosA + 5) (line 18)
     fld qword [cosj2]
     fmul
     fld qword [sinA]
     fmul
     fld qword [sinj]
     fld qword [cosA]
     fmul
     fadd
     fld qword [fp_5_0]
     fadd
     fld qword [fp_1_0]
     fdivr ; might be fdivr
     fstp qword [mess]
     movsd xmm0, qword [i]	; cosi = cos(i) (line 19)
     call cos
     movsd qword [cosi], xmm0
     movsd xmm0, qword [B]	; cosB = cos(B) (line 20)
     call cos
     movsd qword [cosB], xmm0
     movsd xmm0, qword [B]	; sinB = sin(B) (line 21)
     call sin
     movsd qword [sinB], xmm0
     fld qword [sini]		; t = sini*cosj2*cosA - sinj*sinA (line 22)
     fld qword [cosj2]
     fmul
     fld qword [cosA]
     fmul
     fld qword [sinj]
     fld qword [sinA]
     fmul
     fsub ; might be fsub
     fstp qword [t]
     fld qword [cosi]		; x = 40 + 30 * mess * (cosi*cosj2*cosB - t*sinB) (line 23)
     fld qword [cosj2]
     fmul
     fld qword [cosB]
     fmul
     fld qword [t]
     fld qword [sinB]
     fmul
     fsub ; might be fsub
     fld qword [mess]
     fmul
     fld qword [fp_30_0]
     fmul
     fld qword [fp_40_0]
     fadd
     fistp qword [x]
     fld qword [cosi]		; y = 12 + 15 * mess * (cosi*cosj2*sinB + t*cosB) (line 24)
     fld qword [cosj2]
     fmul
     fld qword [sinB]
     fmul
     fld qword [t]
     fld qword [cosB]
     fmul
     fadd
     fld qword [mess]
     fmul
     fld qword [fp_15_0]
     fmul
     fld qword [fp_12_0]
     fadd
     fistp qword [y]
     mov rax, [y]		; o = x + 80*y (line 25)
     mov rbx, 80
     imul rax, rbx
     mov rbx, [x]
     add rax, rbx
     mov [o], rax
     fld qword [sinj]		; N = 8 * ((sinj*sinA - sini*cosj*cosA) * cosB - sini*cosj*sinA - sinj*cosA - cosi*cosj*sinB) (line 26)
     fld qword [sinA]
     fmul
     fld qword [sini]
     fld qword [cosj]
     fmul
     fld qword [cosA]
     fmul
     fsub ; might be fsub
     fld qword [cosB]
     fmul
     fld qword [sini]
     fld qword [cosj]
     fmul
     fld qword [sinA]
     fmul
     fsub ; might be fsub
     fld qword [sinj]
     fld qword [cosA]
     fmul
     fsub ; might be fsub
     fld qword [cosi]
     fld qword [cosj]
     fmul
     fld qword [sinB]
     fmul
     fsub ; might be fsub
     fld qword [fp_8_0]
     fmul
     fistp qword [N]

     mov rax, 22		; if thing (line 27)
     mov rbx, [y]
     cmp rax, rbx
     jle _if_end
     mov rax, [y]
     mov rbx, 0
     cmp rax, rbx
     jle _if_end
     mov rax, [x]
     mov rbx, 0
     cmp rax, rbx
     jle _if_end
     mov rax, 80
     mov rbx, [x]
     cmp rax, rbx
     jle _if_end
     fld qword [mess]
     mov rax, [z]
     mov rbx, [o]
     imul rbx, 8
     add rax, rbx
     fld qword [rax]
     fcomip
     fstp
     jle _if_end

     ;;DEBUG
     ;mov rdi, db_f
     ;mov rsi, [x]
     ;mov rdx, [y]
     ;movsd xmm0, qword [mess]
     ; mov rax, [z]
     ; mov rbx, [o]
     ; imul rbx, 8
     ; add rax, rbx
     ;movsd xmm1, qword [rax]
     ;mov rax, 1
     ;call printf
     ;;END DEBUG

     mov rax, [z]		; z[o] = mess (line 28)
     mov rbx, [o]
     imul rbx, 8
     add rax, rbx
     mov rbx, [mess]
     mov [rax], rbx

     mov rax, [b]		; b[o] = ".,-~:;=!*#$@"[N > 0 ? N : 0] (line 29)
     add rax, [o]
     mov rbx, [N]
     cmp rbx, 0
     jg _swap_end
     mov rbx, 0
     _swap_end:
     add rbx, char_array
     mov cl, [rbx]
     mov [rax], cl

     _if_end:			; line 30
     
     ; increment i, compare to 6.28 and jump if less than (line 11)
     fld qword [i]
     fld qword [fp_0_02]
     fadd
     fstp qword [i]
     fld qword [fp_6_28]
     fld qword [i]
     fcomip
     fstp
     jbe _loop_i
    
    ; increment j, compare to 6.28 and jump if less than (line 10)
    fld qword [j]
    fld qword [fp_0_07]
    fadd
    fstp qword [j]
    fld qword [fp_6_28]
    fld qword [j]
    fcomip
    fstp
    jbe _loop_j

   call _screen_top		; go to top of screen (line 33)

   ; for k loop (line 34)
   mov rax, 0			; initialize k
   mov [k], rax
   _loop_k:
    mov rax, [k]
    mov rbx, 80
    div rbx
    mov rax, rdx
    cmp rax, 0
    je _add_nl

    mov rax, [b]
    add rax, [k]
    mov rdi, [rax]
    mov rax, 1
    call putchar
    jmp _loop_k_end

    _add_nl:
    mov rdi, 0xa
    mov rax, 1
    call putchar

    _loop_k_end:
    ; increment k and jump if less than 1761 (line 34)
    mov rax, [k]
    add rax, 1
    mov [k], rax
    cmp rax, 1761
    jl _loop_k

   _loop_exec_end:
   ; jump to start of loop
   ;jmp _exit ; DEBUG
   fld qword [A]
   fld qword [fp_0_004];
   fadd
   fstp qword [A]
   fld qword [B]
   fld qword [fp_0_002];
   fadd
   fstp qword [B]
   jmp _loop_exec

 ; exit with code 0 (success)
 _exit:
  ;free z and b
  mov rdi, [z]
  call free
  mov rdi, [b]
  call free
  ; exit
  mov rbx, 0
  mov rax, 1
  int 0x80
 
 ; exit with code 1 (malloc z failed)
 _exit_malloc_z_fail:
  mov rbx, 1
  mov rax, 1
  int 0x80

 ; exit with code 2 (malloc b failed)
 _exit_malloc_b_fail:
  ; free z
  mov rdi, [z]
  call free
  ; exit
  mov rbx, 2
  mov rax, 1
  int 0x80
 
 ; send signal to clear screen
 _screen_clear:
  mov rdx, msg_clear_len
  mov rcx, msg_clear
  mov rbx, 1
  mov rax, 4
  int 0x80
  ret
 
 ; send signal to go to top of screen
 _screen_top:
  mov rdx, msg_top_len
  mov rcx, msg_top
  mov rbx, 1
  mov rax, 4
  int 0x80
  ret

; DEBUGGING STUFF JUST SO I DONT LOSE IT
;
; movsd xmm0, qword [j]
; mov rdi, format
; mov rax, 1
; call printf
;
; format		db '%f', 10, 0 ; DEBUG
