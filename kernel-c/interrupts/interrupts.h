#ifndef _INTERRUPTS_H
#define _INTERRUPTS_H

struct IDTR {
	uint16_t entry_number;
	uint32_t start_addr;
};
typedef struct IDTR IDTR;

#define IDT_ADDRESS 0x0
#define IDT_ENTRIES 256
#define IDTR_ADDRESS IDT_ADDRESS + IDT_ENTRIES * 8
#define IDTR_SIZE 6

#define IDT_ERR_ENTRIES 32
#define IRQ_NUMBER 16
#define MASTER_IRQ_VECTOR_OFFSET 0x20
#define SLAVE_IRQ_VECTOR_OFFSET 0x28

#define PIC1_COMMAND 0x20
#define PIC1_DATA 0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA 0xA1
#define ICW1_INIT 0x10
#define ICW1_ICW4 0x01
#define PIC_EOI 0x20
#define ICW4_8086 0x01

void install_interrupt_handler(uint32_t i, void (*ptr)());

#endif