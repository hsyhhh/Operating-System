#include "test.h"
#include "put.h"
#include "rand.h"
#include "sched.h"

int os_test()
{
	const char *msg = "ZJU OS LAB 2  GROUP-XX  31xxxxxxxx\n";

    puts(msg);
    task_init();
	while(1) ;

    return 0;
}
