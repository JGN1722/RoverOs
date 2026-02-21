import os
import sys
import struct

# A crappy ext2fs implementation

# The comments do not, or barely, explain what is going on. Before you
# try to read this source, make sure you're familiar with the ext2fs
# specification. Here's the document I used as a reference:
# https://cscie28.dce.harvard.edu/lectures/lect04/6_Extras/ext2-struct.html

EXT2_MAGIC = 0xef53

EXT2_FT_REG_FILE	= 1
EXT2_FT_DIR		= 2

EXT2_S_IFREG	= 0x8000
EXT2_S_IFDIR	= 0x4000

# I'm ashamed of this function. Please don't ever bring it up.
def align_up(x, align):
	while x % align != 0:
		x += 1
	return x

class DirectoryEntry:
	def __init__(self, objtype, obj, name):
		self.type = objtype
		self.obj = obj
		self.name = name

class Directory:
	def __init__(self, name):
		self.files = {} # name : object
		self.subdirectories = {}
		
		self.entries = []
		self.logical_blocks = []
		self.data_blocks = []
		self.data_block_count = 0
		
		self.inode_number = 0
		
		self.name = name # Useless, only for debugging
	
	def create_blocks(self, block_size):
		# First thing is getting the list of item entries
		
		# TODO: Here is where I ought to add the special subdirs
		
		for f in self.files.keys():
			self.entries.append(DirectoryEntry(
				EXT2_FT_REG_FILE,
				self.files[f],
				f
			))
		for d in self.subdirectories.keys():
			self.entries.append(DirectoryEntry(
				EXT2_FT_DIR,
				self.subdirectories[d],
				d
			))
		
		# Then, we group them in logical blocks
		current_block = bytearray(block_size)
		index = 0
		for i in range(len(self.entries)):
			e = self.entries[i]
			
			if index >= block_size:
				self.logical_blocks.append(current_block)
				current_block = bytearray(block_size)
				index = 0
			
			if i == len(self.entries) - 1:
				rec_len = block_size - index
			else:
				rec_len = align_up(8+len(e.name), 4)
				
				next_e = self.entries[i + 1]
				next_rec_len = align_up(
					8+len(next_e.name), 4
				)
				
				if index + rec_len + next_rec_len > block_size:
					rec_len = block_size - index
			
			be = bytearray(rec_len)
			be[0:4] = struct.pack('<I', e.obj.inode_number)
			be[4:6] = struct.pack('<H', rec_len)
			be[6:7] = struct.pack('<B', len(e.name))
			be[7:8] = struct.pack('<B', e.type)
			for i in range(len(e.name)):
				be[8+i:8+i+1] = struct.pack(
					'<B', ord(e.name[i])
				)
			current_block[index:index + len(be)] = be
			index += len(be)
		
		self.logical_blocks.append(current_block)
		
		# Then, order those blocks in 13 direct blocks, an indirect
		# block, and then the doubly and trebly indirect blocks
		self.data_blocks = [None] * 15
		self.data_block_count = 0
		i = 0
		
		def create_indirect_block(start_i):
			i = start_i
			indirect_block = [None] * (block_size // 4)
			count = 0
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect_block[i] = self.logical_blocks[i]
				count += 1
				i += 1
			return indirect_block, i, count
		
		def create_indirect2(start_i):
			i = start_i
			indirect = [None] * (block_size // 4)
			count = 0
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect[i], i, c = create_indirect_block(i)
				count += c
			return indirect, i, count
		
		def create_indirect3(start_i):
			i = start_i
			indirect = [None] * (block_size // 4)
			count = 0
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect[i], i, c = create_indirect2(i)
				count += c
			return indirect, i, count
		
		# 13 direct blocks
		while i < 12:
			if i >= len(self.logical_blocks):
				return
			
			self.data_blocks[i] = self.logical_blocks[i]
			self.data_block_count += 1
			i += 1
		
		indirect_block, i, c = create_indirect_block(i)
		self.data_blocks[12] = indirect_block
		self.data_block_count += c
		
		if i >= len(self.logical_blocks):
			return
		
		indirect_block, i, c = create_indirect2(i)
		self.data_blocks[13] = indirect_block
		self.data_block_count += c
		
		if i >= len(self.logical_blocks):
			return
		
		indirect_block, i, c = create_indirect3(i)
		self.data_blocks[14] = indirect_block
		self.data_block_count += c

class File:
	def __init__(self, name, content):
		self.content = content
		self.logical_blocks = []
		self.data_blocks = []
		self.data_block_count = 0
		
		self.inode_number = None
		
		self.name = name # Useless, only for debugging
	
	def create_blocks(self, block_size):
		# First, divide the content into blocks
		i = 0
		self.logical_blocks = []
		
		while i * block_size < len(self.content):
			b = i * block_size
			self.logical_blocks.append(
				self.content[b:b + block_size]
				.ljust(block_size, b'\x00')
			)
			i += 1
		
		# Then, order those blocks in 13 direct blocks, an indirect
		# block, and then the doubly and trebly indirect blocks
		self.data_blocks = [None] * 15
		self.data_block_count = 0
		i = 0
		
		def create_indirect_block(start_i):
			i = start_i
			count = 1 # 1 bc we create the indirect block itself
			indirect_block = [None] * (block_size // 4)
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect_block[i - start_i] = self.logical_blocks[i]
				count += 1
				i += 1
			return indirect_block, i, count
		
		def create_indirect2(start_i):
			i = start_i
			count = 1
			indirect = [None] * (block_size // 4)
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect[i - start_i], i, c = create_indirect_block(i)
				count += c
			return indirect, i, count
		
		def create_indirect3(start_i):
			i = start_i
			count = 1
			indirect = [None] * (block_size // 4)
			while i < block_size // 4:
				if i >= len(self.logical_blocks):
					break
				
				indirect[i - start_i], i, c = create_indirect2(i)
				count += c
			return indirect, i, count
		
		# 13 direct blocks
		while i < 12:
			if i >= len(self.logical_blocks):
				return
			
			self.data_blocks[i] = self.logical_blocks[i]
			self.data_block_count += 1
			i += 1
		
		indirect_block, i, c = create_indirect_block(i)
		self.data_blocks[12] = indirect_block
		self.data_block_count += c
		
		if i >= len(self.logical_blocks):
			return
		
		indirect_block, i, c = create_indirect2(i)
		self.data_blocks[13] = indirect_block
		self.data_block_count += c
		
		if i >= len(self.logical_blocks):
			return
		
		indirect_block, i, c = create_indirect3(i)
		self.data_blocks[14] = indirect_block
		self.data_block_count += c

class FileSystem:
	def __init__(self, boot_file, block_size,
		inode_size, blocks_per_group, inodes_per_group,
		first_inode, root_inode, res_blocks):
		
		self.BOOTLOADER  = boot_file
		
		self.BLOCK_SIZE = block_size
		self.INODE_SIZE = inode_size
		self.BLOCKS_PER_GROUP = blocks_per_group
		self.INODES_PER_GROUP = inodes_per_group
		
		self.FIRST_INODE = first_inode
		self.ROOT_INODE = root_inode
		self.RES_BLOCKS = res_blocks # Not supported
		
		self.root = Directory(name='/')
		
		# self.next_inode_number = self.FIRST_INODE # Fuck this
		# TODO: support reserved inodes and reserved blocks
		self.next_inode_number = 1 # Inode 0 is root, right now
		
		self.block_group_count = 0
		self.block_groups = []
		self.data_block_list = []
		self.block_bitmap_list = []
	
	def dump_files(self):
		def dump_dir(dir,tabs=0):
			for f in dir.files.keys():
				print('\t' * tabs + f'[+] {f}')
			for d in dir.subdirectories.keys():
				print('\t' * tabs + f'[-] {d}')
				dump_dir(dir.subdirectories[d], tabs + 1)
		print('[-] /')
		dump_dir(self.root, 1)
	
	@staticmethod
	def get_path_first_dir(path):
		if path[0] != '/':
			print('Invalid path:', path)
			print('Expected first character is \'/\'')
			sys.exit(-1)
		
		path = path[1:]
		
		i = 0
		while path[i] != '/':
			i += 1
			if i >= len(path):
				return path, ''
		
		if path[i:] == '/':
			return path[:i], ''
		return path[:i], path[i:]
	
	def add_dir(self, path, name):
		wd = self.root
		if path != '/':
			rest = path
			while rest != '':
				dir, rest = self.get_path_first_dir(rest)
				
				if not dir in wd.subdirectories.keys():
					print('path not found:', path)
					sys.exit(-1)
				wd = wd.subdirectories[dir]
		
		if name in wd.subdirectories.keys():
			print('directory already present:', path+name)
			sys.exit(-1)
		
		wd.subdirectories[name] = Directory(name=name)
		
		wd.subdirectories[name].inode_number = self.next_inode_number
		self.next_inode_number += 1
	
	def add_file(self, path, name, content):
		if not isinstance(content, bytes):
			print('Content of', path+name, 'is not bytes as expected')
			sys.exit(-1)
		
		if len(name) >= 255:
			print('Name \'',name,'\' is longer than 255 chars')
			sys.exit(-1)
		
		wd = self.root
		if path != '/':
			rest = path
			while rest != '':
				dir, rest = self.get_path_first_dir(rest)
				
				if not dir in wd.subdirectories.keys():
					print('path not found:', path)
					sys.exit(-1)
				wd = wd.subdirectories[dir]
		
		if name in wd.files.keys():
			print('file already present:', path+name)
			sys.exit(-1)
		
		wd.files[name] = File(name=name, content=content)
		
		wd.files[name].inode_number = self.next_inode_number
		self.next_inode_number += 1
	
	def get_log_block_size(self):
		l = 0
		while 1024 << l != self.BLOCK_SIZE:
			l += 1
		return l
	
	def read_bootloader(self):
		with open(self.BOOTLOADER, 'rb') as f:
			data = f.read()
		bytearr_data = bytearray(1024)
		bytearr_data[0:1024] = data
		return bytearr_data
	
	def add_block_to_list(self, block):
		"""
		Adds a block to the list of blocks that will be written as
		is to the block groups. At this stage of the conversion to
		binary, we already need to know the definitive address of
		each block. This is why this function is tricky: We need to
		take into account every fs structure that's in the way to
		assign the correct ID to every block.
		Returns the actual address of the block once appended to the
		data array.
		"""
		i = len(self.data_block_list)
		
		# Calculate how many blocks are needed for every structure
		
		# Disk layout is as follows:
		# - Bootloader
		# - Superblock
		# - Block Group Descriptor Table
		# - Block groups
		# The bootloader is prepended later
		n_SB = 1
		n_BGDT = align_up(32 * self.block_group_count, self.BLOCK_SIZE) // self.BLOCK_SIZE
		
		# Starting offset of the block groups
		# TODO: it isn't there are superblock copies everywhere
		# and maybe copies of the bgdt as well
		n_start = n_SB + n_BGDT
		
		# The layout of a block group is as follows
		# - Inode bitmap
		# - Block bitmap
		# - Inode table
		# - Data blocks
		n_IB = align_up(self.INODES_PER_GROUP, 8 * self.BLOCK_SIZE) // (8 * self.BLOCK_SIZE)
		n_BB = align_up(self.BLOCKS_PER_GROUP, 8 * self.BLOCK_SIZE) // (8 * self.BLOCK_SIZE)
		n_IT = self.INODE_SIZE * self.INODES_PER_GROUP // self.BLOCK_SIZE
		n_DB = self.BLOCKS_PER_GROUP
		
		n_BG = n_IB + n_BB + n_IT + n_DB
		n_BG_header = n_IB + n_BB + n_IT
		
		if i == 0:
			for j in range(n_start):
				self.data_block_list.append(None)
			i += n_start
		
		# Always true on the first call of this function
		if (i - n_start) % n_BG == 0:
			for j in range(n_BG_header):
				self.data_block_list.append(None)
			bg_i = (i - n_start) // n_BG
			self.block_groups[bg_i].IB_lba = 1 + i
			self.block_groups[bg_i].BB_lba = 1 + i + n_IB
			self.block_groups[bg_i].IT_lba = 1 + i + n_IB + n_BB
			i += n_BG_header
		
		bg_i = (i - n_start) // n_BG
		self.block_groups[bg_i].add_block(block)
		
		self.data_block_list.append(block)
		return i
	
	def linearize_block(self, block):
		"""
		A helper for the next function: takes a block that can
		contain either data or pointers to other blocks, and appends
		the data blocks directly to the binary data list, and fills
		the pointers contained by pointer blocks recursively.
		Returns the address that was assigned to a block.
		"""
		if type(block) == bytearray or type(block) == bytes:
			return self.add_block_to_list(block)
		data_block = bytearray(self.BLOCK_SIZE)
		for i in range(self.BLOCK_SIZE // 4):
			if not block[i]:
				data_block[i * 4:(i + 1) * 4] = struct.pack('<I', 0)
				continue
			data_block[i * 4:(i + 1) * 4] = struct.pack('<I', self.linearize_block(block[i]) + 1)
		return self.add_block_to_list(data_block)
	
	def linearize_data_blocks(self, dir):
		"""
		Takes every item - files and directories - and creates
		an array containing all of their data blocks. Also, update
		the files by giving them a 15 int array containing the
		newly assigned LBA of their data blocks. This will make
		the process of creating inodes and converting to binary
		much easier.
		The function iterates over every item recursively, starting
		with dir.
		"""
		for f in dir.files.values():
			for i in range(len(f.data_blocks)):
				b = f.data_blocks[i]
				
				if not b:
					f.data_blocks[i] = 0
					continue
				lba = self.linearize_block(b)
				f.data_blocks[i] = 1 + lba
		
		for d in dir.subdirectories.values():
			self.linearize_data_blocks(d)
		
		for i in range(len(dir.data_blocks)):
			b = dir.data_blocks[i]
			
			if not b:
				dir.data_blocks[i] = 0
				continue
			lba = self.linearize_block(b)
			dir.data_blocks[i] = 1 + lba
	
	def write_inodes(self, arr):
		"""
		arr is supposed to be the array of every file and directory,
		already ordered by inode number. This function writes the
		corresponding inodes to the block groups.
		"""
		for e in arr:
			bg_i = e.inode_number // self.INODES_PER_GROUP
			if type(e) == File:
				self.block_groups[bg_i].add_inode(Inode(
					mode=EXT2_S_IFREG,
					size=len(e.content),
					blocks=len(e.logical_blocks) * (self.BLOCK_SIZE // 512),
					block=e.data_blocks,
					inode_size=self.INODE_SIZE
				), False)
			else:
				self.block_groups[bg_i].add_inode(Inode(
					mode=EXT2_S_IFDIR,
					size=len(e.logical_blocks) * self.BLOCK_SIZE,
					blocks=len(e.logical_blocks) * (self.BLOCK_SIZE // 512),
					block=e.data_blocks,
					inode_size=self.INODE_SIZE
				), True)
	
	def fs_to_bin_repr(self):
		"""
		Create an array of block group objects that represent the
		files and directories that have been created in the file
		system.
		"""
		inodes = []
		
		flattened_dir_entries = [None] * self.next_inode_number
		# Split every file and directory into their data blocks
		def create_data_blocks(dir):
			nonlocal flattened_dir_entries
			data_blocks = 0
			for f in dir.files.values():
				f.create_blocks(self.BLOCK_SIZE)
				flattened_dir_entries[f.inode_number] = f
				data_blocks += f.data_block_count
			for d in dir.subdirectories.values():
				data_blocks += create_data_blocks(d)
			dir.create_blocks(self.BLOCK_SIZE)
			flattened_dir_entries[dir.inode_number] = dir
			return data_blocks + dir.data_block_count
		data_block_count = create_data_blocks(self.root)
		
		# Calculate the number of block groups needed to accomodate
		# all the inodes, and then all the data blocks. The number
		# of block groups we will create is the maximum of those
		# two.
		# TODO: those formulas are fucked up, probably. Idk tho.
		i_n_bg = 1 + (self.next_inode_number - 1) // self.INODES_PER_GROUP
		b_n_bg = 1 + (data_block_count - 1) // self.BLOCKS_PER_GROUP
		n_bg = max(i_n_bg, b_n_bg)
		
		self.block_group_count = n_bg
		for i in range(n_bg):
			self.block_groups.append(BlockGroup(
				self.INODE_SIZE,
				self.BLOCK_SIZE,
				self.INODES_PER_GROUP,
				self.BLOCKS_PER_GROUP
			))
		
		self.linearize_data_blocks(self.root)
		self.write_inodes(flattened_dir_entries)
		
		free_blocks = self.BLOCKS_PER_GROUP - data_block_count % self.BLOCKS_PER_GROUP
		free_inodes = self.INODES_PER_GROUP - self.next_inode_number % self.INODES_PER_GROUP
		
		return free_blocks, free_inodes
	
	def to_binary(self):
		free_blocks, free_inodes = self.fs_to_bin_repr()
		
		data = b''
		for bg in self.block_groups:
			data += bg.to_bin()
		
		superblock = SuperBlock(
			self.block_group_count * self.INODES_PER_GROUP,
			self.block_group_count * self.BLOCKS_PER_GROUP,
			self.RES_BLOCKS,
			free_blocks,
			free_inodes,
			1 if self.BLOCK_SIZE == 1024 else 0,
			self.get_log_block_size(),
			self.BLOCKS_PER_GROUP,
			self.INODES_PER_GROUP
		)
		
		# TODO: I think there's supposed to be a superblock at the
		# start of every block group
		
		bgdt = bytearray(align_up(32 * self.block_group_count, self.BLOCK_SIZE))
		for i in range(len(self.block_groups)):
			bg = self.block_groups[i]
			start_i = 32 * i
			end_i = 32 * (i + 1)
			bgdt[start_i:end_i] = bg.build_descriptor()
		
		bl = self.read_bootloader()
		sb = superblock.to_binary()
		data = bl + sb + bgdt + data
		
		return data

class BlockGroup:
	def __init__(self, inode_size, block_size, n_inodes, n_blocks):
		self.inode_bitmap = []
		self.block_bitmap = []
		self.inodes = []
		self.blocks = []
		
		self.inode_size = inode_size
		self.block_size = block_size
		self.n_inodes = n_inodes
		self.n_blocks = n_blocks
		
		self.n_IB = align_up(self.n_inodes, 8 * self.block_size) // (8 * self.block_size)
		self.n_BB = align_up(self.n_blocks, 8 * self.block_size) // (8 * self.block_size)
		self.n_IT = self.inode_size * self.n_inodes // self.block_size
		
		self.free_inodes = n_inodes
		self.free_blocks = n_blocks
		
		self.BB_lba = 0
		self.IB_lba = 0
		self.IT_lba = 0
		
		self.used_dirs_count = 0
			
		for i in range(block_size):
			self.inode_bitmap.append(0)
			self.block_bitmap.append(0)
		
		self.IT = bytearray(self.block_size * self.n_IT)
		self.next_inode_i = 0
	
	def add_inode(self, inode, is_dir):
		start_i = self.next_inode_i * self.inode_size
		end_i = (self.next_inode_i + 1) * self.inode_size
		self.IT[start_i:end_i] = inode.to_bin()
		
		byte = self.next_inode_i // 8
		offset = self.next_inode_i % 8
		self.inode_bitmap[byte] |= (1 << offset)
		
		self.next_inode_i += 1
		self.free_inodes -= 1
		
		if is_dir:
			self.used_dirs_count += 1
	
	def add_block(self, block):
		self.blocks.append(block)
		i = len(self.blocks) - 1
		byte, offset = i // 8, i % 8
		self.block_bitmap[byte] |= (1 << offset)
		
		self.free_blocks -= 1
	
	def build_descriptor(self):
		return struct.pack(
			'<IIIHHH',
			self.BB_lba,
			self.IB_lba,
			self.IT_lba,
			self.free_blocks,
			self.free_inodes,
			self.used_dirs_count
		).ljust(32, b'\x00')
	
	def to_bin(self):
		data = b''
		IB = bytearray(self.block_size * self.n_IB)
		BB = bytearray(self.block_size * self.n_BB)
		for i in range(self.block_size * self.n_IB):
			IB[i] = self.inode_bitmap[i]
		for i in range(self.block_size * self.n_BB):
			BB[i] = self.block_bitmap[i]
		
		data = b''
		for b in self.blocks:
			data += b
		
		return IB + BB + self.IT + data

class Inode:
	def __init__(self, mode, size, blocks, block, inode_size):
		self.mode = mode
		self.uid = 42
		self.size = size
		self.atime = 0
		self.ctime = 0
		self.mtime = 0
		self.dtime = 0
		self.gid = 0
		self.links_count = 1
		self.blocks = blocks
		self.flags = 0
		self.osd1 = 0
		self.block = block
		self.generation = 0
		self.file_acl = 0
		self.dir_acl = 0
		self.faddr = 0
		
		self.inode_size = inode_size
	
	def to_bin(self):
		i = struct.pack(
			'<' + 'H' * 2 + 'I' * 5 + 'H' * 2 + 'I' * (7 + 15),
			self.mode,
			self.uid,
			self.size,
			self.atime,
			self.ctime,
			self.mtime,
			self.dtime,
			self.gid,
			self.links_count,
			self.blocks,
			self.flags,
			self.osd1,
			self.block[0],
			self.block[1],
			self.block[2],
			self.block[3],
			self.block[4],
			self.block[5],
			self.block[6],
			self.block[7],
			self.block[8],
			self.block[9],
			self.block[10],
			self.block[11],
			self.block[12],
			self.block[13],
			self.block[14],
			self.generation,
			self.file_acl,
			self.dir_acl,
			self.faddr
		)
		return i.ljust(self.inode_size, b'\x00')

class SuperBlock:
	def __init__(self, inode_count, block_count, r_block_count,
		free_blocks_count, free_inodes_count, first_data_block,
		log_block_size,	blocks_per_group, inodes_per_group):
		self.inode_count = inode_count
		self.block_count = block_count
		self.r_block_count = r_block_count
		self.free_blocks_count = free_blocks_count
		self.free_inodes_count = free_inodes_count
		self.first_data_block = first_data_block
		self.log_block_size = log_block_size
		self.log_frag_size = 0
		self.blocks_per_group = blocks_per_group
		self.frags_per_group = 0
		self.inodes_per_group = inodes_per_group
		self.mtime = 0
		self.wtime = 0
		self.mnt_count = 0
		self.max_mnt_count = 0
		self.state = 1
		self.errors = 3
		self.minor_rev_level = 0
		self.lastcheck = 0
		self.checkinterval = 0
		self.creator_os = 0
		self.rev_level = 0
		self.def_resuid = 0
		self.def_resgid = 0
	
	def to_binary(self):
		return struct.pack(
			'<' + 'I' * 13 + 'H' * 6 + 'I' * 4 + 'H' * 2,
			self.inode_count,
			self.block_count,
			self.r_block_count,
			self.free_blocks_count,
			self.free_inodes_count,
			self.first_data_block,
			self.log_block_size,
			self.log_frag_size,
			self.blocks_per_group,
			self.frags_per_group,
			self.inodes_per_group,
			self.mtime,
			self.wtime,
			self.mnt_count,
			self.max_mnt_count,
			EXT2_MAGIC,
			self.state,
			self.errors,
			self.minor_rev_level,
			self.lastcheck,
			self.checkinterval,
			self.creator_os,
			self.rev_level,
			self.def_resuid,
			self.def_resgid
		).ljust(1024, b'\x00')

script_dir = os.path.dirname(os.path.abspath(__file__)) + '\\'
KERNEL_FILE = script_dir + '..\\image\\kernel.bin'
BOOTLOADER = script_dir + '..\\image\\boot_sect.bin'
IMAGE_NAME = script_dir + '..\\image\\image.bin'

fs = FileSystem(
	boot_file=BOOTLOADER,
	block_size=1024,
	inode_size=128,
	blocks_per_group=1024 * 8,
	inodes_per_group=(2 * 1024) // 128, # Two blocks wide inode table
	first_inode=11,
	root_inode=2,
	res_blocks=0
)

with open(KERNEL_FILE, 'rb') as k:
	fs.add_file('/', 'kernel.bin', k.read())

fs.add_dir('/', 'etc')
fs.add_dir('/etc/', 'conf')
fs.add_file('/etc/conf/', 'conf.cfg', b'truc')

fs.add_dir('/', 'bin')
fs.add_file('/bin/', 'exec.elf', b'aaa')

fs.dump_files()

with open(IMAGE_NAME, 'wb') as f:
	f.write(fs.to_binary())

print('Image created')
