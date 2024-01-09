section .data
    ten    dq 10
    output db 10 dup(0), 10 ; max 32bit number is 10 digits (decimal) long, followed by newline

section .text

global _start

_start:                 ; argc is at `rsp`, argv is at `rsp + 8`
    mov rdi, [rsp + 8]  ; put argv into `rdi`
    add rdi, 8          ; skip the first argument (program name)

    xor rcx, rcx        ; zero
    xor rax, rax        ; zero
from_decimal_loop:
    movzx rdx, byte [rdi + rcx]
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    cmp byte [rdi + rcx], 0
    jne from_decimal_loop

    xor ecx, ecx       ; zero
count:
    inc ecx
    or ecx, 1
    cmp ecx, eax
    jl count

print:
    mov eax, ecx         ; number is stored in `ecx`, put it in `eax` for division
    lea rsi, [output+10] ; build the string from right to left, `rsi` tracks start of string

to_decimal_loop:
    xor edx, edx         ; `edx` must be zeroed (`edx` and `eax` are combined for 64bit division)
    div dword [ten]      ; divide by 10
    add edx, '0'         ; remainer in `edx`, convert it to ascii
    dec rsi              ; move to the previous char in the buffer
    mov [rsi], dl        ; store the ascii character
    test eax, eax        ; quotient in `eax`, test if 0
    jnz to_decimal_loop  ; if not, convert the next digit

write:                   ; args: `rax` syscall, `rdi` fd, `rsi` buf, `rdx` length
    mov rax, 1
    mov rdi, 1
    lea rdx, [output+11]
    sub rdx, rsi
    syscall

end_program:             ; args; `rax` syscall, `rdi` exit code
    mov eax, 60
    xor edi, edi
    syscall
