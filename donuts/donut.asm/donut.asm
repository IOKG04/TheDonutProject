section .text
 global _start
 extern malloc, free, sin, cos

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
  syscall
 
 ; exit with code 1 (malloc z failed)
 _exit_malloc_z_fail:
  mov rbx, 1
  mov rax, 1
  syscall

 ; exit with code 2 (malloc b failed)
 _exit_malloc_b_fail:
  ; free z
  mov rdi, [z]
  call free
  ; exit
  mov rbx, 2
  mov rax, 1
  syscall
 
 ; send signal to clear screen
 _screen_clear:
  mov rdx, msg_clear_len
  mov rcx, msg_clear
  mov rbx, 1
  mov rax, 4
  syscall
  ret
 
 ; send signal to go to top of screen
 _screen_top:
  mov rdx, msg_top_len
  mov rcx, msg_top
  mov rbx, 1
  mov rax, 4
  syscall
  ret
