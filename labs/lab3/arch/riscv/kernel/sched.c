#include "sched.h"
#include "put.h"
// in entry.S
extern void switch_thread_struct(struct thread_struct *current, struct thread_struct *next);
extern void task_init_ra(void);

/* 当前进程 */
struct task_struct *current;

/* 进程指针数组 */
struct task_struct * task[NR_TASKS];

/* 进程初始化 创建四个dead_loop进程 */
void task_init(void) {
	puts("task init...\n");
	// initialize current and task[0]
	current = (struct task_struct *)0x80010000;
	task[0] = current;
	task[0]->state = TASK_RUNNING;
	task[0]->counter = 0;
	task[0]->priority = 5;
	task[0]->blocked = 0;
	task[0]->pid = 0;
	(task[0]->thread).sp = (unsigned long long)(0x80010000 + TASK_SIZE);
	// initialize task[1-4]
	int i;
	for(i = 1; i <= 4; i++) {
		task[i] = (struct task_struct *)(0x80010000 + TASK_SIZE * i);
		task[i]->state = TASK_RUNNING;
		task[i]->blocked = 0;
		task[i]->pid = i;
		(task[i]->thread).sp = (unsigned long long)(0x80010000 + TASK_SIZE * (i+1));
		// initialize ra
		(task[i]->thread).ra = (unsigned long long)task_init_ra;
	#ifdef SJF
		task[i]->counter = rand();
		task[i]->priority = 5;
	#endif
	#ifdef PRIORITY
		task[i]->counter = 8 - i;
		task[i]->priority = 5;
	#endif
		puts("[PID = ");
		puti(i);
		puts("] Process Create Successfully! counter = ");
		puti(task[i]->counter);
	#ifdef PRIORITY
		puts(" priority = ");
		puti(task[i]->priority);
	#endif
		puts("\n");
	}
}

/* 在时钟中断处理中被调用 */
void do_timer(void) {
	// puts("In do_timer\n");
#ifdef SJF
	puts("[PID = ");
	puti(current->pid);
	puts("] Context Calculation: counter = ");
	puti(current->counter); puts("\n");
#endif
	current->counter--;
#ifdef SJF
	
	if(current->counter <= 0) {
		schedule();
	} else {
		return;
	}
#endif
#ifdef PRIORITY
	if(current->counter <= 0) {
		current->counter = 8 - current->pid;
	}
	schedule();
#endif
}

/* 调度程序 */
void schedule(void) {
	// puts("In schedule\n");
#ifdef SJF
	int next_task, min_counter;
	int i, flag;
	while(1) {
		// puts("in while\n");
		min_counter = 1000;
		next_task = 0;
		flag = 0;
		for(i = NR_TASKS-1; i > 0; i--) {
			if(task[i]) {
				// puti(i);
				if(task[i]->state == TASK_RUNNING &&
				   task[i]->counter < min_counter &&
				   task[i]->counter > 0) {
					min_counter = task[i]->counter;
					next_task = i;
					flag = 1;
				}
			}
		}
		if(flag)
			break;
		// reset counter
		for(i = 1; i < NR_TASKS; i++) {
			if(task[i]) {
				task[i]->counter = rand();
				puts("[PID = "); puti(i); puts("] Reset counter = ");
				puti(task[i]->counter); puts("\n");
			}
		}
	}
	puts("[!] Switch from task "); puti(current->pid); puts(" to task "); puti(task[next_task]->pid); 
	puts(", prio: "); puti(task[next_task]->priority);
	puts(", counter: "); puti(task[next_task]->counter); puts("\n");

	switch_to(task[next_task]);
#endif
#ifdef PRIORITY
	int next_task = 0;
	int min_counter = 1000;
	int max_priority = 6;
	int i;
	// find maximum priority
	for(i = NR_TASKS-1; i > 0; i--) {
		if(task[i]) {
			if(task[i]->state == TASK_RUNNING && task[i]->counter > 0 && task[i]->priority < max_priority) {
				max_priority = task[i]->priority;
			}
		}
	}
	// find minimum counter
	for(i = NR_TASKS-1; i > 0; i--) {
		if(task[i]) {
			if(task[i]->state == TASK_RUNNING &&
			   task[i]->priority == max_priority &&
			   task[i]->counter < min_counter) {
				min_counter = task[i]->counter;
				next_task = i;
			}
		}
	}
	// switch
	puts("[!] Switch from task "); puti(current->pid); puts(" to task "); puti(task[next_task]->pid); 
	puts(", prio: "); puti(task[next_task]->priority);
	puts(", counter: "); puti(task[next_task]->counter); puts("\n");
	// reset priority
	puts("tasks' priority changed\n");
	for(i = 1; i < NR_TASKS; i++) {
		if(task[i]) {
			task[i]->priority = rand();
			puts("[PID = "); puti(i); puts("]counter = ");
			puti(task[i]->counter); puts(" priority = ");
			puti(task[i]->priority); puts("\n");
		}
	}
	switch_to(task[next_task]);
#endif
}

/* 切换当前任务current到下一个任务next */
void switch_to(struct task_struct* next) {
	// puts("In switch_to\n");
	if(current == next)
		return;
	else {
		// puts("In switch_to's else\n");
		struct task_struct *tmp = current;
		current = next;
		// puts("I'm here\n");
		switch_thread_struct(&(tmp->thread), &(next->thread));
		// puts("I'm also here\n");
	}
}

/* 死循环 */
void dead_loop(void) {
	while(1) {
		puts("In dead_loop\n");
	}
}