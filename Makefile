# bootloader build script

ASM = nasm
ASM_FLAGS = -f bin

# Source files
BOOT1_SRC = boot.asm
BOOT2_SRC = second_stage.asm
PRINT_SRC = print.asm

# Output files
BOOT1_BIN = boot.bin
BOOT2_BIN = second_stage.bin
BOOT_IMG = boot.img

# Default target: build bootloader and floppy image
all: $(BOOT1_BIN) $(BOOT2_BIN) $(BOOT_IMG)

# Build first stage bootloader
$(BOOT1_BIN): $(BOOT1_SRC)
	$(ASM) $(ASM_FLAGS) $(BOOT1_SRC) -o $(BOOT1_BIN)

# Build second stage loader
$(BOOT2_BIN): $(BOOT2_SRC) $(PRINT_SRC)
	$(ASM) $(ASM_FLAGS) $(BOOT2_SRC) -o $(BOOT2_BIN)

# Create 1.44MB floppy image and write bootloader + second stage
$(BOOT_IMG): $(BOOT1_BIN) $(BOOT2_BIN)
	# Create empty floppy
	dd if=/dev/zero of=$(BOOT_IMG) bs=512 count=2880
	# Write first stage bootloader to first sector
	dd if=$(BOOT1_BIN) of=$(BOOT_IMG) conv=notrunc bs=512 count=1
	# Write second stage loader starting from sector 2
	dd if=$(BOOT2_BIN) of=$(BOOT_IMG) conv=notrunc bs=512 seek=1

# Run the image in QEMU
run: $(BOOT_IMG)
	qemu-system-i386 -fda $(BOOT_IMG)

# Clean build files
clean:
	rm -f $(BOOT1_BIN) $(BOOT2_BIN) $(BOOT_IMG)
