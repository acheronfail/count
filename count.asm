; Handmade x86_64 ELF binary, no linker needed! The ELF header is defined manually.
; This means the binary size is very small.
;
; Recommended reading:
; - https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
; - https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture
; - https://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

BITS 64

    org     0x08048000

; https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
elf_header:                       ; Elf64_Ehdr
    db      0x7F, "ELF"           ;   e_ident[ei_mag0 - ei_mag3]
    db      2                     ;   e_ident[ei_class] (1=32bit, 2=64bit)
    db      1                     ;   e_ident[ei_data] (1=little endian, 2=big endian)
    db      1                     ;   e_ident[ei_version]
    db      0                     ;   e_ident[ei_osabi]
    dq      0                     ;   e_ident[ei_abiversion] +   e_ident[ei_pad]
    dw      2                     ;   e_type
    dw      0x3e                  ;   e_machine (0x3=32bit, 0x3e=amd64)
    dd      1                     ;   e_version
    dq      _start                ;   e_entry
    dq      program_header - $$   ;   e_phoff
    dq      0                     ;   e_shoff
    dd      0                     ;   e_flags
    dw      ehdrsize              ;   e_ehsize
    dw      phdrsize              ;   e_phentsize
    dw      1                     ;   e_phnum
    dw      0                     ;   e_shentsize
    dw      0                     ;   e_shnum
    dw      0                     ;   e_shstrndx
    ehdrsize equ $ - elf_header

program_header:                   ; Elf64_Phdr
    dd      1                     ;   p_type
    dd      7                     ;   p_flags (bitmask: x=0x1, w=0x2, r=0x4; we set to rwx)
    dq      0                     ;   p_offset
    dq      $$                    ;   p_vaddr
    dq      $$                    ;   p_paddr
    dq      filesize              ;   p_filesz
    dq      filesize              ;   p_memsz
    dq      0x1000                ;   p_align
    phdrsize equ $ - program_header

    ten    dq 10
    output db 10 dup(0), 10 ; max 32bit number is 10 digits (decimal) long, followed by newline

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

    filesize      equ     $ - $$