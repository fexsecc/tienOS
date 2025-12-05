# Toolchain
CC := i686-elf-gcc
LD := i686-elf-ld
ASM := nasm

# Flags
INCLUDES := -I./src -I./inc
CFLAGS := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops \
          -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function \
          -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter \
          -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -std=gnu99
LDFLAGS := -g -relocatable

# Paths
SRCDIR := ./src
BUILDDIR := ./build
BINDIR := ./bin

# Sources / objects
C_SRCS := $(wildcard $(SRCDIR)/*.c)
ASM_SRCS := $(SRCDIR)/kernel.asm
ASM_BOOT := $(SRCDIR)/boot/boot.asm

C_OBJS := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(C_SRCS))
ASM_OBJS := $(BUILDDIR)/kernel.asm.o
KERNEL_OBJS := $(ASM_OBJS) $(BUILDDIR)/kernelfull.o  # kernelfull.o created during link step
ALL_FILES := $(ASM_OBJS) $(BUILDDIR)/kernel.o

.PHONY: all clean dirs

all: $(BINDIR)/boot.bin $(BINDIR)/kernel.bin
	@rm -f $(BINDIR)/os.bin
	dd if=$(BINDIR)/boot.bin >> $(BINDIR)/os.bin
	dd if=$(BINDIR)/kernel.bin >> $(BINDIR)/os.bin
	dd if=/dev/zero bs=512 count=100 >> $(BINDIR)/os.bin

# Boot binary
$(BINDIR)/boot.bin: $(ASM_BOOT) | dirs
	$(ASM) -f bin $< -o $@

# Assemble kernel asm (ELF)
$(ASM_OBJS): $(ASM_SRCS) | dirs
	$(ASM) -f elf -g $< -o $@

# Compile C sources to build/*.o
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | dirs
	$(CC) $(INCLUDES) $(CFLAGS) -c $< -o $@

# Produce kernelfull.o by collecting specific object files (use the actual list of objs you want)
# Here we link the asm object and all C object files into a relocatable kernelfull.o
$(BUILDDIR)/kernelfull.o: $(ASM_OBJS) $(C_OBJS)
	$(LD) $(LDFLAGS) $(ASM_OBJS) $(C_OBJS) -o $@

# Final linked kernel binary using linker script
$(BINDIR)/kernel.bin: $(BUILDDIR)/kernelfull.o | dirs
	$(CC) $(CFLAGS) -T $(SRCDIR)/linker.ld -o $@ -ffreestanding -O0 -nostdlib $(BUILDDIR)/kernelfull.o

dirs:
	mkdir -p $(BUILDDIR)
	mkdir -p $(BINDIR)

clean:
	rm -rf $(BINDIR)/*
	rm -rf $(BUILDDIR)/*

