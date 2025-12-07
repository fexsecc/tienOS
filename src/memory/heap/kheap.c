#include "kheap.h"
#include "heap.h"
#include <config.h>


struct heap kheap;
struct heap_table kheap_table;

void kheap_init() {
    size_t total_table_entries = KERNEL_HEAP_SIZE_BYTES / KERNEL_HEAP_BLOCK_SIZE; 
    kheap_table.entries = (HEAP_BLOCK_TABLE_ENTRY*)(KERNEL_HEAP_TABLE_ADDRESS);
    kheap_table.total = total_table_entries;

    void* end = (void*)(KERNEL_HEAP_ADDRESS + KERNEL_HEAP_SIZE_BYTES);
    int32_t res = heap_create(&kheap, (void*)(KERNEL_HEAP_ADDRESS), end, &kheap_table);
    if (res < 0) {
	// TODO: Make a panic function

    }
}


void* kmalloc(size_t size) {
    return heap_malloc(&kheap, size);
}

void kfree(void* ptr) {
    heap_free(&kheap, ptr);
}
