# Second Stage Loader (x86 i686)

## Overview
Ye project **second stage bootloader** ke liye hai jo **floppy disk se sector read karke** memory me load hota hai aur execution start karta hai. Ye loader **first stage bootloader ke baad** run hota hai.  

- **Target Architecture:** x86 i686 (32-bit)  
- **Boot Mode:** BIOS Real Mode  
- **Load Address:** `0x7E00` (memory segment where second stage is loaded)  
- **Disk Service:** BIOS INT 13h ([Ralf Brown's Interrupt List: INT 13h](https://en.wikipedia.org/wiki/INT_13H)) 
- **Sector Loaded:** Defined by `__LODE_SECTOR` constant  

---

## Flow of Execution

1. **First Stage Bootloader**  
   - Loaded by BIOS at `0x7C00`  
   - Reads second stage loader from floppy disk using **INT 13h**  

2. **Second Stage Loader**  
   - Loaded at memory **0x7E00**  
   - Reads **`__LODE_SECTOR`** sectors from disk (usually sector 1 or more)  
   - Prints status message `[INFO] Second Stage Loader successfully loaded at 0x7E00 and running...`  
   - Enters infinite loop / waits for further tasks  

---

## Key Constants

| Constant | Purpose |
|----------|---------|
| `__LODE_SECTOR` | Number of sectors to read from floppy. Defines how much data to load in memory. |
| `0x7E00`       | Memory address where second stage loader is loaded by first stage. |
| `INT 13h`      | BIOS interrupt used for disk read operations. Handles floppy/hard disk access. |

---

## Disk Read (INT 13h)

- **INT 13h AH=02h** → Read sector(s) from disk  
- **Registers Used**:  
  - `AH` = 02h (read)  
  - `AL` = number of sectors to read (`__LODE_SECTOR`)  
  - `CH` = cylinder  
  - `CL` = sector number  
  - `DH` = head  
  - `DL` = drive number (0 = floppy, 80h = first HDD)  
  - `ES:BX` = memory address to load sector(s)  

- **Error Handling:**  
  - Retry up to 3 times on failure  
  - If read fails, prints `[ERROR] Read from disk failed!` and halts  

---

## Files

```

.
├── second_stage.asm   # Second stage loader code
├── print.asm          # Print routine for screen output
├── Makefile           # Compile and create bootable floppy image
└── README.md          # This documentation

````

---

## Build & Run

```bash
# Build second stage loader and floppy image
make

# Run in QEMU
make run

# Clean build files
make clean
````

---

## Notes

* Always make sure `__LODE_SECTOR` matches the **number of sectors occupied by second stage loader**
* Loader assumes **first stage bootloader** has already executed
* Memory address `0x7E00` must not overlap with first stage bootloader (`0x7C00`)
* INT 13h is **mandatory BIOS call** for floppy/hard disk reads in real mode

```