# Makefile_lib
# 利用put.c生成put.o
all : put.o
.PHONY : all
put.o : put.c
	$(GCC) $(CFLAG) -o put.o -c put.c
.PHONY : clean run
clean :
	-rm -f put.o
