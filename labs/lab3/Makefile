# Makefile_lab2
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
CFLAG = ${CF} ${INCLUDE} -DSJF

OBJ=vmlinux
LDSFILE=./arch/riscv/kernel/vmlinux.lds
NM=${CROSS_}nm

all : $(OBJ) init riscv lib
.PHONY : all
.PHONY : init riscv lib
riscv : 
	$(MAKE) -w -C arch/riscv
lib :
	$(MAKE) -w -C lib
init :
	$(MAKE) -w -C init
$(OBJ) : riscv init lib
	# 生成vmlinux
	$(LD) -o ./$(OBJ) -T $(LDSFILE) ./init/main.o ./init/test.o ./lib/put.o ./lib/rand.o ./arch/riscv/kernel/head.o ./arch/riscv/kernel/entry.o ./arch/riscv/kernel/strap.o ./arch/riscv/kernel/sched.o
	# 生成System.map
	$(NM) -n $(OBJ) > System.map
	# 生成Image文件
	$(OBJCOPY) -O binary vmlinux ./arch/riscv/boot/Image --strip-all

.PHONY : clean
clean :
	-rm -f System.map vmlinux
	-rm -f arch/riscv/boot/Image
	$(MAKE) -w -C init clean
	$(MAKE) -w -C arch/riscv clean
	$(MAKE) -w -C lib clean

.PHONY : run
run :
	qemu-system-riscv64 -nographic -machine virt -kernel vmlinux

.PHONY : debug
debug :
	qemu-system-riscv64 -nographic -machine virt -kernel vmlinux -S -s
