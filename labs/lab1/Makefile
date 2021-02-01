# Makefile_lab1
# 设置编译需要的变量，并利用make -C调用其需要控制的其他Make
export
CROSS_= riscv64-unknown-elf-
AR=${CROSS_}ar
GCC=${CROSS_}gcc
LD=${CROSS_}ld
OBJCOPY=${CROSS_}objcopy
ISA ?= rv64imafd
ABI ?= lp64
INCLUDE = -I ../include
CF = -O3 -march=$(ISA) -mabi=$(ABI) -mcmodel=medany -ffunction-sections -fdata-sections -nostartfiles -nostdlib -nostdinc -static -lgcc -Wl,--nmagic -Wl,--gc-sections
CFLAG = ${CF} ${INCLUDE}

OBJ=vmlinux
LDSFILE=./arch/riscv/kernel/vmlinux.lds
NM=${CROSS_}nm

all : $(OBJ) init riscv
.PHONY : all
.PHONY : init riscv
riscv:
	$(MAKE) -w -C arch/riscv
init:
	$(MAKE) -w -C init
$(OBJ) : riscv init
	# 生成vmlinux
	$(LD) -o ./$(OBJ) -T $(LDSFILE) ./init/main.o ./init/test.o ./arch/riscv/kernel/head.o
	# 生成System.map
	$(NM) $(OBJ) > System.map
	# 生成Image文件
	$(OBJCOPY) -O binary vmlinux ./arch/riscv/boot/Image --strip-all

.PHONY : clean
clean :
	-rm -f System.map vmlinux
	-rm -f arch/riscv/boot/Image
	$(MAKE) -w -C init clean
	$(MAKE) -w -C arch/riscv clean

.PHONY : run
run :
	qemu-system-riscv64 -nographic -machine virt -kernel vmlinux

.PHONY : debug
debug :
	qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -S -s
