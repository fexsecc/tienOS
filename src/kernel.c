#include "kernel.h"
#include <stdint.h>

void kernel_main() {
    int32_t idx = 0;
    for (int32_t i = 1; i <= 10; i++) {
        idx += i * 2;
    }
}
