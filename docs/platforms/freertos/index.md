# FreeRTOS

- **Template**: [ulf-freertos-template](https://github.com/lf-lang/ulf-freertos-template)
- **FreeRTOS Documentation**: [freertos.org](https://www.freertos.org/Documentation/02-Kernel/07-Books-and-manual/01-RTOS_book)
- **Supported Devices**: [FreeRTOS Supported Devices](https://www.freertos.org/Documentation/02-Kernel/03-Supported-devices/00-Supported-devices)

## Supported Platforms

The FreeRTOS template currently supports:

- **Pico (RP2040/RP2350)** - Raspberry Pi Pico and Pico 2

## Setup

Clone and initialize submodules:

```bash
git clone https://github.com/lf-lang/ulf-freertos-template.git my-project
cd my-project
git submodule update --init --recursive
```

Install the ARM toolchain as described in the [Pico platform](../pico/index.md) prerequisites.

## Building

```bash
mkdir build && cd build
cmake -DPLATFORM_TARGET=pico ..
make
```

## Flashing (Pico)

Put the Pico into BOOTSEL mode, then:

```bash
picotool load -x bin/Blink.elf
```

## Project Structure

```
ulf-freertos-template/
├── CMakeLists.txt
├── platforms/
│   └── pico/
│       ├── FreeRTOSConfig.h
│       ├── platform.cmake
│       └── README.md
├── src/
│   ├── Blink.lf
│   ├── HelloFreeRTOS.lf
│   └── Timer.lf
└── FreeRTOS/                # Submodule
```

## Platform Configuration

Each platform has its own `FreeRTOSConfig.h` for tuning:

- **CPU clock**: 133 MHz (Pico default)
- **Tick rate**: 100 Hz
- **Heap size**: 128 KB

## Adding New Platforms

1. Create `platforms/<platform-name>/`
2. Add `platform.cmake` with platform-specific CMake configuration
3. Add `FreeRTOSConfig.h` tuned for your hardware
4. Optionally add FreeRTOS hooks in `<platform>_freertos_hooks.c`

## Pico-Specific Features

- USB and UART stdio enabled by default
- Pico W WiFi libraries automatically linked
- Connect GPIO 0 (TX) and GPIO 1 (RX) for UART output
