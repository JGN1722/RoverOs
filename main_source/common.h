#ifndef _COMMON_H
#define _COMMON_H

// Useful constants
#define KERNEL_ADDRESS 0x7c00 + 512 + 512
#define STACK_ADDRESS 0x7c00 - 1

// Some types
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define NULL  ((void *)0)
#define true  1
#define false 0

#define VA_ARG(REF_ARG, I, T) ((T)(*((T *)((&REF_ARG) + I * 4))))

#endif