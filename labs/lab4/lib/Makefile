# Makefile_lib
# 利用put.c生成put.o
# 利用rand.c生成rand.o
all : put.o rand.o
.PHONY : all
put.o : put.c
	$(GCC) $(CFLAG) -o put.o -c put.c
rand.o : rand.c
	$(GCC) $(CFLAG) -o rand.o -c rand.c
.PHONY : clean run
clean :
	-rm -f put.o rand.o
