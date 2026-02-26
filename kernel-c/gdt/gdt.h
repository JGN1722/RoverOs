#ifndef _GDT_H
#define _GDT_H

struct gdt_descriptor_t {
	uint16_t limit_low;
	uint16_t base_low;
	uint8_t base_mid;
	uint8_t flags1;
	uint8_t flags2;
	uint8_t base_high;
};
typedef struct gdt_descriptor_t gdt_descriptor_t;

struct gdtr_t {
	uint16_t size;
	uint32_t base;
};
typedef struct gdtr_t gdtr_t;

#define NULL_SEG 0x00
#define CODE_SEG 0x08
#define DATA_SEG 0x10

int setup_gdt();

#endif