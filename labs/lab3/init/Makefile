# Makefile_init
# 利用main.c和test.c生成main.o和test.o
all : main.o test.o
.PHONY : all
main.o : main.c
	$(GCC) $(CFLAG) -o main.o -c main.c
test.o : test.c
	$(GCC) $(CFLAG) -o test.o -c test.c 
.PHONY : clean run
clean :
	-rm -f main.o test.o
