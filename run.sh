#!/bin/sh

set -e

if [ "$1" = "gdb" ]; then
    qemu-system-x86_64 -hda ./bin/os.bin -s -S
else
    qemu-system-x86_64 -hda ./bin/os.bin
fi
