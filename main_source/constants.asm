KERNEL_ADDRESS = 0x7c00 + 512 + 512
STACK_ADDRESS = 0x7c00 - 1
IDT_ADDRESS = 0x0
IDT_ENTRIES = 256
IDTR_ADDRESS = IDT_ADDRESS + IDT_ENTRIES * 8
IDTR_SIZE = 6
MEM_MAP_ADDRESS = IDTR_ADDRESS + IDTR_SIZE
MEM_MAP_ENTRIES_START = MEM_MAP_ADDRESS + 4

IDT_ERR_ENTRIES = 32
IRQ_NUMBER = 16
MASTER_IRQ_VECTOR_OFFSET = 0x20
SLAVE_IRQ_VECTOR_OFFSET = 0x28

VIDEO_MEMORY = 0xB8000
WHITE_ON_BLACK = 0x0f
MAX_ROWS = 25
MAX_COLS = 80
REG_SCREEN_CTRL = 0x3D4
REG_SCREEN_DATA = 0x3D5

PIC1_COMMAND = 0x20
PIC1_DATA = 0x21
PIC2_COMMAND = 0xA0
PIC2_DATA = 0xA1
ICW1_INIT = 0x10
ICW1_ICW4 = 0x01
PIC_EOI = 0x20
ICW4_8086 = 0x01