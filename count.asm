section .data
format db "%d", 10, 0

section .text
extern printf
global _start

_start:
    pop rdi ; argc is in rdi
    pop rsi ; argv is in rsi

    add rsi, 8   ; skip the first argument
    mov rdi, rsi ; move into rdi
    xor rcx, rcx ; zero
    xor rax, rax ; zero

parse_arg:
    movzx rdx, byte [rdi + rcx]
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    cmp byte [rdi + rcx], 0
    jne parse_arg

    xor ecx, ecx
count:
    inc ecx
    or ecx, 1
    cmp ecx, eax
    jl count

    ; print
    mov rdi, format ; rdi: first argument
    mov esi, eax    ; esi: second argument
    xor eax, eax    ; number of vector registers used is 0
    call printf

end_program:
    mov eax, 60  ; system call number for exit
    xor edi, edi ; exit code 0
    syscall
