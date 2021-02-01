# .section .bss
# .lcomm buffer, 10000
.equ framesize, 400
.equ mtime, 0x200bff8
.equ mtimecmp, 0x2004000

.section .text.init
.global _start
_start:
	# initialize memory of bss section
	la t0, __bss_start
	la t1, __bss_end
	ble t0, t1, not_clean
clean_loop:
	sd zero, 0(t0) # store doubleword
	addi t0, t0, 8
	blt t0, t1, clean_loop

not_clean:
	# initialize mtimecmp -> mtime+1000000
	li t0, mtime # t0 -> mtime
	li t1, mtimecmp # t1 -> mtimecmp
	ld t2, 0(t0)
	li t3, 1000000
	add t3, t2, t3
	sd t3, 0(t1)

	# set timer interrupt delegation
	# Supervisor timer interrupt: 5 -> mideleg[5] = 1
	li t0, 0x20
	csrs mideleg, t0
	
	# enable bits
	# mstatus[mie(3)] = 1, mie[7] = 1
	# sstatus[sie(1)] = 1, sie[5] = 1
	li t0, 0x8
	csrs mstatus, t0
	# li t0, 0x2
	# csrs mstatus, t0
	li t0, 0x2
	csrs sstatus, t0
	li t0, 0x80
	csrs mie, t0
	# li t0, 0x20
	# csrs mie, t0
	li t0, 0x20
	csrs sie, t0

	# 设置machine mode异常处理地址
	la t0, trap_m
	csrw mtvec, t0

	# 使cpu从machine mode切换到supervisor mode
	# 设置MPP为01，对应supervisor mode
	li t0, 0x800
	csrs mstatus, t0 # csrs为|=
	li t0, 0x1000
	csrc mstatus, t0
	# 将_mret_addr放入mepc寄存器
	la t0, _mret_addr
	csrw mepc, t0 #csrw为全赋值
	mret

_mret_addr:
	# 设置supervisor mode异常处理地址
	la t0, trap_s
	csrw stvec, t0

	# 设置c语言调用栈环境
	la sp, stack_top

	# 跳转到main.c中给出的start_kernel函数
	j start_kernel

.global trap_m
trap_m:
	# context switch
	addi sp, sp, -framesize
	# save regs
	sd ra, (framesize-8)(sp)
	sd t0, framesize-16(sp)
	sd t1, framesize-24(sp)
	sd t2, framesize-32(sp)
	sd s0, framesize-40(sp)
	sd s1, framesize-48(sp)
	sd a0, framesize-56(sp)
	sd a1, framesize-64(sp)
	sd a2, framesize-72(sp)
	sd a3, framesize-80(sp)
	sd a4, framesize-88(sp)
	sd a5, framesize-96(sp)
	sd a6, framesize-104(sp)
	sd a7, framesize-112(sp)
	sd s2, framesize-120(sp)
	sd s3, framesize-128(sp)
	sd s4, framesize-136(sp)
	sd s5, framesize-144(sp)
	sd s6, framesize-152(sp)
	sd s7, framesize-160(sp)
	sd s8, framesize-168(sp)
	sd s9, framesize-176(sp)
	sd s10, framesize-184(sp)
	sd s11, framesize-192(sp)
	sd t3, framesize-200(sp)
	sd t4, framesize-208(sp)
	sd t5, framesize-216(sp)
	sd t6, framesize-224(sp)

	# jal ra, mtrap_print
	# decode trap cause
	# mcause < 0 means trap is interrupt
	csrr t0, mcause # read mcause
	bgez t0, m_exception # >= 0, trap is exception
	andi t0, t0, 0x3f # isolate interrupt cause
	li t1, 7 # t1 = machine timer interrupt cause
	bne t0, t1, m_otherInt # branch if not a timer interrupt

	# handle machine timer interrupt
	# disable machine timer interrupt
	# 
	# jal ra, mtrap_print
	li t0, 0x80 # mie[7] = 0, disable mie[mtie]
	csrc mie, t0
	# enable sip[stip], sip[5] = 1
	li t0, 0x20
	csrs sip, t0
	csrs mip, t0
	j m_handle_done

m_otherInt:
	j m_handle_done

m_exception:
	# mepc = mepc + 4
	csrr t0, mepc
	addi t0, t0, 4
	csrw mepc, t0
	andi t0, t0, 0x3f # isolate exception cause
	li t1, 9 # t1 = ecall from S-mode
	bne t0, t1, m_otherExcp

	# handle ecall from S-mode
	# set mtimecmp += 100000
	li t0, mtime # t0 -> mtime
	li t1, mtimecmp # t1 -> mtimecmp
	ld t2, 0(t0)
	li t3, 100000
	add t3, t2, t3
	sd t3, 0(t1)
	# enable mie[mtie], mie[7] = 1
	li t0, 0x80
	csrs mie, t0

	j m_handle_done

m_otherExcp:
	j m_handle_done

m_handle_done:
	# restore regs
	ld ra, framesize-8(sp)
	ld t0, framesize-16(sp)
	ld t1, framesize-24(sp)
	ld t2, framesize-32(sp)
	ld s0, framesize-40(sp)
	ld s1, framesize-48(sp)
	ld a0, framesize-56(sp)
	ld a1, framesize-64(sp)
	ld a2, framesize-72(sp)
	ld a3, framesize-80(sp)
	ld a4, framesize-88(sp)
	ld a5, framesize-96(sp)
	ld a6, framesize-104(sp)
	ld a7, framesize-112(sp)
	ld s2, framesize-120(sp)
	ld s3, framesize-128(sp)
	ld s4, framesize-136(sp)
	ld s5, framesize-144(sp)
	ld s6, framesize-152(sp)
	ld s7, framesize-160(sp)
	ld s8, framesize-168(sp)
	ld s9, framesize-176(sp)
	ld s10, framesize-184(sp)
	ld s11, framesize-192(sp)
	ld t3, framesize-200(sp)
	ld t4, framesize-208(sp)
	ld t5, framesize-216(sp)
	ld t6, framesize-224(sp)
	addi sp, sp, framesize
	# return
	mret

# .bss
# .align 4
# .zero 1024
