#include "interrupts.h"

#include "exceptions.c"
#include "irqs.c"

[[align(16)]] idt_entry_t idt[IDT_ENTRIES];
idtr_t idtr;

void build_idt() {
	idtr.limit = (IDT_ENTRIES << 3) - 1;
	idtr.base = (uint32_t)&idt;
	
	&idtr;
	asm("lidt [eax]");
}

void install_interrupt_handler(uint32_t i, void (*fptr)()) {
	idt_entry_t *ptr = &(idt[i]);
	
	ptr->isr_low = fptr & 0xffff; // lower 16 bits
	ptr->kernel_cs = 0x08;
	ptr->attributes = 0x8E;
	ptr->isr_high = fptr >> 16; // upper 16 bits
	ptr->reserved = 0;
}

void PIC_remap(uint32_t offset1, uint32_t offset2) {
	uint8_t mask1, mask2;
	
	// Save masks
	mask1 = inb(PIC1_DATA);
	mask2 = inb(PIC2_DATA);
	
	// Start cascade initialisation
	outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
	outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
	
	// Set PICs vector offset
	outb(PIC1_DATA, offset1);
	outb(PIC2_DATA, offset2);
	
	// Tell master PIC that there is a slave at IRQ2 (0000 0100)
	outb(PIC1_DATA, 4);
	// Tell slave PIC its identity (0000 0010)
	outb(PIC2_DATA, 2);
	
	// Have the PICs use 8086 mode instead of 8080
	outb(PIC1_DATA, ICW4_8086);
	outb(PIC2_DATA, ICW4_8086);
	
	// Restore the masks
	outb(PIC1_DATA, mask1);
	outb(PIC2_DATA, mask2);
}

void PIC_mask(uint8_t mask1, uint8_t mask2) {
	outb(PIC1_DATA, mask1);
	outb(PIC2_DATA, mask2);
}

[[roverc::interrupt]] void generic_interrupt_handler() {
	printf("Unhandled interrupt received\r\n");
}

void install_generic_interrupt_handler() {
	for (int i = 0; i < IDT_ENTRIES; i++) {
		install_interrupt_handler(i, generic_interrupt_handler);
	}
}

void setup_interrupts() {
	build_idt();
	install_generic_interrupt_handler();
	install_exception_interrupts();
	install_irq_interrupts();
	PIC_remap(MASTER_IRQ_VECTOR_OFFSET, SLAVE_IRQ_VECTOR_OFFSET);
}