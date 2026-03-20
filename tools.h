#ifndef WRITE_ARRAY_H
#define WRITE_ARRAY_H

#include <stdint.h>
#include <stddef.h>

void writeArrayToFile(void *array, int size, const char *filename, const char *format, size_t elem_size);

#endif
