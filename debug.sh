#!/bin/bash

FILE="conv"

qemu-aarch64 -g 1234 ./${FILE} & sleep 1

gdb-multiarch -tui ./${FILE} -ex "set architecture aarch64" -ex "target remote :1234" -ex "break conv_4x8_indir_packweight" -ex "continue"