#! /bin/bash

nasm -f elf64 donut.asm
ld -s -o donut donut.o -lc -lm
patchelf --set-interpreter /usr/lib64/ld-linux-x86-64.so.2 donut
