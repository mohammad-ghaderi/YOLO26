#!/bin/bash

FILE="conv"

qemu-aarch64 -g 1234 ./${FILE} & sleep 1

gdb-multiarch -tui ./${FILE} -ex "set architecture aarch64" -ex "target remote :1234" -ex "break add_padding" -ex "continue"