.section .text.init

.equ reg_size, 0x8
.equ mtime, 0x200bff8
.equ mtimecmp, 0x2004000
.align 3

.extern paging_init
.extern testputs
.extern putlonglong
.extern init_stack_top
.extern perm_test

.global _start
_start:
	# disable global interrupt -> mstatus[3] mstatus.mie = 0
	li t0, 0x8
	csrc mstatus, t0
	# set satp = 0, close MMU
	csrw satp, zero
	# set m mode trap handler -> mtvec = trap_m
	la t0, trap_m
	csrw mtvec, t0
	# to change mode with mret instruction
	# need to set -> mepc = s_mode
	la t0, s_mode
	csrw mepc, t0
	# mstatus.mpie = 0 (mstatus[7])
	li t0, 0x80
	csrc mstatus, t0
	# mstatus.mpp = 01 for s mode (mstatus[12:11])
	csrr t0, mstatus
	addi t1, zero, 0x1
	slli t1, t1, 11
	or t0, t0, t1 # set [11] = 1
	slli t1, t1, 1
	not t1, t1
	and t0, t0, t1 # set [12] = 0
	csrw mstatus, t0

	# initialize bss section
	la t0, bss_start
	la t1, bss_end
init_bss:
	bge t0, t1, init_bss_done
	sd zero, 0(t0)
	addi t0, t0, 8
	j init_bss

init_bss_done:
	# initialize mtimecmp -> mtime+1000000
	li t0, mtime # t0 -> mtime
	li t1, mtimecmp # t1 -> mtimecmp
	ld t2, 0(t0)
	li t3, 1000000
	add t3, t2, t3
	sd t3, 0(t1)

	# set mscratch = stack_top
	la t0, stack_top
	csrw mscratch, t0
	
	# set timer interrupt delegation
	# Supervisor timer interrupt: 5 -> mideleg[5] = 1
	li t0, 0x20
	csrs mideleg, t0

	# set instruction/load/store page fault delegation
	# instruction/load/store: 12/13/15
	li t0, 0xb000
	csrs medeleg, t0
	
	# sstatus.sie = 1 sie.stie = 1
	# sstatus[sie(1)] = 1, sie[5] = 1
	li t0, 0x2
	csrs sstatus, t0
	li t0, 0x20
	csrs sie, t0
	# mstatus[mie(3)] = 1, mie[7] = 1
	li t0, 0x8
	csrs mstatus, t0
	li t0, 0x80
	csrs mie, t0
	mret

s_mode:
	# 设置c语言调用栈环境
	la sp, stack_top

	# call paging_init()
	call paging_init

	# jal testputs ###

	# set satp, open MMU
	# MODE[63:60] = 8, ASID = 0, PPN[43:0] = 0x80010000 >> 12
	li t0, 0x80010
	li t1, 0x1
	sll t1, t1, 63
	or t0, t0, t1
	csrw satp, t0

	sfence.vma

	# jal testputs ###

	# jump to high address
	la t0, after_virtual
	andi t1, t0, 0x1ff # 取低9位
	li t2, 0xffffffe000000000
	# slli t2, 36
	or t1, t1, t2
	add ra, t1, zero
	jr ra

after_virtual:
	# jal testputs ###

	# 设置stvec为trap_s在虚拟地址空间下的地址
	la t0, trap_s
	csrw stvec, t0

	# 设置sp的值为虚拟地址空间下的init_stack_top
	la sp, init_stack_top

	# call perm_test ###

	# 跳转到main.c中给出的start_kernel函数
	call start_kernel

.global trap_m
trap_m:
	# exchange mscratch, sp
	csrrw sp, mscratch, sp
	# context switch
	addi sp, sp, -32*reg_size
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
handler_m:
	csrr t0, mcause
	addi t1, zero, 1
	slli t1, t1, 63
	and t1, t1, t0
	slli t0, t0, 1
	srli t0, t0, 1 # t0 store unsigned cause
	beqz t1, exception_m # mcause < 0 means interrupt
interrupt_m:
	li t1, 7
	bne t1, t0, handler_m_done
	# machine timer interrupt
	# unset mie[mtie] and set sip[stip]
	# mie[7] = 0
	li t0, 0x80
	csrc mie, t0
	# sip[5] = 1
	li t0, 0x20
	csrs mip, t0
	j handler_m_done
exception_m:
	li t1, 9
	bne t1, t0, handler_m_done
	# ecall from S-mode
	# set mtimecmp += 1000
	li t0, mtime # t0 -> mtime
	li t1, mtimecmp # t1 -> mtimecmp
	ld t2, 0(t0)
	li t3, 1000
	add t3, t2, t3
	sd t3, 0(t1)
	# enable mie[mtie], mie[7] = 1
	li t0, 0x80
	csrs mie, t0
	# unset mip[5]
	li t0, 0x20
	csrc mip, t0
	# set mepc += 4
	csrr t0, mepc
	addi t0, t0, 4
	csrw mepc, t0

handler_m_done:
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
	# exchange mscratch, sp
	csrrw sp, mscratch, sp
	mret
