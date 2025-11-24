Build = ./build/
BOOT_IMG = $(Build)boot.img
all:
	cd ./stage2/ && make 

run: all
	qemu-system-i386 -fda $(BOOT_IMG)

clean:
	rm -f $(Build)*.bin $(Build)*.o $(BOOT_IMG) linker.map