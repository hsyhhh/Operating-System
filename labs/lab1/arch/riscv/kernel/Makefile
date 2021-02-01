# Makefile_kernel
# 利用head.S生成head.o
head.o : head.S
	$(GCC) $(CFLAG) -o head.o -c head.S
.PHONY : clean
clean :
	-rm -f head.o
