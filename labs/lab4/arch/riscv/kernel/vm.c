#include "vm.h"
#include "put.h"
extern unsigned long long get__end(void);
extern unsigned long long get_text_start(void);
extern unsigned long long get_text_end(void);
extern unsigned long long get_rodata_start(void);
extern unsigned long long get_rodata_end(void);
extern unsigned long long get_data_start(void);
extern void testputs(void);


uint64 read_piece(uint64 n, int left, int right) {
	uint64 res;
	res = (n << (63 - left)) >> (63 + right - left);
	return res;
}

uint64 write_piece(uint64 n, uint64 content, int left, int right) {
	int i;
	// clear
	for (i = right; i <= left; i++) {
		n &= ~(1 << i);
	}
	// set
	n |= content << right;
	return n;
}

uint64 alloc_phys_frame(void) {
	static uint64 phys_addr = PAGE_TABLE_START;
	// putlonglong(phys_addr);
	// static uint64 phys_addr = get__end();
	uint64 phys_addr_pre = phys_addr;
	phys_addr += 0x1000;
	return phys_addr_pre;
}

uint64 read_mem(uint64 *p) {
	return (uint64)(*p);
}

void write_mem(uint64 *p, uint64 val) {
	*p = val;
	return;
}

/**
 * pgtbl: 根页表的基地址
 * va, pa: 需要映射的虚拟,物理地址的基地址
 * sz: 映射的大小
 * perm: 映射的读写权限 xwr
 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, int perm) {
	int i, page_num;
	if(sz % 0x1000 == 0) 
		page_num = sz / 0x1000;
	else
		page_num = sz / 0x1000 + 1;
	puts("In creating_mapping, page_num: ");
	puti(page_num);
	puts("\n");
	for (i = 0; i < page_num; i++) {
		// puts("page_num: "); puti(i); puts("\n");
		create_page_mapping(pgtbl, va + i * 0x1000, pa + i * 0x1000, perm);
	}
	return;
}

void create_page_mapping(uint64 *pgtbl, uint64 va, uint64 pa, int perm) {
	uint64 vpn2, vpn1, vpn0, ppn2, ppn1, ppn0;
	vpn2 = read_piece(va, 38, 30);
	vpn1 = read_piece(va, 29, 21);
	vpn0 = read_piece(va, 20, 12);
	ppn2 = read_piece(pa, 55, 30);
	ppn1 = read_piece(pa, 29, 21);
	ppn0 = read_piece(pa, 20, 12);
	// puts("pgtbl: ");
	// putlonglong((uint64)pgtbl);
	// puts("\n");
	// puts("va: ");
	// putlonglong(va);
	// puts("\n");
	// puts("pa: ");
	// putlonglong(pa);
	// puts("\n");
	// puts("vpn2 << 3: ");
	// putlonglong(vpn2 << 3);
	// puts("\n");
	// puts("vpn1 << 3: ");
	// putlonglong(vpn1 << 3);
	// puts("\n");
	// puts("vpn0 << 3: ");
	// putlonglong(vpn0 << 3);
	// puts("\n");
	uint64 first_page_addr = (uint64)pgtbl + (vpn2 << 3);
	uint64 first_page_entry;
	first_page_entry = read_mem((uint64*)first_page_addr);
	if(!(first_page_entry & 0x1)) {
		first_page_entry = write_piece(first_page_entry, alloc_phys_frame() >> 12, 53, 10);
		first_page_entry = write_piece(first_page_entry, 0x1, 0, 0);
	}
	// puts("first_page_table: ");
	// putlonglong((uint64)pgtbl);
	// puts(", first_page_addr: ");
	// putlonglong(first_page_addr);
	// puts(", first_page_entry: ");
	// putlonglong(first_page_entry);
	// puts("\n");
	write_mem((uint64*)first_page_addr, first_page_entry);


	uint64 second_page_addr = (read_piece(read_mem((uint64*)first_page_addr), 53, 10) << 12) + (vpn1 << 3);
	uint64 second_page_entry;
	second_page_entry = read_mem((uint64*)second_page_addr);
	if(!(second_page_entry & 0x1)) {
		second_page_entry = write_piece(second_page_entry, alloc_phys_frame() >> 12, 53, 10);
		second_page_entry = write_piece(second_page_entry, 0x1, 0, 0);
	}
	// puts("second_page_table: ");
	// putlonglong(read_piece(first_page_entry, 53, 10) << 12);
	// puts(", second_page_addr: ");
	// putlonglong(second_page_addr);
	// puts(", second_page_entry: ");
	// putlonglong(second_page_entry);
	// puts("\n");
	write_mem((uint64*)second_page_addr, second_page_entry);
	
	uint64 third_page_addr = (read_piece(read_mem((uint64*)second_page_addr), 53, 10) << 12) + (vpn0 << 3);
	uint64 third_page_entry = 0x0;
	third_page_entry = write_piece(third_page_entry, pa >> 12, 53, 10);
	uint64 perm_with_valid = (perm << 1) | 0b1;
	third_page_entry = write_piece(third_page_entry, perm_with_valid, 3, 0);
	// puts("third_page_table: ");
	// putlonglong(read_piece(second_page_entry, 53, 10) << 12);
	// puts(", third_page_addr: ");
	// putlonglong(third_page_addr);
	// puts(", third_page_entry: ");
	// putlonglong(third_page_entry);
	// puts("\n");
	write_mem((uint64*)third_page_addr, third_page_entry);
	// puts("ppn: ");
	// putlonglong(read_piece(read_mem((uint64*)third_page_addr), 53, 10) << 12);
	// puts("\n");
	// puts("------\n");
	
	return;
}

void paging_init(void) {
	puts("here in paging_init\n");
	uint64 root_pgt_addr = alloc_phys_frame();
	// xwr
	uint64 text_start, text_end;
	uint64 rodata_start, rodata_end;
	uint64 data_start;
	text_start = get_text_start();
	text_end = get_text_end();
	rodata_start = get_rodata_start();
	rodata_end = get_rodata_end();
	data_start = get_data_start();
	puts("text_start: "); putlonglong(text_start);
	puts(", text_end: "); putlonglong(text_end); puts("\n");
	puts("rodata_start: "); putlonglong(rodata_start);
	puts(", rodata_end: "); putlonglong(rodata_end); puts("\n");
	puts("data_start: "); putlonglong(data_start); puts("\n");

	create_mapping((uint64*)root_pgt_addr, 0x80000000, 0x80000000, 0x1000000, 0b111);
	
	// create_mapping((uint64*)_end_addr, 0xffffffe000000000, 0x80000000, 0x1000000, 0b111);
	create_mapping((uint64*)root_pgt_addr, 0xffffffe000000000, 0x80000000, rodata_start - text_start, 0b101);
	create_mapping((uint64*)root_pgt_addr, 0xffffffe000000000 + rodata_start - text_start, 0x80000000 + rodata_start - text_start, data_start - rodata_start, 0b001);
	create_mapping((uint64*)root_pgt_addr, 0xffffffe000000000 + data_start - text_start, 0x80000000 + data_start - text_start, 0x1000000 - data_start + text_start, 0b011);
	
	create_mapping((uint64*)root_pgt_addr, 0x10000000, 0x10000000, 0x1000, 0b111);
	return;
}

void perm_test(void) {
	uint64 read_val = 0x0;
	uint64 write_val = 0xabcdef1234567890;
	uint64 *text_addr = (uint64*)0xffffffe000001100;
	uint64 *rodata_addr = (uint64*)0xffffffe000002100;
	uint64 *other_addr = (uint64*)0xffffffe000003100;
	// test text section protection: r-x
	// puts("before read_mem: ");
	// putlonglong(read_val);
	// read_val = read_mem(text_addr);
	// puts(", after read_mem: ");
	// putlonglong(read_val); puts("\n");
	// puts("r is permitted!\n");
	// puts("\'testputs\' is in text section: ");
	// putlonglong((uint64)testputs);
	// puts("\n");
	// asm volatile("la t0, testputs");
	// asm volatile("jalr t0");
	// puts("x is permitted!\n");
	// write_mem(text_addr, write_val);
	
	// test rodata section protection: r--
	// puts("before read_mem: ");
	// putlonglong(read_val);
	// read_val = read_mem(rodata_addr);
	// puts(", after read_mem: ");
	// putlonglong(read_val); puts("\n");
	// puts("r is permitted!\n");
	// // asm volatile("li t0, 0xffffffe000002100");
	// // asm volatile("jalr t0");
	// // puts("x is permitted!\n");
	// write_mem(text_addr, write_val);
	
	// test other section protection: rw-
	puts("before read_mem: ");
	putlonglong(read_val);
	read_val = read_mem(other_addr);
	puts(", after read_mem: ");
	putlonglong(read_val); puts("\n");
	puts("r is permitted!\n");
	puts("before write_mem: ");
	putlonglong(read_val);
	write_mem(other_addr, write_val);
	read_val = read_mem(other_addr);
	puts(", after write_mem: ");
	putlonglong(read_val);
	puts("\nx is permitted!\n");
	asm volatile("li t0, 0xffffffe000003100");
	asm volatile("jalr t0");
	puts("x is permitted!\n");
}