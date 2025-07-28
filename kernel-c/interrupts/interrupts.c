#include "interrupts.h"

#include "exceptions.c"
#include "irqs.c"

void build_idt() {
	// Build IDT
	for (uint8_t *ptr = IDT_ADDRESS; ptr < IDT_ENTRIES; ptr++) {
		*ptr = 0;
	}
	
	// Build IDTR
	IDTR *idtr = IDTR_ADDRESS;
	idtr->entry_number = (IDT_ENTRIES * 8) - 1;
	idtr->start_addr = IDT_ADDRESS;
	
	IDTR_ADDRESS;
	asm("lidt [eax]");
}

void install_interrupt_handler(uint32_t i, void (*fptr)()) {
	uint16_t *ptr = (i << 3) + IDT_ADDRESS;
	
	*ptr = (uint16_t)fptr; // lower 16 bits
	*((uint16_t *)(ptr += 2)) = 0x08;
	*((uint16_t *)(ptr += 2)) = 0x8E00; // Set up the interrupt gate descriptor (0x8E00 means present, privilege level 0, interrupt gate)
	*((uint16_t *)(ptr += 2)) = fptr >> 16; // upper 16 bits
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