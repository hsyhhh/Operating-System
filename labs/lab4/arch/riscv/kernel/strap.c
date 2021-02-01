#include "put.h"
#include "sched.h"
#define uLL unsigned long long
extern unsigned long long get__end(void);
int count = 0;
int tmpcount = 0;
void handler_s(uLL cause, uLL epc) {
	const char *msg = "[S] Supervisor Mode Timer Interrupt ";
	if(cause >> 63) {	// interrupt
		if(((cause << 1) >> 1) == 5) {	// supervisor time interrupt
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
	} else { // exception
		if(cause == 12) {
			puts("here in Instuction page fault\n");
		} else if(cause == 13) {
			puts("here in Load page fault\n");
		} else if(cause == 15) {
			puts("here in Store page fault\n");
		}
		// set sepc += 4
		// asm volatile("csrr t0, sepc");
		// asm volatile("addi t0, t0, 4");
		// asm volatile("csrw sepc, t0");
	}
	return;
}

void testputs(void) {
	puts("here in testputs\n");
	return;
}