import os
import struct

# Constants
BOOT_SECTOR_SIZE = 512
SUPERBLOCK_SIZE = 1024
BLOCK_SIZE = 1024
INODE_SIZE = 64
INODE_COUNT = 128
TOTAL_SIZE = SUPERBLOCK_SIZE + INODE_SIZE * INODE_COUNT

# File paths
script_dir = os.path.dirname(os.path.abspath(__file__)) + '\\'
FS_BIN = script_dir + '..\\image\\fs.bin'
KERNEL_BIN = script_dir + '..\\image\\kernel.bin'

# Helper function to pad data to the nearest block size
def pad_to_block_size(data, block_size=BLOCK_SIZE):
    padding = block_size - (len(data) % block_size)
    if padding == block_size:
        return data  # No padding needed
    return data + b'\x00' * padding

# Initialize the buffer
buffer = bytearray(TOTAL_SIZE)

# Fill the superblock with placeholder data (0xCA)
buffer[0:SUPERBLOCK_SIZE] = bytearray([0xCA] * SUPERBLOCK_SIZE)

# Fill inodes
inode_start_offset = SUPERBLOCK_SIZE

# Helper to write an inode
def write_inode(index, used, name, ext, num_blocks, data_pointer):
    inode_offset = inode_start_offset + index * INODE_SIZE
    inode = bytearray(INODE_SIZE)
    
    # Used flag (1 byte)
    inode[0] = 1 if used else 0
    
    # Name (57 bytes, padded with \x00)
    name_bytes = name.encode('ascii')[:57]
    inode[1:1 + len(name_bytes)] = name_bytes
    
    # Extension (3 bytes, padded with \x00)
    ext_bytes = ext.encode('ascii')[:3]
    inode[57:57 + len(ext_bytes)] = ext_bytes
    
    # Number of blocks (1 byte)
    inode[59] = num_blocks
    
    # Data pointer (4 bytes, little-endian)
    struct.pack_into('<I', inode, 60, data_pointer)
    
    # Write inode to buffer
    buffer[inode_offset:inode_offset + INODE_SIZE] = inode

# Write the root inode
root_data_pointer = TOTAL_SIZE
write_inode(0, True, "", "", 1, root_data_pointer)

# Allocate space for the root inode's data block
buffer += bytearray(BLOCK_SIZE)
buffer[root_data_pointer] = 1  # Kernel inode index (1-based)

# Write the kernel inode
kernel_data_offset = TOTAL_SIZE + BLOCK_SIZE
kernel_name = "KERNEL"
kernel_ext = "BIN"

# Read kernel file and determine size
with open(KERNEL_BIN, 'rb') as kernel_file:
    kernel_data = kernel_file.read()

# Calculate the number of blocks needed for the kernel
kernel_size = len(kernel_data)
kernel_blocks = (kernel_size + BLOCK_SIZE - 1) // BLOCK_SIZE
kernel_data_padded = pad_to_block_size(kernel_data)

write_inode(1, True, kernel_name, kernel_ext, kernel_blocks, kernel_data_offset)

# Append the kernel data block
buffer += kernel_data_padded

# Write the filesystem image to a file
with open(FS_BIN, 'wb') as fs_file:
    fs_file.write(buffer)

print("Filesystem image created successfully!")
