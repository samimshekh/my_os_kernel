# Boot sector build script
ASM = nasm
ASM_FLAGS = -f bin

all: boot.bin boot.img

# Build boot binary
boot.bin: boot.asm
	$(ASM) $(ASM_FLAGS) boot.asm -o boot.bin

# Create 1.44MB floppy image and write boot.bin with dd
boot.img: boot.bin
	dd if=/dev/zero of=boot.img bs=512 count=2880
	dd if=boot.bin of=boot.img conv=notrunc bs=512 count=1

# Run with QEMU
run: boot.img
	qemu-system-i386 -fda boot.img 

# Clean build files
clean:
	rm -f boot.bin boot.img
