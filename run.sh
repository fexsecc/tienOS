#!/bin/sh

set -e

if [ "$1" = "gdb" ]; then
    qemu-system-i386 -hda ./bin/os.bin -s -S
else
    qemu-system-i386 -hda ./bin/os.bin
fi
