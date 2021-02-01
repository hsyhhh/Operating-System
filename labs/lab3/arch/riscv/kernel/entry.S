.section .text.entry

.global trap_s
.extern handler_s
.extern dead_loop
.extern testputs
.equ reg_size, 0x8
.align 3
trap_s:
	# context switch
	addi sp, sp, -32*reg_size
	# csrw sscratch, sp
	# save regs
	sd x1, 1*reg_size(sp)
	sd x2, 2*reg_size(sp)
	sd x3, 3*reg_size(sp)
	sd x4, 4*reg_size(sp)
	sd x5, 5*reg_size(sp)
	sd x6, 6*reg_size(sp)
	sd x7, 7*reg_size(sp)
	sd x8, 8*reg_size(sp)
	sd x9, 9*reg_size(sp)
	sd x10, 10*reg_size(sp)
	sd x11, 11*reg_size(sp)
	sd x12, 12*reg_size(sp)
	sd x13, 13*reg_size(sp)
	sd x14, 14*reg_size(sp)
	sd x15, 15*reg_size(sp)
	sd x16, 16*reg_size(sp)
	sd x17, 17*reg_size(sp)
	sd x18, 18*reg_size(sp)
	sd x19, 19*reg_size(sp)
	sd x20, 20*reg_size(sp)
	sd x21, 21*reg_size(sp)
	sd x22, 22*reg_size(sp)
	sd x23, 23*reg_size(sp)
	sd x24, 24*reg_size(sp)
	sd x25, 25*reg_size(sp)
	sd x26, 26*reg_size(sp)
	sd x27, 27*reg_size(sp)
	sd x28, 28*reg_size(sp)
	sd x29, 29*reg_size(sp)
	sd x30, 30*reg_size(sp)
	sd x31, 31*reg_size(sp)
	# save sepc
	csrr t0, sepc
	sd t0, 0*reg_size(sp)
	# call handler
	csrr a0, scause
	csrr a1, sepc
	call handler_s
	# restore sepc
	ld t0, 0*reg_size(sp)
	csrw sepc, t0
	# restore regs
	ld x1, 1*reg_size(sp)
	ld x2, 2*reg_size(sp)
	ld x3, 3*reg_size(sp)
	ld x4, 4*reg_size(sp)
	ld x5, 5*reg_size(sp)
	ld x6, 6*reg_size(sp)
	ld x7, 7*reg_size(sp)
	ld x8, 8*reg_size(sp)
	ld x9, 9*reg_size(sp)
	ld x10, 10*reg_size(sp)
	ld x11, 11*reg_size(sp)
	ld x12, 12*reg_size(sp)
	ld x13, 13*reg_size(sp)
	ld x14, 14*reg_size(sp)
	ld x15, 15*reg_size(sp)
	ld x16, 16*reg_size(sp)
	ld x17, 17*reg_size(sp)
	ld x18, 18*reg_size(sp)
	ld x19, 19*reg_size(sp)
	ld x20, 20*reg_size(sp)
	ld x21, 21*reg_size(sp)
	ld x22, 22*reg_size(sp)
	ld x23, 23*reg_size(sp)
	ld x24, 24*reg_size(sp)
	ld x25, 25*reg_size(sp)
	ld x26, 26*reg_size(sp)
	ld x27, 27*reg_size(sp)
	ld x28, 28*reg_size(sp)
	ld x29, 29*reg_size(sp)
	ld x30, 30*reg_size(sp)
	ld x31, 31*reg_size(sp)
	addi sp, sp, 32*reg_size
	sret

# extern void switch_thread_struct
# (struct thread_struct *current, struct thread_struct *next);
.global switch_thread_struct
switch_thread_struct:
	# store curent thread_struct
	sd ra, 0*reg_size(a0)
	sd sp, 1*reg_size(a0) # sp
	sd s0, 2*reg_size(a0)
	sd s1, 3*reg_size(a0)
	sd s2, 4*reg_size(a0)
	sd s3, 5*reg_size(a0)
	sd s4, 6*reg_size(a0)
	sd s5, 7*reg_size(a0)
	sd s6, 8*reg_size(a0)
	sd s7, 9*reg_size(a0)
	sd s8, 10*reg_size(a0)
	sd s9, 11*reg_size(a0)
	sd s10, 12*reg_size(a0)
	sd s11, 13*reg_size(a0)
	# load next thread_struct
	ld ra, 0*reg_size(a1)
	ld sp, 1*reg_size(a1)
	ld s0, 2*reg_size(a1)
	ld s1, 3*reg_size(a1)
	ld s2, 4*reg_size(a1)
	ld s3, 5*reg_size(a1)
	ld s4, 6*reg_size(a1)
	ld s5, 7*reg_size(a1)
	ld s6, 8*reg_size(a1)
	ld s7, 9*reg_size(a1)
	ld s8, 10*reg_size(a1)
	ld s9, 11*reg_size(a1)
	ld s10, 12*reg_size(a1)
	ld s11, 13*reg_size(a1)
	ret

.global task_init_ra
task_init_ra:
	# dead_loop -> sepc
	la t0, dead_loop
	csrw sepc, t0
	sret