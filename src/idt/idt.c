#include "idt.h"
#include <memory/memory.h>
#include <config.h>
#include <vga/vga.h>
#include <io/io.h>

struct idt_desc idt_descriptors[TOTAL_INTERRUPTS];
struct idtr idtr_descriptor;

extern void idt_load(struct idtr* ptr);
extern void int21h();
extern void no_interrupt();

void int21h_handler() {
    char err[] = "Keyboard pressed!\n";
    terminal_write(err, strlen(err));
    outb(0x20, 0x20);
}

void no_interrupt_handler() {
    outb(0x20, 0x20);
}

void idt_zero() {
    char err[] = "Divide by zero fault!\n";
    terminal_write(err, strlen(err));
}

void idt_set(int int_no, void* addr) {
    struct idt_desc* desc = &idt_descriptors[int_no];
    desc->offset_1 = (uint32_t) addr & 0xffff;
    desc->selector = KERNEL_CS;
    desc->zero = 0x00;
    desc->type_attr = 0xee;
    desc->offset_2 = (uint32_t) addr >> 16;
}

// Loads the Interrupt Descriptor Table into the IDTR register
void idt_init() {
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors;

    for (size_t i = 0; i < TOTAL_INTERRUPTS; i++) {
        idt_set(i, no_interrupt);
    }

    idt_set(0, idt_zero);
    idt_set(0x21, int21h);

    idt_load(&idtr_descriptor);
}
