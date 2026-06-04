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
| [Zephyr](zephyr/index.md) | [lf-zephyr-uc-template](https://github.com/lf-lang/lf-zephyr-uc-template) | West |
| [RIOT](riot/index.md) | [lf-riot-uc-template](https://github.com/lf-lang/lf-riot-uc-template) | Make |
| [Pico](pico/index.md) | [lf-pico-uc-template](https://github.com/lf-lang/lf-pico-uc-template) | CMake |
| [FreeRTOS](freertos/index.md) | [lf-freertos-uc-template](https://github.com/lf-lang/lf-freertos-uc-template) | CMake |
| [ESP-IDF](esp-idf/index.md) | [lf-esp-idf-uc-template](https://github.com/lf-lang/lf-esp-idf-uc-template) | CMake + ESP-IDF |
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
