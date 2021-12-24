# !!! Change this to your specific Raspberry Pi version
RPI_VERSION ?= 4

# ARM cross compiler toolchain
ARMGNU ?= aarch64-none-elf

# Set the CPU architecture based on the Raspberry Pi version
ifeq ($(RPI_VERSION), 4)
CPU_VER ?= cortex-a72
else
CPU_VER ?= cortex-a53
endif

# Files to load to SD card (to deploy)
BOOTMNT ?= boot
ifeq ($(RPI_VERSION), 4)
BOOTMNT = boot\boot4
else ifeq ($(RPI_VERSION), 3)
BOOTMNT = boot\boot3
endif

# C operations (to compile properly)
COPS = -DRPI_VERSION=$(RPI_VERSION) -Wall -nostdlib -nostartfiles -ffreestanding \
	   -Iinclude -mgeneral-regs-only -mcpu=$(CPU_VER)

# ASM operations (to compile properly)
ASMOPS = -Iinclude

# Directory for object files to live (and die)
BUILD_DIR = build

# Directory for OS source code to live
SRC_DIR = src

# File to make
all : clean kernel.img

# Cleans up all object files and build directory
clean : 
	del /Q $(BUILD_DIR)\*
	del $(BOOTMNT)\*.img

# Build targets for all C files
$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

# Build targets for all assembly files
$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

# Build targets for all files (C and assembly, wildcards for all files in directory)
C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

# Build targets for dependency files
DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

# Build target for kernel8.img
kernel.img: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	@echo Building for RPI $(value RPI_VERSION)
	@echo Deploy to $(value BOOTMNT)
	@echo Using $(value ARMGNU)
	$(ARMGNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel.elf $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BUILD_DIR)/kernel.img
ifeq ($(RPI_VERSION), 4)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BOOTMNT)/kernel7l.img
else
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BOOTMNT)/kernel7.img
endif
