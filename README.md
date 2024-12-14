# RoverOS - A Work-in-Progress Operating System  

**RoverOS** is a custom operating system designed from scratch, with a focus on being built entirely in my custom programming language. This project is in its early stages and serves as a platform to explore low-level system programming, language design, and operating system concepts.  

## 🚧 **Work in Progress**  
Please note that **RoverOS** is still under heavy development. A custom compiler for my language is under construction, and most of the current functionality has been implemented using a combination of assembly and placeholder code for my language. Expect frequent changes, incomplete features, and rough edges.  

## Features (So Far)  

### ✅ Implemented:  
- **Basic VGA Driver**:  
  - Provides text-mode output to the screen.  
  - Useful for debugging and basic UI during development.  

- **Basic Filesystem**:  
  - A simple, custom filesystem implementation for reading and writing files.  
  - Serves as a starting point for more complex storage systems.  

- **Interrupt Handling**:  
  - Robust interrupt handling for hardware and software interrupts.  
  - Includes support for IRQs and exception handling.  

- **Keyboard Input**:  
  - A basic driver for processing keyboard input.  
  - Currently supports scancode translation for text input.  

### 🛠️ In Progress:  
- **Memory Management**:  
  - Developing a memory manager for heap and stack allocations.  
  - Future plans include support for paging and virtual memory.  

- **Custom Language Integration**:  
  - The compiler for my custom programming language is in progress.  
  - RoverOs will eventually be written entirely in this language.  

## Goals  
- Develop a fully functional operating system written in my custom language.  
- Implement core OS features, including process management, networking, and a graphical user interface (GUI).  
- Create a seamless development environment for the custom language.  

## How to Build  
Currently, building RoverOS requires only a python interpreter, even if I am yet to provide a build script. Detailed instructions will be provided once the custom language compiler is ready.  

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
