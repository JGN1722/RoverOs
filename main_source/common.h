#ifndef _COMMON_H
#define _COMMON_H

// Useful constants
#define KERNEL_ADDRESS 0x100000
#define STACK_ADDRESS 0x7c00 - 1

// Some types
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define NULL  ((void *)0)
#define true  1
#define false 0

#endif