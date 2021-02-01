#include "test.h"
#include "put.h"
#include "rand.h"

int os_test()
{
	const char *msg = "ZJU OS LAB 4  GROUP-XX  31xxxxxxxx\n";

    puts(msg);
    task_init();
	int x = 0;
	while(1) {
		if(x > 1000000) {
			// puts("In os_test\n");
			x = 0;
		}
		x++;
	}

    return 0;
}

