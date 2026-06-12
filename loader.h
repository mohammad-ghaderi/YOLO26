// load_weights.h
#ifndef LOADER_H
#define LOADER_H

#define NUM_PARAM 2713960
#define IMAGE_SIZE 640*640*3

extern float params[NUM_PARAM];
extern unsigned char img[IMAGE_SIZE];

int load_weights(void);
int load_image(void);

#endif