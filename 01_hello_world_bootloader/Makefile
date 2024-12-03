BUILD_DIR=./bin
TARGET=$(BUILD_DIR)/boot.bin

SRC_DIRS=./src/boot
ASM_FILES=$(foreach D,$(SRC_DIRS),$(wildcard $(D)/*.asm))

.PHONY: all
all: $(BUILD_DIR) | $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(ASM_FILES)
	nasm -f bin $^ -o $(TARGET)

run:
	qemu-system-x86_64 -hda $(TARGET)

clean:
	rm -rf $(BUILD_DIR)
