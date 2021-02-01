# Makefile_kernel
# 利用head.S, entry.S, strap.c生成head.o, entry.o, strap.o
all : head.o entry.o strap.o
.PHONY : all
head.o : head.S
	$(GCC) $(CFLAG) -o head.o -c head.S
entry.o : entry.S
	$(GCC) $(CFLAG) -o entry.o -c entry.S
strap.o : strap.c
	$(GCC) $(CFLAG) -o strap.o -c strap.c
.PHONY : clean
clean :
	-rm -f head.o entry.o strap.o
