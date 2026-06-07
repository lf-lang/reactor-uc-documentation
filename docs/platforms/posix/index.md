# POSIX (Linux / macOS)

The Native platform target compiles and runs micro-LF programs directly on POSIX-compatible operating systems. Both **Linux** and **macOS** are supported with no additional hardware or cross-compilation toolchain required.

## Setup

No platform-specific dependencies are needed beyond a standard C compiler (e.g. `gcc` or `clang`) and `cmake`. These are typically pre-installed on macOS (via Xcode Command Line Tools) and available through your distribution's package manager on Linux.

## Usage

Add the `@platform("Native")` attribute to your main reactor (or to the federated top-level reactor):

```lf
@platform("Native")
main reactor {
    ...
}
```

When you run the compiler, it will compile the generated C code for the native host platform and place the resulting executable binary in the `bin/` directory of your project:

```bash
bin/MyApp
```

## Federated Programs

The same attribute applies to the top-level federated reactor:

```lf
@platform("Native")
federated reactor MyFederatedApp {
    ...
}
```

