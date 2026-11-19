; QEMU PC BIOS enters here at physical 0x7c00.
bits 16
section .bootstrap progbits alloc exec
global bootstrap
extern kernel_entry
bootstrap:
    cli
    xor ax, ax
    mov ds, ax
    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 0x08:protected_entry

align 8
gdt:
    dq 0
    dq 0x00cf9a000000ffff  ; flat ring-0 code
    dq 0x00cf92000000ffff  ; flat ring-0 data
gdtr:
    dw gdtr - gdt - 1
    dd gdt

bits 32
protected_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00
    cld
    call kernel_entry
.halt:
    hlt
    jmp .halt
