# Makefile - Bootloader + Second Stage Loader + C 

ASM = nasm
ASM_FLAGS = -f bin
elf_asm = -f elf32
CC = gcc
CFLAGS = -m32 -mgeneral-regs-only -ffreestanding -fno-asynchronous-unwind-tables -fno-builtin \
         -fno-stack-protector -Wall -Wextra -mno-80387 -mno-fp-ret-in-387 \
         -fno-pic -fno-pie -nostdlib -nostartfiles -c

LD = ld
LD_FLAGS = -m elf_i386 -T linker.ld -Map=linker.map

# Files
BOOT1_SRC = boot.asm
BOOT2_SRC = second_stage.asm
PRINT_SRC = print.asm
C_SRC = main.c

BOOT1_BIN = boot.bin
BOOT2_O = second_stage.o
BOOT_IMG = boot.img

OBJ = main.o second_stage.o

all: $(BOOT1_BIN) $(BOOT2_O) second_stage $(BOOT_IMG)

# Build first stage bootloader
$(BOOT1_BIN): $(BOOT1_SRC)
	$(ASM) $(ASM_FLAGS) $(BOOT1_SRC) -o $(BOOT1_BIN)

# Build second stage loader
$(BOOT2_O): $(BOOT2_SRC) $(PRINT_SRC)
	$(ASM) $(elf_asm) $(BOOT2_SRC) -o $(BOOT2_O)

# Build C code
main.o: $(C_SRC)
	$(CC) $(CFLAGS) $(C_SRC) -o main.o

second_stage: main.o
	$(LD) $(LD_FLAGS) $(BOOT2_O) main.o -o second_stage.bin

# Create 1.44MB floppy image and write binaries
$(BOOT_IMG): $(BOOT1_BIN) $(BOOT2_O) second_stage
	dd if=/dev/zero of=$(BOOT_IMG) bs=512 count=2880
	dd if=$(BOOT1_BIN) of=$(BOOT_IMG) conv=notrunc bs=512 count=1
	dd if=second_stage.bin of=$(BOOT_IMG) conv=notrunc bs=512 seek=1

run: $(BOOT_IMG)
	qemu-system-i386 -fda $(BOOT_IMG)

clean:
	rm -f *.bin *.o $(BOOT_IMG) linker.map
