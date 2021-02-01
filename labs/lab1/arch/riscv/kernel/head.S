.global _start
_start:
	# 关闭machine mode中断
	li t0, 0x8 # MIE置0
	csrc mstatus, t0

	# 设置machine mode异常处理地址
	la t0, _mexcep_vet
	# slli t0, t0, 2
	csrw mtvec, t0
	
	# 使cpu从machine mode切换到supervisor mode
	# 设置MPP为01，对应supervisor mode
	li t0, 0x800
	csrs mstatus, t0 #csrs为|=
	# 将_mret_addr放入mepc寄存器
	la t0, _mret_addr
	csrw mepc, t0 #csrw为全赋值
	mret
_mret_addr:
	# 设置supervisor mode异常处理地址
	la t0, _sexcep_vet
	# slli t0, t0, 2
	csrw stvec, t0

	# 设置c语言调用栈环境
	la sp, stack_top

	# 跳转到main.c中给出的start_kernel函数
	j start_kernel

.global _mexcep_vet
_mexcep_vet:

.global _sexcep_vet
_sexcep_vet:



