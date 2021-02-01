#ifndef VM_H
#define VM_H
#define uint64 unsigned long long
#define PAGE_TABLE_START 0x80010000

uint64 read_piece(uint64 n, int left, int right);
uint64 write_piece(uint64 n, uint64 content, int left, int right);
uint64 read_mem(uint64 *p);
void write_mem(uint64 *p, uint64 val);
uint64 alloc_phys_frame(void);
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, int perm);
void create_page_mapping(uint64 *pgtbl, uint64 va, uint64 pa, int perm);
void paging_init(void);

#endif
