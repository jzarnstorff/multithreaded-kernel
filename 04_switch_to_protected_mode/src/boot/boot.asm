ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:  ; offset 0 of the BIOS Parameter Block - https://wiki.osdev.org/FAT#BPB_(BIOS_Parameter_Block)
    jmp short start
    nop

; pad 33 bytes with zeroes to make a fake BIOS
; Parameter Block in case the BIOS modifies values
times 33 db 0

start:
    jmp 0:main

main:
    cli  ; clear interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti  ; enable interrupts

.load_protected:
    cli  ; disable interrupts
    lgdt[gdt_descriptor]  ; load GDT register with start address of Global Descriptor Table
    mov eax, cr0
    or eax, 0x1  ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT (Global Descriptor Table) - https://wiki.osdev.org/Global_Descriptor_Table
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:  ; CS should point to this
    dw 0xffff  ; segment limit first 0-15 bits
    dw 0  ; base first 0-15 bits
    db 0  ; base 16-23 bits
    db 0x9a  ; access byte
    db 11001111b  ; high 4 bit flags and the low 4 bit flags
    db 0  ; base 24-31 bits

; offset 0x10
gdt_data:  ; DS, SS, ES, FS, GS
    dw 0xffff  ; segment limit first 0-15 bits
    dw 0  ; base first 0-15 bits
    db 0  ; base 16-23 bits
    db 0x92  ; access byte
    db 11001111b  ; high 4 bit flags and the low 4 bit flags
    db 0  ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $  ; jump to this line infinitely

times 510-($ - $$) db 0  ; pad up to 510 bytes with zeroes
dw 0xAA55  ; add boot signature at bytes 511 and 512
