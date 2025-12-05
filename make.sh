mkdir -p build
nasm -f elf32 ./boot/kernel.asm -o ./build/kernel.o
ld -m elf_i386 -T ./boot/link.ld  ./build/kernel.o -Map=linker.map -o ./build/kernel.bin
kernel_size=$(stat -c%s ./build/kernel.bin)
echo "kernel_size equ $kernel_size" > ./boot/kernel_size.inc
nasm -f bin ./boot/boot.asm -o ./build/boot.bin
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=./build/boot.bin of=floppy.img bs=512 count=1 conv=notrunc
dd if=./build/kernel.bin of=floppy.img bs=512 seek=1 conv=notrunc
qemu-system-i386 -fda floppy.img