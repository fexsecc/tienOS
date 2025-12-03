#!/bin/sh
mkdir -p bin build
export PREFIX="/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
make all
