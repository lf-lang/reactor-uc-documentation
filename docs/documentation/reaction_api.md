# Reaction API

The Reaction API provides functions and macros for use within reaction bodies, deadline violation handlers, and STP (Safe to Process) violation handlers. A pointer to the `Environment` is automatically available as `env` within reaction scope, enabling access to the environment API. Furthermore points to all effects, oberservers and sources are also made available.

```lf
reaction(t) {=
  instant_t now = env->get_logical_time(env);
=}
```

## Time Query Functions

Query the current logical and physical time within the reactor system.

- **`env->get_logical_time(env)`**

Returns the current logical time of the reactor system.

**Returns:** `instant_t` — Current logical time in nanoseconds

**Example:**
```c
instant_t now = env->get_logical_time(env);
```

- **`env->get_elapsed_logical_time(env)`**

Returns the elapsed logical time since the program started.

**Returns:** `instant_t` — Elapsed logical time in nanoseconds

- **`env->get_physical_time(env)`**

Returns the current physical (wall-clock) time.

**Returns:** `instant_t` — Current physical time in nanoseconds

- **`env->get_elapsed_physical_time(env)`**

Returns the elapsed physical time since the program started.

**Returns:** `instant_t` — Elapsed physical time in nanoseconds

- **`env->get_lag(env)`**

Returns the difference between logical and physical time (lag). A positive value indicates the system is keeping up with real-time.

**Returns:** `interval_t` — Lag in nanoseconds

## Synchronization and Waiting

- **`env->wait_for(env, duration)`**

Blocks the current reaction until the specified duration has elapsed.

**Parameters:**
- `duration`: `interval_t` — Duration to wait in nanoseconds

## Critical Sections

Protect shared resources in concurrent environments.

- **`env->enter_critical_section(env)`**

Enters a critical section. No other reactions will execute until the critical section is left.

- **`env->leave_critical_section(env)`**

Leaves the current critical section, allowing other reactions to execute.

**Example:**
```c
env->enter_critical_section(env);
// Protected code here
shared_resource++;
env->leave_critical_section(env);
```

## Shutdown Control

- **`env->request_shutdown(env)`**

Requests that the reactor system shut down gracefully after the current round of execution completes.

## Port Operations

Read and write values on reactor ports.

- **`lf_set(port, value)`**

Sets the value of an output port.

**Parameters:**
- `port`: Output port handle
- `value`: Value to set (type depends on port declaration)

**Example:**
```c
lf_set(output, 42);
```

- **`lf_set_array(port, length, array)`**

Sets an array value on an output port.

**Parameters:**
- `port`: Output port handle
- `length`: Number of elements in the array
- `array`: Pointer to the array data

**Example:**
```c
int values[] = {1, 2, 3};
lf_set_array(output, 3, values);
```

- **`lf_get(port)`**

Reads the current value from an input port.

**Returns:** Current port value (type depends on port declaration)

**Example:**
```c
int value = lf_get(input);
```

- **`lf_is_present(port)`**

Checks if a port has a value present at the current logical time.

**Returns:** `bool` — `true` if port is present, `false` otherwise

**Example:**
```c
if (lf_is_present(input)) {
  int value = lf_get(input);
}
```

## Action Scheduling

Schedule logical actions to occur at a future logical time.

- **`lf_schedule(action, delay)`**

Schedules an action to trigger after the specified delay.

**Parameters:**
- `action`: Logical action handle
- `delay`: `interval_t` — Delay in nanoseconds

**Example:**
```c
lf_schedule(my_action, MSEC(100)); // Schedule 100ms in the future
```

- **`lf_schedule_array(action, delay, length, array)`**

Schedules an action with array payload to trigger after the specified delay.

**Parameters:**
- `action`: Logical action handle
- `delay`: `interval_t` — Delay in nanoseconds
- `length`: Number of elements in the array
- `array`: Pointer to the array data

**Example:**
```c
int data[] = {10, 20, 30};
lf_schedule_array(my_action, MSEC(50), 3, data);
```

## Logging

Configure runtime logging to debug and monitor reactor execution. Verbosity is controlled via CMake compile definitions.

### Log Levels

- `LF_LOG_LEVEL_OFF` — Disable logging
- `LF_LOG_LEVEL_ERROR` — Only errors
- `LF_LOG_LEVEL_WARN` — Warnings and errors
- `LF_LOG_LEVEL_INFO` — General information
- `LF_LOG_LEVEL_DEBUG` — Detailed debug information

### Global Log Configuration

Set logging level for all modules:

```cmake
target_compile_definitions(reactor-uc PUBLIC LF_LOG_LEVEL_ALL=LF_LOG_LEVEL_DEBUG)
```

### Per-Module Log Configuration

Set logging level for specific modules:

```cmake
target_compile_definitions(reactor-uc PUBLIC LF_LOG_LEVEL_SCHED=LF_LOG_LEVEL_DEBUG)
```

### Available Modules

- `LF_LOG_LEVEL_ENV` — Environment
- `LF_LOG_LEVEL_SCHED` — Scheduler
- `LF_LOG_LEVEL_QUEUE` — Event queue
- `LF_LOG_LEVEL_FED` — Federated execution
- `LF_LOG_LEVEL_TRIG` — Triggers
- `LF_LOG_LEVEL_PLATFORM` — Platform layer
- `LF_LOG_LEVEL_CONN` — Connections
- `LF_LOG_LEVEL_NET` — Network

### Logging Features

**Disable all logging:**
```cmake
target_compile_definitions(reactor-uc PUBLIC LF_LOG_DISABLE)
```

**Disable log colorization:**
```cmake
target_compile_definitions(reactor-uc PUBLIC LF_COLORIZE_LOGS=0)
```

**Disable log timestamps:**
```cmake
target_compile_definitions(reactor-uc PUBLIC LF_TIMESTAMP_LOGS=0)
```

By default, logs are colorized and include timestamps.