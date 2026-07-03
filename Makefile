ARCH := $(shell uname -m)

ifeq ($(ARCH),aarch64)
    CC := gcc
    RUN :=
else
    CC := aarch64-linux-gnu-gcc
    RUN := qemu-aarch64
endif

# Build flags
CFLAGS := -O0 \
          -march=armv8-a+simd+fp16 \
          -ftree-vectorize \
          -fopenmp \


LDFLAGS := -lm

# Source files
SRC := main.c  tools/tools.c buffer.s  padding.s indirection.s \
        conv.c buffer.s winograd.c activation_function.s loader.c \
       $(wildcard microkernels/*.s fused_ops/*.s modules/*.c modules/*.s ops/*.s)

TARGET := conv

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

run: $(TARGET)
	$(RUN) ./$(TARGET)

clean:
	rm -f $(TARGET)
