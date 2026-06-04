# Code Generation and Compilation

The design of systems with micro-LF and Lingua Franca (LF) follows a top-down approach, where the programmer starts with a design written in the LF language. The LF compiler (lfc) translates this design into C code that uses the uLF runtime library for execution. This generated code is platform-agnostic and can be compiled for various embedded and resource-constrained systems.

## Code Generation Process

The LF compiler (lfc) is the code-generator that transforms LF source files into C code. lfc analyzes the reactor model, performs optimizations, and generates:

- Reactor definitions and connections
- Event scheduling logic
- Platform-specific initialization code
- Network communication code for federated systems

For federated (distributed) programs, lfc generates separate subfolders for each federate, containing the necessary code and build files for that node.

## uLF Runtime Library

The uLF runtime is technically a runtime library written in C, providing the core execution engine for the reactor model. It implements:

- Event-driven scheduling
- Logical time management
- Network communication protocols
- Platform abstraction layers

The library is highly configurable through compile-time flags, allowing it to be tailored for specific platforms and use cases without runtime overhead. Common configuration options include:

- **Logging levels**: Control verbosity for debugging and monitoring
- **Platform features**: Enable/disable platform-specific optimizations
- **Network protocols**: Select supported communication interfaces
- **Memory management**: Configure buffer sizes and allocation strategies

## Build System Integration

The uLF runtime enables seamless integration into existing toolchains. The generated code includes importable build files (CMake or Makefiles) that can be incorporated into your project's build system.

### Zephyr Integration

For Zephyr-based projects, lfc provides integration through a custom west command. The build process follows the standard Zephyr workflow:

1. west calls lfc to generate C code from LF sources
2. Generated code is compiled alongside the uLF runtime library
3. west uses CMake to configure and build the final executable

### RIOT OS Integration

For RIOT OS projects with Make-based toolchains, lfc is integrated into the application Makefile:

1. `make all` first invokes lfc on LF sources
2. Generated sources are compiled with the uLF runtime library
3. Standard RIOT build process produces the binary

### Other Platforms

For common platforms like Raspberry Pi Pico (pico-sdk), we provide build templates that simplify integration. The generated CMake files can be imported directly into your project's build configuration.

``` mermaid
graph LR
  A[LF Source Files] --> B[lfc Code Generator];
  B -->|Generates C Code| C[Platform-Specific Code];
  D[uLF Runtime Library] --> E[Configured with Compile Flags];
  C --> F[Build System];
  E --> F;
  F --> G[Cross Compiler];
  G --> H[Binary];
```

This approach ensures that micro-LF applications can be built using familiar tools while benefiting from the deterministic execution guarantees of the reactor model.
