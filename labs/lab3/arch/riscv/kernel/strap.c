#include "put.h"
#include "sched.h"
#define uLL unsigned long long
int count = 0;
int tmpcount = 0;
void handler_s(uLL cause, uLL epc) {
	const char *msg = "[S] Supervisor Mode Timer Interrupt ";
	if(cause >> 63) {	// interrupt
		if( ((cause << 1) >> 1) == 5) {	// supervisor time interrupt
			tmpcount++;
			if(tmpcount == 100) {
				// puts(msg);
				// puti(count++);
				// puts("\n");
				tmpcount = 0;
				do_timer();
				// puts("do_timer() done.\n");
			}
			asm volatile("ecall");
		}
	}
	return;
}

void testputs(void) {
	puts("here in testputs\n");
	return;
}
