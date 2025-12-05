#include "idt.h"
#include <memory/memory.h>
#include <config.h>
#include <vga/vga.h>

struct idt_desc idt_descriptors[TOTAL_INTERRUPTS];
struct idtr idtr_descriptor;

extern void idt_load(struct idtr* ptr);

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

    idt_set(0, idt_zero);

    idt_load(&idtr_descriptor);
}
