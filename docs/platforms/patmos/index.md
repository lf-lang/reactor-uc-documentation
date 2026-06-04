# Patmos

- **Template**: [lf-patmos-template](https://github.com/lf-lang/lf-patmos-template)
- **Patmos Project**: [patmos-project](https://github.com/t-crest/patmos)

Patmos is a time-predictable processor designed for hard real-time systems and WCET (Worst-Case Execution Time) analysis. The uLF runtime supports single-threaded static scheduling on Patmos.

## Prerequisites

- Patmos toolchain (patmos-clang compiler)
- Pasim simulator
- Platin WCET analysis tool

## Setup

Clone the required repositories:

```bash
# Clone the Patmos template
git clone https://github.com/lf-lang/lf-patmos-template.git

# Clone Lingua Franca and checkout the static schedule branch
git clone https://github.com/lf-lang/lingua-franca.git
cd lingua-franca
git checkout static-schedule-single-thread
git submodule update --init core/src/main/resources/lib/c/reactor-c
cd ..
```

Copy support files:

```bash
cp -r lf-patmos-template/patmos lingua-franca/test/C/src/static/patmos
cp lf-patmos-template/Makefile lingua-franca/test/C/Makefile
cp lf-patmos-template/ADASModel.lf lingua-franca/test/C/src/static/ADASModel.lf
cp lf-patmos-template/SimpleConnection.lf lingua-franca/test/C/src/static/SimpleConnection.lf
```

## Building and Running

Navigate to the test directory:

```bash
cd lingua-franca/test/C
```

Build and simulate:

```bash
make APP=SingleConnection
```

This will:

1. Generate C code using `lfc`
2. Compile with the Patmos compiler
3. Simulate with Pasim
4. Analyze with Platin

## WCET Analysis

Analyze a specific function:

```bash
make APP=SingleConnection FUNC=_sinkreaction_function_0 wcet
```

## Make Targets

| Target | Description |
|--------|-------------|
| `gen` | Generate C code using lfc |
| `copy` | Copy support files to src-gen |
| `comp` | Compile with Patmos compiler |
| `sim` | Simulate with Pasim |
| `wcet` | Analyze WCET with Platin |
| `clean` | Delete compiled files |
| `del` | Delete all generated code |

## Static Scheduling

Patmos uses the uLF runtime's **static scheduler** for predictable execution timing. The schedule is computed at compile time, enabling precise WCET analysis.
