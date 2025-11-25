Build = ../build/
BOOT1_SRC = boot.asm
BOOT1_BIN = $(Build)boot.bin
ASM = nasm
ASM_FLAGS = -f bin
elf_asm = -f elf32

all: $(BOOT1_BIN)

# Build first stage bootloader
$(BOOT1_BIN): $(BOOT1_SRC)
	$(ASM) $(ASM_FLAGS) $(BOOT1_SRC) -o $(BOOT1_BIN)