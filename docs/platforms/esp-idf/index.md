# ESP-IDF

- **Template**: [ulf-esp-idf-template](https://github.com/lf-lang/ulf-esp-idf-template)
- **ESP-IDF Documentation**: [docs.espressif.com](https://docs.espressif.com/projects/esp-idf/en/latest/)
- **Supported Boards**: ESP32, ESP32-C3, ESP32-C6, ESP32-S2, ESP32-S3, ESP32-H2

## Prerequisites

In addition to the common prerequisites:

- **Python 3.8+**
- **CMake 3.20+**
- **Ninja** build system

## Setup

Clone and initialize submodules:

```bash
git clone https://github.com/lf-lang/ulf-esp-idf-template.git my-project
cd my-project
git submodule update --init --recursive
```

### Option A: Using Nix (Recommended)

```bash
nix develop           # Default: ESP32
nix develop .#esp32c3 # ESP32-C3
nix develop .#esp32c6 # ESP32-C6
```

### Option B: Manual Setup

```bash
cd esp-idf
./install.sh esp32c6  # Or: esp32, esp32c3, all, etc.
source ./export.sh
cd ..
```

Source `export.sh` in each new terminal:

```bash
source ./esp-idf/export.sh
```

## Building

Set the target board and configure:

```bash
export ESP_BOARD=esp32c6

cmake -Bbuild \
      -DESP_IDF_BOARD=$ESP_BOARD \
      -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake \
      -GNinja
```

Build:

```bash
cmake --build build -j $(nproc)
```

## Flashing

```bash
cd build
ninja flash
```

Or specify the port:

```bash
ninja flash -p /dev/ttyUSB0
```

Flash and monitor:

```bash
ninja flash && ninja monitor
```

Press `Ctrl+]` to exit the monitor.

## Changing the Application

```bash
cmake -Bbuild \
      -DLF_MAIN=Timer \
      -DLOG_LEVEL=LF_LOG_LEVEL_DEBUG \
      -DESP_IDF_BOARD=$ESP_BOARD \
      -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-$ESP_BOARD.cmake \
      -GNinja
```

## Build Parameters

| Parameter | Description |
|-----------|-------------|
| `LF_MAIN` | LF file to compile (default: `HelloEsp`) |
| `LOG_LEVEL` | `LF_LOG_LEVEL_ERROR`, `WARN`, `INFO`, `DEBUG` |
| `ESP_IDF_BOARD` | `esp32`, `esp32c3`, `esp32c6`, `esp32s2`, `esp32s3`, `esp32h2` |

## Cleaning

```bash
rm -rf src-gen build
```

## Example Applications

- **HelloEsp** - Serial console output
- **Timer** - Periodic timer events
- **Blink** - LED toggle
