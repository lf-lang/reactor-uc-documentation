# RIOT

- **Template**: [ulf-riot-template](https://github.com/lf-lang/ulf-riot-template)
- **RIOT Documentation**: [doc.riot-os.org](https://doc.riot-os.org/)
- **Supported Boards**: [RIOT Board Support](https://www.riot-os.org/boards.html)

## Prerequisites

In addition to the common prerequisites:

- **make** version 4.0+ (on macOS, install via `brew install make` and use `gmake`)
- **ARM cross-compiler** for ARM-based boards:

```bash
# Debian/Ubuntu
sudo apt install gcc-arm-none-eabi

# Or use Nix
nix develop
```

## Setup

Clone and initialize submodules:

```bash
git clone https://github.com/lf-lang/ulf-riot-template.git my-project
cd my-project
git submodule update --init --recursive
```

## Building

Configure `LF_MAIN` and `BOARD` in the Makefile, then:

```bash
make all
```

Or override on command line:

```bash
make LF_MAIN=HelloWorld BOARD=nucleo-f446re all
```

For native Linux simulation:

```bash
make BOARD=native all
```

## Flashing

```bash
make flash
```

Or with parameters:

```bash
make LF_MAIN=HelloWorld BOARD=nucleo-f446re flash
```

## Terminal

Open a serial terminal:

```bash
make term
```

## Log Level

Edit the Makefile:

```makefile
CFLAGS += -DLF_LOG_LEVEL_ALL=LF_LOG_LEVEL_DEBUG
```

## Network Channels

| Channel | Mode | Description |
|---------|------|-------------|
| TCP/IP | Async | TCP sockets via RIOT's GNRC stack |
| CoAP/UDP | Async | CoAP over UDP for IoT networks |
| UART | Polled, Async | Serial point-to-point |

## macOS Notes

Use `gmake` instead of `make` (macOS ships with make 3.81, RIOT requires 4.0+):

```bash
brew install make
gmake all
```
