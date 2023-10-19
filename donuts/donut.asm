section .text
 global _start
 extern malloc, free, sin, cos, memset, printf, putchar

section .data
 msg_clear	db 0x1b, '[2J'
 msg_clear_len	equ $ - msg_clear
 msg_top	db 0x1b, '[d'
 msg_top_len	equ $ - msg_top
 char_array	db '.,-~:;=!*#$@'
 z_size		dq 14080
 b_size		dq 1760
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
 k		dq 0
 x		dq 0
 y		dq 0
 o		dq 0
 N		dq 0
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
 z		dq 0
 b		dq 0

section .text
 _start:
  mov rdi, [z_size]
  call malloc
  mov [z], rax
  test rax, rax
  jz _exit_malloc_z_fail
  mov rdi, [b_size]
  call malloc
  mov [b], rax
  test rax, rax
  jz _exit_malloc_b_fail
  mov rax, [fp_0_0]
  mov [A], rax
  mov [B], rax
  call _screen_clear
  _loop_exec:
   mov rdi, [z]
   mov rsi, [fp_0_0]
   mov rdx, [z_size]
   call memset
   mov rdi, [b]
   mov rsi, ' '
   mov rdx, [b_size]
   call memset
   mov rax, [fp_0_0]
   mov [j], rax
   _loop_j:
    mov rax, [fp_0_0]
    mov [i], rax
    _loop_i:
     movsd xmm0, qword [i]
     call sin
     movsd qword [sini], xmm0
     movsd xmm0, qword [j]
     call cos
     movsd qword [cosj], xmm0
     movsd xmm0, qword [A]
     call sin
     movsd qword [sinA], xmm0
     movsd xmm0, qword [j]
     call sin
     movsd qword [sinj], xmm0
     movsd xmm0, qword [A]
     call cos
     movsd qword [cosA], xmm0
     fld qword [cosj]
     fld qword [fp_2_0]
     fadd
     fstp qword [cosj2]
     fld qword [sini]
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
     fdivr
     fstp qword [mess]
     movsd xmm0, qword [i]
     call cos
     movsd qword [cosi], xmm0
     movsd xmm0, qword [B]
     call cos
     movsd qword [cosB], xmm0
     movsd xmm0, qword [B]
     call sin
     movsd qword [sinB], xmm0
     fld qword [sini]
     fld qword [cosj2]
     fmul
     fld qword [cosA]
     fmul
     fld qword [sinj]
     fld qword [sinA]
     fmul
     fsub
     fstp qword [t]
     fld qword [cosi]
     fld qword [cosj2]
     fmul
     fld qword [cosB]
     fmul
     fld qword [t]
     fld qword [sinB]
     fmul
     fsub
     fld qword [mess]
     fmul
     fld qword [fp_30_0]
     fmul
     fld qword [fp_40_0]
     fadd
     fistp qword [x]
     fld qword [cosi]
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
     mov rax, [y]
     mov rbx, 80
     imul rax, rbx
     mov rbx, [x]
     add rax, rbx
     mov [o], rax
     fld qword [sinj]
     fld qword [sinA]
     fmul
     fld qword [sini]
     fld qword [cosj]
     fmul
     fld qword [cosA]
     fmul
     fsub
     fld qword [cosB]
     fmul
     fld qword [sini]
     fld qword [cosj]
     fmul
     fld qword [sinA]
     fmul
     fsub
     fld qword [sinj]
     fld qword [cosA]
     fmul
     fsub
     fld qword [cosi]
     fld qword [cosj]
     fmul
     fld qword [sinB]
     fmul
     fsub
     fld qword [fp_8_0]
     fmul
     fistp qword [N]
     mov rax, 22
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
     mov rax, [z]
     mov rbx, [o]
     imul rbx, 8
     add rax, rbx
     fld qword [rax]
     fld qword [mess]
     fcomip
     fstp
     jbe _if_end
     mov rax, [z]
     mov rbx, [o]
     imul rbx, 8
     add rax, rbx
     mov rbx, [mess]
     mov [rax], rbx
     mov rax, [b]
     add rax, [o]
     mov rbx, [N]
     cmp rbx, 0
     jg _swap_end
     mov rbx, 0
     _swap_end:
     add rbx, char_array
     mov cl, [rbx]
     mov [rax], cl
     _if_end:
     fld qword [i]
     fld qword [fp_0_02]
     fadd
     fstp qword [i]
     fld qword [fp_6_28]
     fld qword [i]
     fcomip
     fstp
     jbe _loop_i
    fld qword [j]
    fld qword [fp_0_07]
    fadd
    fstp qword [j]
    fld qword [fp_6_28]
    fld qword [j]
    fcomip
    fstp
    jbe _loop_j
   call _screen_top
   mov rax, 0
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
    mov rax, [k]
    add rax, 1
    mov [k], rax
    cmp rax, 1761
    jl _loop_k
   _loop_exec_end:
   fld qword [A]
   fld qword [fp_0_004]
   fadd
   fstp qword [A]
   fld qword [B]
   fld qword [fp_0_002]
   fadd
   fstp qword [B]
   jmp _loop_exec
 _exit:
  mov rdi, [z]
  call free
  mov rdi, [b]
  call free
  mov rbx, 0
  mov rax, 1
  int 0x80
 _exit_malloc_z_fail:
  mov rbx, 1
  mov rax, 1
  int 0x80
 _exit_malloc_b_fail:
  mov rdi, [z]
  call free
  mov rbx, 2
  mov rax, 1
  int 0x80
 _screen_clear:
  mov rdx, msg_clear_len
  mov rcx, msg_clear
  mov rbx, 1
  mov rax, 4
  int 0x80
  ret
 _screen_top:
  mov rdx, msg_top_len
  mov rcx, msg_top
  mov rbx, 1
  mov rax, 4
  int 0x80
  ret
