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
          -march=armv8-a+simd \
          -ftree-vectorize \
          -fopenmp \
          -g

# Source files
SRC := main.c \
       tools.c \
       padding.s\
       $(wildcard microkernels/*.s)

TARGET := conv

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $^ -o $@

run: $(TARGET)
	$(RUN) ./$(TARGET)

clean:
	rm -f $(TARGET)
