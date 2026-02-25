/*
* Implementation of FYSOS's bucket allocator, minus a few features
* See: https://github.com/fysnet/FYSOS/blob/master/bucket/malloc.cpp
*/

#include "kmalloc.h"

struct mem_bucket_t *kernel_heap = NULL;

struct mem_bucket_t *create_bucket(size_t size) {
	struct mem_pebble_t *first;
	
	size = (size + PMM_BLOCK_SIZE - 1) & ~(PMM_BLOCK_SIZE - 1);
	struct mem_bucket_t *bucket = (struct mem_bucket_t *)(mmap(size / PMM_BLOCK_SIZE));
	
	if (bucket != NULL) {
		bucket->magic = MALLOC_MAGIC_BUCKET;
		bucket->lflags = 0;
		bucket->size = size / PMM_BLOCK_SIZE;
		bucket->largest = size - sizeof(struct mem_bucket_t) - sizeof(struct mem_pebble_t);
		bucket->prev = NULL;
		bucket->next = NULL;
		
		first = (struct mem_pebble_t *)((uint8_t *)bucket + sizeof(struct mem_bucket_t));
		bucket->first = first;
		
		first->magic = MALLOC_MAGIC_PEBBLE;
		first->lflags = PEBBLE_FLAG_FREE;
		first->size = bucket->largest;
		first->parent = bucket;
		first->prev = NULL;
		first->next = NULL;
	}
	
	return bucket;
}

void insert_bucket(struct mem_bucket_t *bucket, void *destination) {
	struct mem_bucket_t *dest = (struct mem_bucket_t *)destination;
	
	if (bucket && dest) {
		bucket->next = dest->next;
		dest->next = bucket;
		bucket->prev = dest;
		if (bucket->next) bucket->next->prev = bucket;
	}
}

void remove_bucket(struct mem_bucket_t *bucket) {
	if (bucket && (bucket != kernel_heap)) {
		if (bucket->prev) {
			bucket->prev->next = bucket->prev;
		}
		if (bucket->next) {
			bucket->next->prev = bucket->prev;
		}
		mmap_free(bucket, bucket->size);
	}
}

size_t bucket_update_largest(struct mem_bucket_t *bucket) {
	struct mem_pebble_t *p = bucket->first;
	size_t ret = 0;
	
	while (p != NULL) {
		if (p->size > ret) ret = p->size;
		p = p->next;
	}
	
	bucket->largest = ret;
	return ret;
}

void memcpy(void *dest, void *src, uint32_t size) {
	uint8_t *d = (uint8_t *)dest, *s = (uint8_t *)src;
	for (int i = 0; i < size; i++) *(d++) = *(s++);
}

struct mem_pebble_t *split_pebble(struct mem_pebble_t *this_pebble, struct mem_pebble_t *src) {
	struct mem_pebble_t *new_pebble;
	size_t new_size;
	
	if (CAN_SPLIT_PEBBLE(this_pebble->size, src->size)) {
		new_size = (src->size + (PEBBLE_MIN_ALIGN - 1)) & ~(PEBBLE_MIN_ALIGN - 1);
		new_pebble = (struct mem_pebble_t *)((uint8_t *)this_pebble + new_size + sizeof(struct mem_pebble_t));
		memcpy(new_pebble, this_pebble, sizeof(struct mem_pebble_t));
		new_pebble->size = this_pebble->size - new_size - sizeof(struct mem_pebble_t);
		new_pebble->prev = this_pebble;
		if (this_pebble->next) {
			this_pebble->next->prev = new_pebble;
		}
		this_pebble->size = new_size;
		this_pebble->next = new_pebble;
	}
	return this_pebble;
}

struct mem_pebble_t *place_pebble(struct mem_bucket_t *bucket, struct mem_pebble_t *pebble) {
	struct mem_pebble_t *start = bucket->first, *best = NULL, *ret = NULL;
	size_t best_size = -1;
	
	// Always use best fit method
	while (start != NULL) {
		if (PEBBLE_IS_FREE(start) && (start->size >= pebble->size)) {
			if (start->size < best_size) {
				best = start;
				best_size = start->size;
			}
		}
		start = start->next;
	}
	if (best != NULL) {
		best = split_pebble(best, pebble);
		best->lflags = pebble->lflags;
		ret = best;
	}
	return ret;
}

