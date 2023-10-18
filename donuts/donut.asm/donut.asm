section .text
 global _start
 extern malloc, free, sin, cos, memset, printf

section .data
 ; constants
 ; code for clearing screen
 msg_clear	db 0x1b, '[2J'
 msg_clear_len	equ $ - msg_clear
 ; code for going to top of screen
 msg_top	db 0x1b, '[d'
 msg_top_len	equ $ - msg_top
 ; sizes for malloc calls
 z_size		dq 0x1b80
 b_size		dq 0x06e0
 ; constants needed for floating point operations
 fp_0_0		dq 0.0
 fp_0_02	dq 0.02
 fp_0_04	dq 0.04
 fp_0_07	dq 0.07
 fp_2_0		dq 2.0
 fp_6_28	dq 6.28
 fp_12_0	dq 12.0
 fp_15_0	dq 15.0
 fp_30_0	dq 30.0
 fp_40_0	dq 40.0

 format		db '%f', 10, 0 ; DEBUG

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

section .text
 ; start of the program
 _start:
  ; malloc z
  mov rdi, [z_size]
  call malloc
  test rax, rax			; test for success
  jz _exit_malloc_z_fail
  mov [z], rax

  ; malloc b
  mov rdi, [b_size]
  call malloc
  test rax, rax			; test for success
  jz _exit_malloc_b_fail
  mov [b], rax

  ; initialize A and B (line 4)
  mov rax, [fp_0_0]
  mov [A], rax
  mov [B], rax

  ; clear screen (line 6)
  call _screen_clear

  ; execution loop
  _loop_exec:
   ; initialize z and b (lines 8, 9)
   lea rdi, [z]			; init z
   mov rax, [fp_0_0]
   mov rcx, [z_size]
   call memset
   lea rdi, [b]			; init b
   mov rax, ' '
   mov rcx, [b_size]
   call memset

   ; for j loop (line 10)
   mov rax, [fp_0_0]
   mov [j], rax
   _loop_j:
    
    ; DEBUG

    movsd xmm0, qword [j]
    mov rdi, format
    mov rax, 1
    call printf

    ; END

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

   ; jump to start of loop
   jmp _loop_exec

 ; exit with code 0 (success)
 _exit:
  ; free z and b
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
