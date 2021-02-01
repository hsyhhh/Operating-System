.equ framesize, 400
.equ mtime, 0x200bff8
.equ mtimecmp, 0x2004000

.section .text.entry
.global trap_s
trap_s:
	# context switch
	addi sp, sp, -framesize
	# save regs
	sd ra, framesize-8(sp)
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

	# decode trap cause
	# mcause < 0 means trap is interrupt
	csrr t0, scause # read scause
	bgez t0, s_exception # >= 0, trap is exception
	# trap is interrupt
	# handle timer interrupt
	jal ra, strap_print
	# sip[stip] = 0, sip[5] = 0
	li t0, 0x20
	csrc sip, t0
	# ecall to produce a trap
	ecall
	j s_handle_done
	
s_exception:
	j s_handle_done

s_handle_done:
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
	sret



