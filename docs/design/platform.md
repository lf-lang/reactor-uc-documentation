# Platform Abstraction

The uLF runtime runs on diverse hardware and operating systems through a **platform abstraction layer**. This page describes the interfaces that platforms must implement and the assumptions the runtime makes about their behavior.

## The Platform Interface

Every platform must implement a small set of timing and synchronization primitives:

```c
struct Platform {
  // Time
  instant_t (*get_physical_time)(Platform* self);

  // Waiting
  lf_ret_t (*wait_until)(Platform* self, instant_t wakeup_time);
  lf_ret_t (*wait_for)(Platform* self, interval_t duration);
  lf_ret_t (*wait_until_interruptible)(Platform* self, instant_t wakeup_time);
  void (*notify)(Platform* self);
};
```

### Time Functions

**`get_physical_time`**: Returns the current physical time in nanoseconds. The epoch (time zero) is typically system boot or program start—consistency within a run matters more than absolute time.

```c
instant_t Platform_get_physical_time(Platform* self);
```

**Assumptions**:

- Must be monotonically increasing (never goes backward)
- Resolution should be microsecond or better for most applications
- Called frequently—should be fast (no system calls if possible)

### Wait Functions

The scheduler uses wait functions to sleep until the next event. There are two modes:

**Blocking wait** (`wait_until`, `wait_for`): Sleep until the specified time. Cannot be interrupted early.

```c
lf_ret_t Platform_wait_until(Platform* self, instant_t wakeup_time);
lf_ret_t Platform_wait_for(Platform* self, interval_t duration);
```

**Interruptible wait** (`wait_until_interruptible`): Sleep until the specified time, but can be woken early by `notify()`. Essential for handling async events.

```c
lf_ret_t Platform_wait_until_interruptible(Platform* self, instant_t wakeup_time);
void Platform_notify(Platform* self);
```

**Return values**:

- `LF_OK`: Woke up at or after the requested time
- `LF_SLEEP_INTERRUPTED`: Woke up early due to `notify()`
- `LF_ERR`: Platform error

### Blocking vs Non-Blocking Behavior

The runtime makes specific assumptions about blocking behavior:

| Function | Blocks? | Can be interrupted? |
|----------|---------|---------------------|
| `get_physical_time` | No | N/A |
| `wait_until` | Yes | No |
| `wait_for` | Yes | No |
| `wait_until_interruptible` | Yes | Yes, by `notify()` |
| `notify` | No | N/A |

**Critical**: `notify()` must be safe to call from any context—interrupt handlers, other threads, or signal handlers. It must not block or allocate memory.

### When Interruptible Waits Matter

Interruptible waits are required when:

- **Physical actions** can arrive asynchronously (interrupts, callbacks)
- **Federated execution** receives network messages
- **Multiple threads** interact with the scheduler

If your application has none of these, the blocking `wait_until` suffices and `wait_until_interruptible` can simply delegate to it.

## Mutex Operations

The uLF runtime uses mutexes to protect shared state from concurrent access:

```c
MUTEX_T mutex;

MUTEX_LOCK(mutex);
// ... critical section ...
MUTEX_UNLOCK(mutex);
```

**Assumptions**:

- `MUTEX_LOCK` blocks until the mutex is acquired
- `MUTEX_UNLOCK` releases the mutex immediately
- Mutexes are not recursive (locking twice from the same context is undefined)
- Must work correctly when called from interrupt context (or use interrupt disabling)

### Implementation Strategies

**RTOS environments**: Use the OS mutex primitives (e.g., `pthread_mutex`, `k_mutex`, `mutex_t`).

**Bare metal / single-core**: Disable interrupts instead of using mutexes:

```c
#define MUTEX_T uint32_t
#define MUTEX_LOCK(m) do { m = __get_PRIMASK(); __disable_irq(); } while(0)
#define MUTEX_UNLOCK(m) __set_PRIMASK(m)
```

## Network Channel Interface

For federated execution, platforms must provide **network channels**—abstractions over the underlying transport:

```c
struct NetworkChannel {
  NetworkChannelType type;

  // Lifecycle
  lf_ret_t (*open)(NetworkChannel* self);
  void (*close)(NetworkChannel* self);

  // Communication
  lf_ret_t (*send)(NetworkChannel* self, const FederatedMessage* msg);
  lf_ret_t (*recv)(NetworkChannel* self, FederatedMessage* msg);

  // Status
  bool (*is_connected)(NetworkChannel* self);
};
```

### Channel Types

| Type | Description |
|------|-------------|
| `TCP_IP` | TCP sockets over Ethernet/WiFi |
| `UART` | Serial point-to-point communication |
| `COAP_UDP` | CoAP over UDP for IoT networks |
| Custom | Platform-specific transports |

### Blocking Behavior

Network channel operations have specific blocking semantics:

| Function | Blocks? | Notes |
|----------|---------|-------|
| `open` | May block | Connection establishment |
| `close` | No | Should return immediately |
| `send` | May block | Until message is queued/sent |
| `recv` | Configurable | See modes below |
| `is_connected` | No | Status check only |

### Polled vs Async Mode

Network channels operate in one of two modes:

**Polled mode**: The scheduler explicitly calls `recv()` to check for messages. The `recv()` function should be non-blocking or have a short timeout.

```c
// In scheduler's acquire_tag loop
while (!can_advance(tag)) {
  if (channel->recv(&msg) == LF_OK) {
    process_message(&msg);
  }
}
```

**Async mode**: Messages arrive via callbacks, typically from a network stack thread or interrupt. The callback queues the message and calls `platform->notify()` to wake the scheduler.

```c
// Registered with network stack
void on_message_received(FederatedMessage* msg) {
  enqueue_incoming_message(msg);
  platform->notify();  // Wake scheduler
}
```

The mode depends on platform capabilities and application requirements.

### Message Serialization

Network channels transport `FederatedMessage` structures, serialized using Protocol Buffers (nanopb):

```protobuf
message TaggedMessage {
  required Tag tag = 1;
  required int32 conn_id = 2;
  required bytes payload = 3;
}
```

Platforms may need to implement custom serialization hooks for complex payload types.

## Logging

Platforms provide a printing function for logging:

```c
void lf_print(const char* fmt, ...);
```

This is used by the logging macros:

```c
LF_DEBUG("Processing tag (%lld, %d)", tag.time, tag.microstep);
LF_INFO("Reactor initialized");
LF_WARN("Pool nearly exhausted");
LF_ERR("Failed to schedule event");
```

**Assumptions**:

- Printf-style format strings
- Should not block for extended periods
- May be called from interrupt context (platform-dependent)

## Porting Checklist

To add support for a new platform, implement:

1. **`Platform` struct** with all function pointers
2. **`MUTEX_T`** type and `MUTEX_LOCK`/`MUTEX_UNLOCK` macros
3. **`lf_print`** function for logging
4. **Network channels** (if federated execution is needed)

For detailed platform-specific information, see the [Platforms](../platforms/zephyr/index.md) section, which covers:

- Template repositories for each platform
- Platform-specific annotations and configuration
- Supported network channels per platform
- Build system integration
