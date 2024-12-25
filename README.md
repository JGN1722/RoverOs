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
- RoverOs should become a nice and cozy development environment for everyday programming, without all the bloat of windows or linux.   

## How to Build  
### Requirements  
As the compiler is part of the project, all you need is a python interpreter. I'm personnally using python 3.12.1.  
### Instructions  
To build RoverOs on windows, run the provided build script. If you wish to run the image directly, you can pass it the argument -run:  
> build.bat -run

To do so, you need to have Bochs installed. I have not tested building on Linux, or running with other emulators.  

## Contribution  
Contributions are welcome, but due to the early stage of development, the project lacks comprehensive documentation and well-defined workflows, I cannot give pointers to the parts of the code that must be improved

## Acknowledgments  
This project is inspired by various OS development resources, mostly on the [OsDev wiki](https://wiki.osdev.org/Expanded_Main_Page). For the compiler, I must thank Jack Crenshaw and his incredibly useful [Let's Build a Compiler](https://compilers.iecc.com/crenshaw/), as well as Ruslan Spivak for his blog series [Let's build a simple interpreter](https://ruslanspivak.com/lsbasi-part1/). My inspiration comes from tishion's [PiscisOs](https://tishion.github.io/PiscisOS/).

---

**Disclaimer:** This project is for educational and experimental purposes. It is not intended for production use, and has not been tested on real hardware yet.  

**Stay tuned for updates!**
