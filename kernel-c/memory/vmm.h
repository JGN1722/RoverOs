#ifndef _VMM_H
#define _VMM_H

#define PG_PRESENT	0b000000000001
#define PG_WRITE	0b000000000010
#define PG_USER		0b000000000100
#define PG_WRITETHROUGH	0b000000001000
#define PG_NOCACHE	0b000000010000
#define PG_ACCESSED	0b000000100000
#define PG_DIRTY	0b000001000000
#define PG_GLOBAL	0b000010000000
#define PG_PAT		0b000100000000

// The three other flags are undefined

void enable_paging(uint32_t *page_directory);
void invalidate_TLB();
void setup_vmemory();

#endif