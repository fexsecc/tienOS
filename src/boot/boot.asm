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

; Load kernel into mem and jump to it
[BITS 32]
load32:
    ; starting sector
    mov eax, 1
    ; sector count
    mov ecx, 100
    ; 1M, addr to load them at
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; Backup LBA (LOGICAL BLOCK ADDRESS)
    ; Send highest 8 bits of LBA to disk controller
    shr eax, 24
    or eax, 0xE0 ; Select the master drive
    mov dx, 0x1F6
    out dx, al
    ; Send sector count to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Send more bits of the LBA
    mov eax, ebx
    mov dx, 0x1F3
    out dx, al
    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    ; Send more bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; Finished writing LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

; Read all sectors into memory
.next_sector:
    push ecx

; Checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

    ; We need to read 256 words at a time (512 bytes / 1 sector)
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret

times 510 - ($ - $$) db 0
dw 0xAA55
