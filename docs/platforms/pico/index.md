# Raspberry Pi Pico

- **Template**: [ulf-pico-template](https://github.com/lf-lang/ulf-pico-template)
- **Pico SDK**: [github.com/raspberrypi/pico-sdk](https://github.com/raspberrypi/pico-sdk/)
- **Documentation**: [raspberrypi.com/documentation/pico-sdk](https://www.raspberrypi.com/documentation/pico-sdk/)
- **Supported Boards**: [Pico Series](https://www.raspberrypi.com/documentation/microcontrollers/pico-series.html)

## Prerequisites

Install the ARM toolchain: [Install ARM Cross-Compiler](https://www.lf-lang.org/embedded-lab/Non-Nix.html#install-cmake-standard-c-library-arm-cross-compiler)

Install picotool: [Install Picotool](https://www.lf-lang.org/embedded-lab/Non-Nix.html#install-picotool)

## Setup

Clone and initialize submodules:

```bash
git clone https://github.com/lf-lang/ulf-pico-template.git my-project
cd my-project
git submodule update --init --recursive
```

## Building

Configure and build:

```bash
cmake -Bbuild
cmake --build build -j $(nproc)
```

This creates `build/Blink.elf`.

## Flashing

Put the Pico into BOOTSEL mode (hold BOOTSEL while connecting USB), then:

```bash
picotool load -x build/Blink.elf
```

## Changing the Application

Edit `LF_MAIN` in `CMakeLists.txt` or via command line:

```bash
cmake -Bbuild -DLF_MAIN=Timer
cmake --build build -j $(nproc)
```

## Log Level

```bash
cmake -Bbuild -DLOG_LEVEL=LF_LOG_LEVEL_DEBUG
```

## Board Variants

For Pico 2 (RP2350):

```bash
export PICO_BOARD=pico2
cmake -Bbuild
```

For Pico W:

```bash
export PICO_BOARD=pico_w
cmake -Bbuild
```

## Cleaning

```bash
rm -rf src-gen build
```

## Network Channels

| Channel | Mode | Description |
|---------|------|-------------|
| UART | Polled | Serial point-to-point |

