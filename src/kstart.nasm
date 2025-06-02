bits 32

%define MB1_MAGIC_NUM 0x1BADB002
%define MB1_FLAGS 0x00
%define MB1_CHECKSUM -(MB1_MAGIC_NUM + MB1_FLAGS)

section .text
    ; Multiboot header
section .multiboot
align 4
    dd MB1_MAGIC_NUM
    dd MB1_FLAGS
    dd MB1_CHECKSUM

global _start
extern kmain

_start:
    cli
    mov esp, stack_space        ; The x86 stack grows downwards so we need to
                                ; set the stack pointer to the top of the
                                ; appropriate section (.bss)
    
    call kmain                  ; No need to `hlt` as `kmain` does this itself

section .bss
    resb 16 * 1024              ; Reserve 16KiB for the stack

stack_space:

