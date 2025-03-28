#ifndef _CONSTANTS_H
#define _CONSTANTS_H

#define KERNEL_ADDRESS 0x7c00 + 512 + 512
#define STACK_ADDRESS 0x7c00 - 1
#define IDT_ADDRESS 0x0
#define IDT_ENTRIES 256
#define IDTR_ADDRESS IDT_ADDRESS + IDT_ENTRIES * 8
#define IDTR_SIZE 6
#define MEM_MAP_ADDRESS IDTR_ADDRESS + IDTR_SIZE
#define MEM_MAP_ENTRIES_START MEM_MAP_ADDRESS + 4

#define IDT_ERR_ENTRIES 32
#define IRQ_NUMBER 16
#define MASTER_IRQ_VECTOR_OFFSET 0x20
#define SLAVE_IRQ_VECTOR_OFFSET 0x28

#define VIDEO_MEMORY 0xB8000
#define WHITE_ON_BLACK 0x0f
#define MAX_ROWS 25
#define MAX_COLS 80
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

#define PIC1_COMMAND 0x20
#define PIC1_DATA 0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA 0xA1
#define ICW1_INIT 0x10
#define ICW1_ICW4 0x01
#define PIC_EOI 0x20
#define ICW4_8086 0x01

#endif