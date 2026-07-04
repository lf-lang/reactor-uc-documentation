# Zephyr

- **Template**: [ulf-zephyr-template](https://github.com/lf-lang/ulf-zephyr-template)
- **Zephyr Documentation**: [docs.zephyrproject.org](https://docs.zephyrproject.org/4.1.0/)
- **Supported Boards**: [Zephyr Board Index](https://docs.zephyrproject.org/4.1.0/boards/index.html)

## Setup

1. Install Zephyr dependencies: [Install Dependencies](https://docs.zephyrproject.org/4.1.0/develop/getting_started/index.html#install-dependencies)

2. Install the Zephyr SDK: [Install the Zephyr SDK](https://docs.zephyrproject.org/4.1.0/develop/getting_started/index.html#install-the-zephyr-sdk)

3. Create and activate a Python virtual environment:

```bash
python3 -m venv ./venv
source ./venv/bin/activate
```

4. Install west and fetch Zephyr sources:

```bash
pip install west
west update
pip install -r deps/zephyr/scripts/requirements.txt
west zephyr-export
```

## Building

Build and run using the `native_posix` target (emulation):

```bash
west build -t run
```

Build for a specific board:

```bash
west build -b qemu_cortex_m3 -p always -t run
west build -b adafruit_feather -p always
```

The `-p always` flag cleans the build directory when changing target boards.

## Changing the Application

Set the `LF_MAIN` CMake variable in `CMakeLists.txt` or via command line:

```bash
west build -b adafruit_feather -p always -- -DLF_MAIN=Blinky
```

## Log Level

```bash
west build -t run -p always -- -DLOG_LEVEL=LF_LOG_LEVEL_DEBUG
```

## Flashing

```bash
west flash
```

## Cleaning

```bash
west clean
```

## Network Channels

| Channel | Description |
|---------|-------------|
| TCP/IP | TCP sockets over Ethernet/WiFi |
