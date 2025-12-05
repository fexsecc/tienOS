#pragma once
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


struct idt_desc {
	uint16_t offset_1;
	uint16_t selector;
	uint8_t zero;
	uint8_t type_attr;
	uint16_t offset_2;
} __attribute__((packed));

struct idtr {
	uint16_t limit;
	uint32_t base;
} __attribute__((packed));


void idt_init();
extern void idt_load(struct idtr* ptr);
void idt_set(int int_no, void* addr);
