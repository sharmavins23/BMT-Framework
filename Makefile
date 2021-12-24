# ! Change this to your specific Raspberry Pi Version!
RPi_VERSION ?= 4

# Change this to your AARCH64 Cross Compiler, if you have a different one
AARCH64CC   ?= aarch64-none-elf

# ==============================================================================
# RPI structure flags

# RPi Version - Defaults to 4b
ifeq ($(RPi_VERSION), 4)
CPU_VER     ?= cortex-a72
else ifeq ($(RPi_VERSION), 3)
CPU_VER     ?= cortex-a53
else
CPU_VER     ?= cortex-a72
endif

# ==============================================================================
# File directory locations

# Copy these files to SD for deployment
ifeq ($(RPi_VERSION), 4)
BOOTMNT     ?= /boot/boot4
else ifeq ($(RPi_VERSION), 3)
BOOTMNT     ?=  /boot/boot3
else
BOOTMNT     ?=  /boot/boot4
endif

# Temporary directory for all object files
BUILD_DIR   = /build

# Directory for source code
SRC_DIR     = /src

# ==============================================================================
# Compile flags and files

# GCC operations for C code
COPS        = -DRPI_VERSION=$(RPi_VERSION)     \
	        -Wall                              \
	        -nostdlib                          \
	        -nostartfiles                      \
	        -ffreestanding                     \
	        -Iinclude                          \
	        -mgeneral-regs-only                \
	        -mcpu=$(CPU_VER)

# GCC operations for Assembly code
ASMOPS      = -Iinclude

# Compiled file locations
C_FILES     = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES   = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES   = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES   += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

# ==============================================================================
# Build targets

# Ran when the makefile is run via `make`
all         : clean kernel8.img

# Clean all intermediate files, and the compiled kernel image
clean       : del $(BOOTMNT)/*.img
			del $(BUILD_DIR)/*

# Build the kernel image to deploy onto SD card
kernel8.img : $(SRC_DIR)/linker.ld $(OBJ_FILES)
			@echo Building for RPi $(value RPI_VERSION)
			@echo Deploy to $(value BOOTMNT)
			@echo Using $(value AARCH64CC)
			$(AARCH64CC)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel.elf $(OBJ_FILES)
			$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BUILD_DIR)/kernel.img
ifeq ($(RPI_VERSION), 4)
			$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BUILD_DIR)/kernel7l.img
else ifeq ($(RPI_VERSION), 3)
			$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BUILD_DIR)/kernel7.img
else
			$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary $(BUILD_DIR)/kernel7l.img