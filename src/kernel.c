#include "kernel.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <memory/memory.h>
#include <vga/vga.h>
#include <idt/idt.h>
#include <io/io.h>
#include <memory/heap/kheap.h>

void kernel_main() {
    init_terminal();
    const char hello_msg[] = "TienOS Alpha 0.1\n";
    terminal_write(hello_msg, strlen(hello_msg));

    kheap_init();
    idt_init();

    // NOTE: Test the heap
    void* ptr = kmalloc(50);
    void* ptr2 = kmalloc(5000);
    void* ptr3 = kmalloc(5600);
    kfree(ptr);
    void* ptr4 = kmalloc(50);
    if (ptr || ptr2 || ptr3 || ptr4) {

    }
}
