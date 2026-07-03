#include <stdio.h>
#include <stdlib.h>
#include "tools.h"
#include "font8x8_basic.h"

void writeArrayToFile(void *array, int size, const char *filename, int integer)
{
    FILE *f = fopen(filename, "w");
    if (!f) {
        printf("Error opening file\n");
        return;
    }
    if (integer == 2) {
        char *arr = (char *)array;
        for (int i = 0; i < size; i++)
            fprintf(f, "%d\n", (int)arr[i]);
    } else if (integer == 1) {
        int *arr = (int *)array;
        for (int i = 0; i < size; i++)
            fprintf(f, "%d\n", (int)arr[i]);
    } else {
        float *arr = (float *)array;
        for (int i = 0; i < size; i++)
            fprintf(f, "%f\n", arr[i]);
    }

    fclose(f);
}


void fillArrayWithRandom(float *arr, int size) {
    for (int i = 0; i < size; i++) {
        float r = (float)rand() / (float)RAND_MAX;
        arr[i] = (float)r;
    }
}


void set_pixel(unsigned char *img, int w, int h, int x, int y, unsigned char r, unsigned char g, unsigned char b) {
    if (x < 0 || x >= w || y < 0 || y >= h)
        return;

    int idx = (y * w + x) * 3;

    img[idx + 0] = r;
    img[idx + 1] = g;
    img[idx + 2] = b;
}
void draw_box(unsigned char *img, int w, int h, int x1, int y1, int x2, int y2, int thickness, unsigned char r, unsigned char g, unsigned char b) {
    for (int t = 0; t < thickness; t++) {
        for (int x = x1; x <= x2; x++) {
            set_pixel(img, w, h, x, y1 + t, r, g, b);
            set_pixel(img, w, h, x, y2 - t, r, g, b);
        }

        for (int y = y1; y <= y2; y++) {
            set_pixel(img, w, h, x1 + t, y, r, g, b);
            set_pixel(img, w, h, x2 - t, y, r, g, b);
        }
    }
}


void draw_char(unsigned char *img, int w, int h, int x, int y, char c, unsigned char r, unsigned char g, unsigned char b) {
    if ((unsigned char)c >= 128) return;

    for (int row = 0; row < 8; row++) {
        uint8_t bits = font8x8_basic[(unsigned char)c][row];
        for (int col = 0; col < 8; col++) {
            if (bits & (1 << col)) {
                set_pixel(img, w, h, x + col, y + row, r, g, b);
            }
        }
    }
}

void draw_text(unsigned char *img, int w, int h, int x, int y, const char *text, unsigned char r, unsigned char g, unsigned char b) {
    while (*text) {
        draw_char(img, w, h, x, y, *text, r, g, b);
        x += 8;
        text++;
    }
}

void get_class_color(int class_id, unsigned char *r, unsigned char *g, unsigned char *b) {
    
    *r = (class_id * 123 + 50) % 256;
    *g = (class_id * 231 + 100) % 256;
    *b = (class_id * 77 + 150) % 256;

    // brighten dark colors
    if (*r < 64) *r += 128;
    if (*g < 64) *g += 128;
    if (*b < 64) *b += 128;
}

void fill_rect(unsigned char *img, int w, int h, int x1, int y1, int x2, int y2, unsigned char r, unsigned char g, unsigned char b){
    if (x1 > x2) { int t = x1; x1 = x2; x2 = t; }
    if (y1 > y2) { int t = y1; y1 = y2; y2 = t; }

    for (int y = y1; y <= y2; y++) {
        for (int x = x1; x <= x2; x++) {
            set_pixel(img, w, h, x, y, r, g, b);
        }
    }
}

