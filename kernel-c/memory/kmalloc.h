/*
* Implementation of FYSOS's bucket allocator, minus a few features
* See: https://github.com/fysnet/FYSOS/blob/master/bucket/malloc.cpp
*/

#ifndef _KMALLOC_H
#define _KMALLOC_H

#define MALLOC_MAGIC_BUCKET 'BUCK'
#define MALLOC_MAGIC_PEBBLE 'ROCK'

#define PEBBLE_FLAG_FREE	(0 << 0)
#define PEBBLE_FLAG_IN_USE	(1 << 0)

#define PEBBLE_MIN_ALIGN 64
#define PEBBLE_MIN_SIZE 64

#define CAN_SPLIT_PEBBLE(s0, s1) ((s0) > (s1) + sizeof(struct mem_pebble_t) + PEBBLE_MIN_SIZE)
#define PEBBLE_IS_FREE(p) (((p)->lflags & PEBBLE_FLAG_IN_USE) == PEBBLE_FLAG_FREE)

struct mem_bucket_t {
	uint32_t magic;
	uint32_t lflags;
	size_t largest;
	size_t size;
	uint32_t spinlock; // Unused in this implementation
	uint8_t reserved1[12];
	struct mem_pebble_t *first;
	struct mem_bucket_t *prev;
	struct mem_bucket_t *next;
};

struct mem_pebble_t {
	uint32_t magic;
	uint32_t lflags;
	uint32_t reserved0;
	uint32_t alignement; // Unused in this implementation
	size_t size;
	uint8_t reserved1[16];
	struct mem_bucket_t *parent;
	struct mem_pebble_t *prev;
	struct mem_pebble_t *next;
};

int malloc_init(size_t size);
void *kmalloc(size_t size);
void *krealloc(void *ptr, size_t size);
void kfree(void *ptr);

#endif