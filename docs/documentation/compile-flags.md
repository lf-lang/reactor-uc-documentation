# Compile Flags

The uLF runtime provides compile-time flags to configure platform selection, feature enabling, logging, memory allocation, and networking. These flags are set via CMake options or compiler definitions.

## Platform Selection

Select the target platform via CMake:

```bash
cmake -DPLATFORM=<platform> ..
```

| Value | Description |
|-------|-------------|
| `POSIX` | Linux/macOS (default) |
| `ZEPHYR` | Zephyr RTOS |
| `RIOT` | RIOT OS |
| `PICO` | Raspberry Pi Pico (RP2040/RP2350) |
| `FREERTOS` | FreeRTOS |
| `ESP_IDF` | ESP-IDF framework |
| `PATMOS` | Patmos processor |
| `FLEXPRET` | FlexPRET processor |

This sets the `PLATFORM_<NAME>` compile definition (e.g., `PLATFORM_POSIX`).

## Federation

Enable federated execution and network channels:

```bash
cmake -DFEDERATED=ON -DNETWORK_CHANNEL_TCP_POSIX=ON ..
```

| Flag | Default | Description |
|------|---------|-------------|
| `FEDERATED` | `OFF` | Enable federated execution support |
| `NETWORK_CHANNEL_TCP_POSIX` | `OFF` | Enable TCP/IP network channel |

## Logging

### Log Levels

| Level | Value | Description |
|-------|-------|-------------|
| `LF_LOG_LEVEL_OFF` | 0 | Logging disabled |
| `LF_LOG_LEVEL_ERROR` | 1 | Errors only |
| `LF_LOG_LEVEL_WARN` | 2 | Warnings and errors |
| `LF_LOG_LEVEL_INFO` | 3 | Info, warnings, errors |
| `LF_LOG_LEVEL_LOG` | 4 | All log messages |
| `LF_LOG_LEVEL_DEBUG` | 5 | Debug messages |

### Global Configuration

```cmake
# Set global log level
target_compile_definitions(reactor-uc PUBLIC LF_LOG_LEVEL_ALL=LF_LOG_LEVEL_DEBUG)

# Disable all logging
target_compile_definitions(reactor-uc PUBLIC LF_LOG_DISABLE)

# Disable colored output
target_compile_definitions(reactor-uc PUBLIC LF_COLORIZE_LOGS=0)

# Disable timestamps
target_compile_definitions(reactor-uc PUBLIC LF_TIMESTAMP_LOGS=0)
```

### Per-Module Configuration

Override log level for specific modules:

| Flag | Module |
|------|--------|
| `LF_LOG_LEVEL_ENV` | Environment |
| `LF_LOG_LEVEL_SCHED` | Scheduler |
| `LF_LOG_LEVEL_QUEUE` | Event/reaction queues |
| `LF_LOG_LEVEL_FED` | Federated execution |
| `LF_LOG_LEVEL_TRIG` | Triggers |
| `LF_LOG_LEVEL_PLATFORM` | Platform layer |
| `LF_LOG_LEVEL_CONN` | Connections |
| `LF_LOG_LEVEL_NET` | Network channels |
| `LF_LOG_LEVEL_CLOCK_SYNC` | Clock synchronization |

Example:

```cmake
target_compile_definitions(reactor-uc PUBLIC
  LF_LOG_LEVEL_ALL=LF_LOG_LEVEL_WARN
  LF_LOG_LEVEL_NET=LF_LOG_LEVEL_DEBUG
)
```

## Memory Configuration

### Buffer Sizes

| Flag | Default | Description |
|------|---------|-------------|
| `SERIALIZATION_MAX_PAYLOAD_SIZE` | 832 | Max federated message payload (bytes) |
| `MEM_ALIGNMENT` | 32 | Memory alignment for structs (bytes) |
| `REACTOR_NAME_MAX_LEN` | 128 | Maximum reactor name length |

### Network Channel Buffers

| Flag | Default | Platform |
|------|---------|----------|
| `TCP_IP_CHANNEL_BUFFERSIZE` | 1024 | POSIX |
| `TCP_IP_CHANNEL_NUM_RETRIES` | 255 | POSIX |
| `UART_CHANNEL_BUFFERSIZE` | 1024 | Pico, RIOT |
| `COAP_UDP_IP_CHANNEL_BUFFERSIZE` | 1024 | RIOT |
| `S4NOC_CHANNEL_BUFFERSIZE` | 1024 | Patmos |
| `S4NOC_CORE_COUNT` | 4 | Patmos |

## Clock Synchronization

| Flag | Default | Description |
|------|---------|-------------|
| `CLOCK_SYNC_DEFAULT_PERIOD` | `SEC(1)` | Sync message period |
| `CLOCK_SYNC_DEFAULT_KP` | 0.7 | Proportional gain |
| `CLOCK_SYNC_DEFAULT_KI` | 0.3 | Integral gain |
| `CLOCK_SYNC_DEFAULT_MAX_ADJ` | 200000000 | Max adjustment (ppb) |
| `CLOCK_SYNC_INITAL_STEP_THRESHOLD` | `MSEC(100)` | Initial step threshold |

## Network Timing

| Flag | Default | Description |
|------|---------|-------------|
| `TCP_IP_CHANNEL_EXPECTED_CONNECT_DURATION` | `MSEC(10)` | TCP connection time |
| `TCP_IP_CHANNEL_WORKER_THREAD_MAIN_LOOP_SLEEP` | `MSEC(100)` | Worker thread sleep |
| `UART_CHANNEL_EXPECTED_CONNECT_DURATION` | `MSEC(0)` | UART connection time |
| `COAP_UDP_IP_CHANNEL_EXPECTED_CONNECT_DURATION` | `MSEC(10)` | CoAP connection time |

## Testing and Debugging

CMake options for development:

```bash
cmake -DBUILD_TESTS=ON -DASAN=ON ..
```

| Flag | Default | Description |
|------|---------|-------------|
| `BUILD_TESTS` | `OFF` | Build all tests |
| `BUILD_UNIT_TESTS` | `OFF` | Build unit tests only |
| `BUILD_LF_TESTS` | `OFF` | Build LF integration tests |
| `ASAN` | `OFF` | Enable AddressSanitizer |

## Time Unit Macros

Convenience macros for expressing time intervals (defined in `tag.h`):

| Macro | Converts to Nanoseconds |
|-------|------------------------|
| `NSEC(t)` | t × 1 |
| `USEC(t)` | t × 1,000 |
| `MSEC(t)` | t × 1,000,000 |
| `SEC(t)` | t × 1,000,000,000 |
| `MINS(t)` | t × 60,000,000,000 |
| `FOREVER` | Maximum value |

## Example Configuration

```cmake
# CMakeLists.txt for a federated Zephyr project
cmake_minimum_required(VERSION 3.20)

find_package(Zephyr REQUIRED)
project(my_reactor_app)

# uLF runtime configuration
set(PLATFORM "ZEPHYR")
set(FEDERATED ON)
set(NETWORK_CHANNEL_TCP_POSIX ON)

add_subdirectory(${REACTOR_UC_PATH} reactor-uc)

target_compile_definitions(app PRIVATE
  LF_LOG_LEVEL_ALL=LF_LOG_LEVEL_WARN
  LF_LOG_LEVEL_FED=LF_LOG_LEVEL_DEBUG
  SERIALIZATION_MAX_PAYLOAD_SIZE=2048
)

target_link_libraries(app PRIVATE reactor-uc)
```
