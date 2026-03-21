#!/bin/bash

FILE="conv"

ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    echo "Intel architecture detected. Using qemu-aarch64..."
    qemu-aarch64 -g 1234 ./${FILE} & sleep 1
    gdb-multiarch -tui ./${FILE} \
        -ex "set architecture aarch64" \
        -ex "target remote :1234" \
        -ex "break main" \
        -ex "continue"

elif [ "$ARCH" == "aarch64" ]; then
    echo "AArch64 architecture detected. Using gdb directly..."
    gdb -tui ./${FILE} \
        -ex "break main" \
        -ex "run"

else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
