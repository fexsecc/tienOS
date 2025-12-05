#include "kernel.h"
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "string.h"
#include "vga.h"


void kernel_main() {
    init_terminal();
    char buf[] = "Hello kernel\n";
    terminal_write(buf, strlen(buf));
    char buf2[] = "Hello kernel 2!\n";
    for (size_t i = 0; i < 2; i++) {
	terminal_write(buf2, strlen(buf2));
    }
    char buf3[] = "Hello kernel 3!\n";
    for (size_t i = 0; i < 20; i++) {
	terminal_write(buf3, strlen(buf3));
    }

    terminal_write(buf, strlen(buf));
    //terminal_write(buf, strlen(buf));
}
