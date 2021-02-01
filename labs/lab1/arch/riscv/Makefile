# Makefile_riscv
# 使用ld并将main.o，test.o，head.o等目标文件以及lds文件（利用ld的-T选项）
# 生成vmlinux文件到指定目录下，并使用OBJCOPY利用vmlinux生成Image文件到指定目录。
kernel/head.o: kernel/head.S
	$(MAKE) -w -C kernel

.PHONY : clean
clean:
	$(MAKE) -w -C kernel clean
