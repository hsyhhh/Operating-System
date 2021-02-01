# Makefile_kernel
# 利用head.S, entry.S, strap.c生成head.o, entry.o, strap.o
all : head.o entry.o strap.o sched.o vm.o
.PHONY : all
head.o : head.S
	$(GCC) $(CFLAG) -o head.o -c head.S
entry.o : entry.S
	$(GCC) $(CFLAG) -o entry.o -c entry.S
strap.o : strap.c
	$(GCC) $(CFLAG) -o strap.o -c strap.c
sched.o : sched.c
	$(GCC) $(CFLAG) -o sched.o -c sched.c
vm.o : vm.c
	$(GCC) $(CFLAG) -o vm.o -c vm.c
.PHONY : clean
clean :
	-rm -f head.o entry.o strap.o sched.o vm.o
