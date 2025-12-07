#include "kernel.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <memory/memory.h>
#include <vga/vga.h>
#include <idt/idt.h>
#include <io/io.h>

void kernel_main() {
    init_terminal();
    const char hello_msg[] = "TienOS Alpha 0.1\n";
    terminal_write(hello_msg, strlen(hello_msg));

    idt_init();

}
