ORG 0x7c00
BITS 16

CODE_SEG equ gdt_cs - gdt_start
DATA_SEG equ gdt_ds - gdt_start

_start:
    jmp short start
    nop

; NOTE: For certain BIOSes and stuff like USB mediums,
; we must provide space for a structure called BPB,
; (BIOS Parameter Block) which can be all 0's for now.
times 33 db 0


start:
    jmp 0:start2

start2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable Interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32


gdt_start:
gdt_null:
    dq 0x0
gdt_cs:     ; CS SHOULD POINT TO THIS
    dw 0xffff ; Segment limit
    dw 0      ; Base fist 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x9a   ; Access byte
    db 11001111b ; High 4 bit flags and low 4 bit flags
    db 0 ; Base 24-31 bits
; offset 0x10
gdt_ds:     ; DS, SS, ES, FS, GS SHOULD POINT HERE
    dw 0xffff ; Segment limit
    dw 0      ; Base fist 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and low 4 bit flags
    db 0 ; Base 24-31 bits
gdt_end:
; Size + start address
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; PROTECTED MODE
[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00600000
    mov esp, ebp
    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55
