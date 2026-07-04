# Platforms

micro-LF supports multiple embedded platforms through dedicated **template repositories**. Each template provides a pre-configured project structure with build system integration, example applications, and platform-specific setup.

## Getting Started

To start a new project:

1. Create a repository from the template on GitHub
2. Clone with submodules: `git clone --recurse-submodules <your-repo>`
3. Set `REACTOR_UC_PATH` to your micro-LF installation
4. Follow the platform-specific build instructions

## Template Repositories

| Platform | Template | Build System |
|----------|----------|--------------|
| [Zephyr](zephyr/index.md) | [ulf-zephyr-template](https://github.com/lf-lang/ulf-zephyr-template) | West |
| [RIOT](riot/index.md) | [ulf-riot-template](https://github.com/lf-lang/ulf-riot-template) | Make |
| [Pico](pico/index.md) | [ulf-pico-template](https://github.com/lf-lang/ulf-pico-template) | CMake |
| [FreeRTOS](freertos/index.md) | [ulf-freertos-template](https://github.com/lf-lang/ulf-freertos-template) | CMake |
| [ESP-IDF](esp-idf/index.md) | [ulf-esp-idf-template](https://github.com/lf-lang/ulf-esp-idf-template) | CMake + ESP-IDF |
| [Patmos](patmos/index.md) | [lf-patmos-template](https://github.com/lf-lang/lf-patmos-template) | Make |

## Common Prerequisites

All platforms require:

- **Linux** or **macOS** (some support Windows via WSL)
- **Git** for version control
- **Java 17** for the Lingua Franca compiler
- **micro-LF** cloned with `REACTOR_UC_PATH` environment variable set

```bash
git clone https://github.com/lf-lang/reactor-uc.git --recurse-submodules
export REACTOR_UC_PATH=/path/to/reactor-uc
```
