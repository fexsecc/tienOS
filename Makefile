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

# Boot file (keep separate)
ASM_BOOT := $(SRCDIR)/boot/boot.asm

# Find sources recursively, excluding boot directory
C_SRCS := $(filter-out $(SRCDIR)/boot/%,$(shell find $(SRCDIR) -name '*.c'))
ASM_SRCS := $(filter-out $(SRCDIR)/boot/%,$(shell find $(SRCDIR) -name '*.asm'))
HDRS    := $(filter-out $(SRCDIR)/boot/%,$(shell find $(SRCDIR) -name '*.h'))

# Convert source paths to object paths under build/, preserving dirs
C_OBJS := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(C_SRCS))
ASM_OBJS := $(patsubst $(SRCDIR)/%.asm,$(BUILDDIR)/%.asm.o,$(ASM_SRCS))

# KERNEL_OBJS: all asm objects (non-boot) plus C objects
KERNEL_OBJS := $(ASM_OBJS) $(C_OBJS)
ALL_FILES := $(ASM_OBJS) $(C_OBJS) $(HDRS)

.PHONY: all clean dirs

all: $(BINDIR)/boot.bin $(BINDIR)/kernel.bin
	@rm -f $(BINDIR)/os.bin
	dd if=$(BINDIR)/boot.bin >> $(BINDIR)/os.bin
	dd if=$(BINDIR)/kernel.bin >> $(BINDIR)/os.bin
	dd if=/dev/zero bs=512 count=100 >> $(BINDIR)/os.bin

# Boot binary (unchanged)
$(BINDIR)/boot.bin: $(ASM_BOOT) | dirs
	$(ASM) -f bin $< -o $@

# Rule to assemble kernel asm files (ELF) into corresponding build/.../*.asm.o
# Preserve subdirs: ensure target directory exists before building
$(BUILDDIR)/%.asm.o: $(SRCDIR)/%.asm | dirs
	mkdir -p $(dir $@)
	$(ASM) -f elf -g $< -o $@

# Compile C sources to build/.../*.o (preserve subdirs)
$(BUILDDIR)/%.o: $(SRCDIR)/%.c | dirs
	mkdir -p $(dir $@)
	$(CC) $(INCLUDES) $(CFLAGS) -c $< -o $@

# Produce kernelfull.o by linking all kernel objects (relocatable)
$(BUILDDIR)/kernelfull.o: $(KERNEL_OBJS) | dirs
	$(LD) $(LDFLAGS) $(KERNEL_OBJS) -o $@

# Final linked kernel binary using linker script
$(BINDIR)/kernel.bin: $(BUILDDIR)/kernelfull.o | dirs
	$(CC) $(CFLAGS) -T $(SRCDIR)/linker.ld -o $@ -ffreestanding -O0 -nostdlib $(BUILDDIR)/kernelfull.o

dirs:
	mkdir -p $(BUILDDIR)
	mkdir -p $(BINDIR)

clean:
	rm -rf $(BINDIR)/*
	rm -rf $(BUILDDIR)/*

