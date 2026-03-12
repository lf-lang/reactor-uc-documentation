# Code Generation and Compilation 

The design of systems with reactor-uc and LF follows a top-down design approach, where the programmer starts with his design written in LF. The LF compiler (lfc) translates your design into C code. This generated code uses the reactor-uc runtime functions to execute the program. When you create federated (distributed) programs, lfc generates subfolders for each federate (node) in your system. The goal of reactor-uc is to enable integration into existing toolchains. For example, for projects based on Zephyr, we provide lfc-integration through a custom west command. When building an application the programmer interacts with west as usual, and west calls lfc to generate C code from the LF source files, finally west uses CMake to configure and build the final executable. Another example is RIOT OS, which has a Make-based toolchain. For RIOT we integrate lfc into the application Makefile such that calling make all first invokes lfc on the LF sources before compiling the generated sources.


``` mermaid
graph LR
  A[Platform Tooling] --> B;
  B[LFG] -->|Success| C;
  C[Generated Code] --> D;
  D[Cross Compiler] --> E[Binary];
  F[reactor-uc] --> D;
```

lfc produces importable CMake and make files that you can import into your build-system. For common platforms like Zephyr, RIOT or the pico-sdk we provide build-templates.