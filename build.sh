#!/usr/bin/env bash
#
# Build script for RoverOs
# Written by JGN1722 (Github)
#
# View the source on Github:
# https://github.com/JGN1722/RoverOs
#

set -e

cd "$(dirname "$0")"

RUN="$1"

# create the target directory
mkdir -p image

# build the boot sector
echo "======= BOOT SECTOR ======="
./compilers/fasm main_source/boot_sect.asm image/boot_sect.bin
echo

# build the kernel
echo "======= KERNEL ======="
python3 compilers/roverc.py --freestanding main_source/kernel.c image/kernel.bin
echo

# build the file system
echo "======= FILE SYSTEM ======="
python3 main_source/build_fs.py
echo

# create the bochs script
echo "floppya: 1_44=$(pwd)/image/image.bin, status=inserted" > image/bochsrc
echo "boot: a" >> image/bochsrc
echo

echo "Done !"

if [ "$RUN" = "-run" ]; then
    bochs -f image/bochsrc
fi