struct mem_pebble_t *absorb_next(struct mem_pebble_t *pebble) {
	if (pebble && pebble->next && PEBBLE_IS_FREE(pebble) && PEBBLE_IS_FREE(pebble->next)) {
		if (pebble->parent->first == pebble->next) {
			pebble->parent->first = pebble;
		}
		pebble->size += pebble->next->size + sizeof(struct mem_pebble_t);
		pebble->next = pebble->next->next;
		if (pebble->next) pebble->next->prev = pebble;
		bucket_update_largest(pebble->parent);
	}
	return pebble;
}

struct mem_pebble_t *melt_prev(struct mem_pebble_t *pebble) {
	if (pebble && pebble->next && PEBBLE_IS_FREE(pebble) && PEBBLE_IS_FREE(pebble->next)) {
		if (pebble->parent->first = pebble) {
			pebble->parent->first = pebble->prev;
		}
		pebble->prev->size += pebble->size + sizeof(struct mem_pebble_t);
		pebble->prev->next = pebble->next;
		if (pebble->next) {
			pebble->next->prev = pebble->prev;
		}
		pebble = pebble->prev;
		bucket_update_largest(pebble->parent);
	}
	return pebble;
}

void *kmalloc(size_t size) {
	void *ret = NULL;
	
	if (size < PEBBLE_MIN_SIZE) size = PEBBLE_MIN_SIZE;
	
	struct mem_pebble_t pebble;
	pebble.magic = MALLOC_MAGIC_PEBBLE;
	pebble.lflags = PEBBLE_FLAG_IN_USE;
	pebble.size = (size + PEBBLE_MIN_ALIGN - 1) & ~(PEBBLE_MIN_ALIGN - 1);
	
	struct mem_bucket_t *bucket = (struct mem_bucket_t *)kernel_heap;
	
	for (; bucket != NULL; bucket = bucket->next) {
		if (bucket->largest >= pebble.size) {
			pebble.parent = bucket;
			ret = place_pebble(bucket, &pebble);
			if (ret) {
				bucket_update_largest(bucket);
				ret = (uint8_t *)ret + sizeof(struct mem_pebble_t);
				break;
			}
		}
	}
	
	if (ret == NULL) {
		size_t new_size = size + (sizeof(struct mem_bucket_t) + sizeof(struct mem_pebble_t));
		bucket = create_bucket(new_size);
		if (bucket) {
			insert_bucket(bucket, kernel_heap);
			pebble.parent = bucket;
			ret = place_pebble(bucket, &pebble);
			bucket_update_largest(bucket);
			if (ret != NULL) {
				ret = (uint8_t *)ret + sizeof(struct mem_pebble_t);
			}
		}
	}
	
	return ret;
}

void kfree(void *ptr) {
	if (ptr == NULL) return;
	
	struct mem_pebble_t *pebble = (struct mem_pebble_t *)((uint8_t *)ptr - sizeof(struct mem_pebble_t));
	
	if (pebble->magic != MALLOC_MAGIC_PEBBLE) return;
	
	pebble->lflags = PEBBLE_FLAG_FREE;
	pebble = melt_prev(pebble);
	absorb_next(pebble);
	
	struct mem_bucket_t *bucket = pebble->parent;
	if (PEBBLE_IS_FREE(bucket->first) && (bucket->first->prev == NULL) && (bucket->first->next == NULL)) {
		remove_bucket(bucket);
	} else {
		bucket_update_largest(bucket);
	}
}

void *krealloc(void *ptr, size_t size) {
	struct mem_pebble_t *pebble;
	void *ret = NULL;
	
	if (size == 0) {
		kfree(ptr);
		return NULL;
	}
	
	if (ptr == NULL) return kmalloc(size);
	
	pebble = (struct mem_pebble_t *)((uint8_t *)ptr - sizeof(struct mem_pebble_t));
	if (pebble->magic != MALLOC_MAGIC_PEBBLE) return NULL;
	
	if (size <= pebble->size) {
		ret = pebble;
	} else {
		ret = kmalloc(size);
		if (ret) {
			memcpy(ret, ptr, size);
		}
		kfree(ptr);
	}
	
	return ret;
}

void malloc_init(size_t size) {
	kernel_heap = create_bucket(size);
}

void setup_memory() {
	setup_pmemory();
	setup_vmemory();
	malloc_init(PMM_BLOCK_SIZE);
}
