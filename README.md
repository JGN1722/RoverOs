# RoverOS - A Work-in-Progress Operating System  

**RoverOS** is a custom operating system designed from entirely from scratch, because I believe we learn the most by reinventing the wheel. And by from scratch, I mean that I am using a self made compiler for a subset of C, and that I'm not using an IDE.  

## 🚧 **Work in Progress**
Because of these added challenges, **RoverOs** is currently under heavy development, and will be for a while.  

## Features (So Far)  

### ✅ Implemented:  
- **Basic VGA Driver**:  
  - Provides text-mode output to the screen.  
  - Allows for multiple colors and blinking text.  

- **Minimalist Filesystem**:  
  - Allows for 56 characters file names and 3 characters extensions.  
  - Can manage up to 2Gb of storage.  
  - Can contain up to 256 files or folders.  

- **Interrupt Handling**:  
  - Can receive and respond to any software, IRQ or error interrupt.
  - Allows for keyboard input, and much more coming soon.   

### 🛠️ In Progress:  
- **Memory Management**:  
  - Developing a physical memory manager for heap allocations.  
  - Future plans include support for paging and virtual memory.  

## Goals  
- My plan for RoverOs is to make it an OS one can use in their everyday life, with a CLI, multiple terminals, a text editor, a network stack, multiprocessing, complete power management, and multiple programming languages ported to it. And who knows, maybe one day a web browser ...?   
- RoverOs is likely to never contain any kind of GUI, as I personally believe CLIs look better, and can provide user interfaces that are just as good.  
- Create a nice and cozy development environment for everyday programming, without all the bloat of windows or linux.   

## How to Build  
No build script is provided right now, but an image file can be found in the [image](/image) folder. If you really wish to build it yourself, you can do so on Windows by running the following commands from the root of the repo:  
+ assemble the boot sector:  
  ```compilers\FASM.EXE main_source\boot_sect.asm image\boot_sect.bin```
+ compile the kernel:  
  ```roverc.py ..\main_source\kernel.c```
+ build the image file system:  
  ```buildfs.py```
+ create the image file:
  

## Contribution  
Contributions are welcome, but due to the early stage of development, the project lacks comprehensive documentation and well-defined workflows. If you'd like to contribute, feel free to reach out or submit issues/PRs.  

## Future Plans  
- Complete the memory management system.  
- Expand the custom language compiler to support advanced features.  
- Implement a multitasking kernel.  
- Explore support for other hardware architectures.  

## Acknowledgments  
This project is inspired by various OS development resources and the incredible open-source community.  

---

**Disclaimer:** This project is for educational and experimental purposes. It is not intended for production use.  

**Stay tuned for updates!**
