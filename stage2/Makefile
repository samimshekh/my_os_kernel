# Makefile - Bootloader + Second Stage Loader + C 
Build = ../build/
ASM = nasm
ASM_FLAGS = -f bin
elf_asm = -f elf32
CC = gcc
CFLAGS = -I ./include/ -m32 -mgeneral-regs-only -ffreestanding -fno-asynchronous-unwind-tables -fno-builtin \
         -fno-stack-protector -Wall -Wextra -mno-80387 -mno-fp-ret-in-387 \
         -fno-pic -fno-pie -nostdlib -nostartfiles -c

LD = ld
LD_FLAGS = -m elf_i386 -T ./c/linker.ld -Map=../linker.map

# Files
BOOT2_SRC = ./asm/second_stage.asm
C_SRC = ./c/main.c

BOOT1_BIN = $(Build)boot.bin
BOOT2_O = $(Build)second_stage.o
BOOT_IMG = $(Build)boot.img

OBJ = $(Build)main.o $(Build)second_stage.o

all: $(BOOT2_O) $(Build)second_stage.bin $(BOOT1_BIN) $(BOOT_IMG)

$(BOOT1_BIN):
	echo __lode_size equ $(shell stat -c%s $(Build)/second_stage.bin) > ../boot/lode_file.asm 
	cd ../boot && make

# Build second stage loader
$(BOOT2_O): $(BOOT2_SRC) $(PRINT_SRC)
	$(ASM) $(elf_asm) $(BOOT2_SRC) -o $(Build)$(BOOT2_O)

# Build C code
$(Build)main.o: $(C_SRC)
	$(CC) $(CFLAGS) $(C_SRC) -o $(Build)main.o

$(Build)second_stage.bin: $(Build)main.o
	$(LD) $(LD_FLAGS) $(Build)$(BOOT2_O) $(Build)main.o -o $(Build)second_stage.bin

# Create 1.44MB floppy image and write binaries
$(BOOT_IMG): $(BOOT2_O) $(Build)second_stage.bin $(BOOT1_BIN)
	dd if=/dev/zero of=$(BOOT_IMG) bs=512 count=2880
	dd if=$(BOOT1_BIN) of=$(BOOT_IMG) conv=notrunc bs=512 count=1
	dd if=$(Build)second_stage.bin of=$(BOOT_IMG) conv=notrunc bs=512 seek=1