ORG 0
BITS 16

_start:  ; offset 0 of the BIOS Parameter Block - https://wiki.osdev.org/FAT#BPB_(BIOS_Parameter_Block)
    jmp short start
    nop

; pad 33 bytes with zeroes to make a fake BIOS
; Parameter Block in case the BIOS modifies values
times 33 db 0

start:
    jmp 0x7c0:main

main:
    cli  ; clear interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti  ; enable interrupts

    mov si, message  ; move address of label: message into the si register
    call print
    jmp $  ; jump to this line infinitely

print:
    mov bx, 0

.loop:
    lodsb  ; load a byte at address stored in si register into the al register
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:
    ret

print_char:
    ; http://www.ctyme.com/intr/rb-0106.htm
    mov ah, 0eh  ; video - teletype output (Ralf Brown's Interrupt List)
    int 0x10  ; call bios routine to display a character loaded in the al register onto the screen
    ret

message: db 'Hello World!', 0 ; set up a label named message

times 510-($ - $$) db 0  ; pad up to 510 bytes with zeroes
dw 0xAA55  ; add boot signature at bytes 511 and 512
