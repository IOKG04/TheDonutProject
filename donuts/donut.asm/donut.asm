section .text
 global _start

section .data

section .text
 _start:
  mov ebx, 0
  mov eax, 1
  int 0x80
