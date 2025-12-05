#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>


size_t strlen(const char* str);
void* memcpy(void* dest, const void* src, size_t n);
void* memset(void* s, uint8_t c, size_t n);
