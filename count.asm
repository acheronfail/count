section .data
format db "%d", 10, 0

section .text
extern printf
global _start

_start:
    xor ecx, ecx

start_loop:
    inc ecx
    cmp ecx, 1000000000
    jl start_loop

    ; print
    mov rdi, format ; rdi: first argument
    mov esi, ecx    ; esi: second argument
    xor eax, eax    ; number of vector registers used is 0
    call printf

    ; exit
    mov eax, 60  ; system call number for exit
    xor edi, edi ; exit code 0
    syscall
