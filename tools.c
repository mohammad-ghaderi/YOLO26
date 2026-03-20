#include <stdio.h>
#include <stdlib.h>
#include "tools.h"

void writeArrayToFile(void *array, int size, const char *filename, const char *format, size_t elem_size)
{
    FILE *f = fopen(filename, "w");
    if (!f) {
        printf("Error opening file\n");
        return;
    }

    for (int i = 0; i < size; i++) {
        void *element = (char *)array + i * elem_size;

        if (elem_size == sizeof(int))
            fprintf(f, format, *(int *)element);
        else if (elem_size == sizeof(float))
            fprintf(f, format, *(float *)element);
        else if (elem_size == sizeof(double))
            fprintf(f, format, *(double *)element);
        else if (elem_size == sizeof(long))
            fprintf(f, format, *(long *)element);
        else if (elem_size == sizeof(int8_t))
            fprintf(f, format, *(int8_t *)element);

        fprintf(f, "\n");
    }

    fclose(f);
}


void fillArrayWithRandom(int8_t *arr, int size) {
    for (int i = 0; i < size; i++) *(arr+i) = (rand()%100)-49;
}