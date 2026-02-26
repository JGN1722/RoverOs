#ifndef _VMM_H
#define _VMM_H

// The high 10 bits of a virtual address are for the page table index
// in the page directory. The next ten are for the index in the entry
// in the page table.
// The address of a page table stored in the page directory are the high
// 20 bits.
#define PG_TBL_MASK	0xffc00000
#define PG_ENTRY_MASK	0x003ff000
#define PG_ADDR_MASK	0xfffff000
#define PG_FLAG_MASK	0x00000fff
#define PG_OFFSET_MASK	0x00000fff

#define PG_PRESENT	0b000000000001
#define PG_WRITE	0b000000000010
#define PG_USER		0b000000000100
#define PG_WRITETHROUGH	0b000000001000
#define PG_NOCACHE	0b000000010000
#define PG_ACCESSED	0b000000100000
#define PG_DIRTY	0b000001000000
#define PG_GLOBAL	0b000010000000
#define PG_PAT		0b000100000000

#define VADDR_MAPPED(p, i) (p[(i)] & PG_ADDR_MASK != 0)

// The three other flags are undefined

void load_page_dir(uint32_t *page_directory);
void invalidate_TLB();
uint32_t *get_page_table_vaddr(uint32_t i);
uint32_t *get_page_table_paddr(uint32_t i);
int map_virtual_to_physical(void *vaddr, void *paddr);
void unmap_vaddr(void *vaddr);
void set_page_flags(void *vaddr, uint32_t flags);
void clear_page_flags(void *vaddr, uint32_t flags);
uint32_t get_page_flags(void *vaddr);
void *translate_vaddr(void *vaddr);
void *mmap(size_t size);
void mmap_free(void *ptr, size_t size);
int setup_vmemory();

#endif