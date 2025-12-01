; nasm -f bin boot.asm -o boot.bin
; qemu-system-x86_64 -hda boot.bin
ORG 0
BITS 16

_start:
    jmp short start
    nop

; NOTE: For certain BIOSes and stuff like USB mediums,
; we must provide space for a structure called BPB,
; (BIOS Parameter Block) which can be all 0's for now.
times 33 db 0


start:
    ; Set CS to 0x7c0 and jmp to start(2)
    jmp 0x7c0:start2

start2:
    cli ; Clear Interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable Interrupts

    lea si, [message]
    call print

    jmp $

print:
    xor bx, bx
.loop:
    lodsb
    test al, al
    je .ret
    call print_char
    jmp .loop
.ret:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message:
    db 'Hello Bootloader!', 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
