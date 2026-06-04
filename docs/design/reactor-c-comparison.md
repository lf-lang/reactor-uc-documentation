# uLF vs reactor-c

Both runtimes implement the [Lingua Franca](https://lf-lang.org) reactor model in C, but they diverge sharply in memory model, toolchain integration, and target environment. **reactor-c** is the reference implementation for desktop and server workloads; **uLF** is purpose-built for resource-constrained embedded systems.

## At a Glance

| Feature | uLF | reactor-c |
|---------|-----------|-----------|
| Memory model | Static / stack-only | Heap-allocated, reference-counted |
| Embedded RTOS support | 8+ platforms, first-class | Limited |
| Code generation | Typed macro layer | Raw struct and function calls |
| Runtime configuration | Annotations | `target { }` property block |
| Federation topology | Peer-to-peer | Central RTI process |
| Federation wire format | Protocol Buffers (nanopb) | Custom binary protocol |
| Per-module logging | Yes (9 modules) | No, global level only |
| Runtime plug-in API | Vtable structs | Direct function calls |
| Multi-threaded schedulers | No | Yes (GEDF_NP, NP, adaptive) |
| Dynamic payload sizes | No (fixed buffers) | Yes (heap tokens) |
| Modal models | No | Yes |
| Tracing infrastructure | No | Yes |

## Memory Model: Static vs Heap

This is the most fundamental difference between the two runtimes.

**reactor-c** uses dynamically allocated, reference-counted `lf_token_t` objects for every port and action payload. A token wraps a heap-allocated value with a reference count; the runtime frees it when the count reaches zero. This enables dynamic-length messages and complex struct types with custom destructors and copy constructors, but it requires `malloc`/`free` and per-timestep garbage collection.

**uLF** allocates all runtime objects — reactors, ports, actions, connections, event queues — statically at compile time. Buffer sizes and array dimensions are encoded directly into the generated struct definitions by the `macros_internal.h` layer. No heap allocation occurs after `lf_start()`. This makes the uLF runtime safe for MCUs without a heap, with deterministic WCET requirements, or in safety-critical contexts where dynamic allocation is forbidden.

## Clean Code Generation via Macros

**reactor-c** emits raw C structs, explicit constructor calls, and untyped `void*` casts directly into generated files. The generated code is verbose and closely tied to internal runtime types.

**uLF** wraps every generated construct in typed macros from `macros_internal.h`, which encode the reactor's exact topology into named types at code-generation time:

```c
// Struct and constructor for a port
LF_DEFINE_OUTPUT_STRUCT(MyReactor, out, 1, int)
LF_DEFINE_OUTPUT_CTOR(MyReactor, out, 1)

// Struct and constructor for a reaction
LF_DEFINE_REACTION_STRUCT(MyReactor, r, 1)
LF_DEFINE_REACTION_CTOR(MyReactor, r, 0, NULL, NULL)

// Entry point wiring up the scheduler, queues, and main reactor
LF_ENTRY_POINT(MyReactor, /*NumEvents=*/16, /*NumReactions=*/4,
               /*Timeout=*/FOREVER, /*KeepAlive=*/false, /*Fast=*/false)
```

Reaction bodies use the `macros_api.h` surface — identical names to the LF source language, no raw casting:

```c
LF_DEFINE_REACTION_BODY(MyReactor, r) {
  LF_SCOPE_SELF(MyReactor);
  LF_SCOPE_PORT(MyReactor, out);

  lf_set(out, 42);
}
```

The `lf_set`, `lf_get`, `lf_is_present`, and `lf_schedule` macros dispatch through the port's vtable, keeping reaction bodies readable regardless of port type.

## Embedded Toolchain Integration

**reactor-c** uses a CMake-only build system designed around Linux and macOS hosts. Support for Zephyr and RP2040 exists but is not a primary concern.

**uLF** provides first-class integration into the native toolchain of each supported platform:

- **Zephyr** — `lfc` is registered as a `west` command. Running `west build` invokes code generation and compilation in a single step, fully integrated with Zephyr's board configuration and DTS.
- **RIOT** — `lfc` is hooked into the application `Makefile`. A plain `make all` invokes the code generator first, then the standard RIOT build pipeline.
- **Raspberry Pi Pico** — Generated CMake files import `pico-sdk` directly. Template repositories for each platform are available to clone and immediately build.
- **Other platforms** — The `Platform` abstraction is a vtable struct (`Platform_ctor` + overrides). Adding a new MCU means implementing one C struct; no changes to the runtime itself are required.

## Federated Execution: Topology and Wire Format

The federation model is where the two runtimes differ most structurally.

### reactor-c: Central RTI

reactor-c federations use a **central Runtime Infrastructure (RTI)** process:

- All federates open a TCP connection to the RTI at startup.
- The RTI coordinates tag advancement through `NET` (Next Event Tag), `LTC` (Latest Tag Confirmed), `TAG`, and `PTAG` message types.
- The RTI spawns one dedicated thread per federate for ongoing coordination.
- Messages use a **custom binary protocol** — raw `MSG_TYPE` byte framing, not a standard serialization format.
- Optional RTI-mediated authorization (`auth: true` target property).
- Payload data flows peer-to-peer, but every timing decision passes through the RTI.

### uLF: Peer-to-Peer with Protocol Buffers

uLF federations are **fully peer-to-peer** — no central broker:

- Federates connect directly to each other; there is no coordinator process.
- Messages are serialized with **Protocol Buffers via nanopb**:

```protobuf
message TaggedMessage {
  required Tag    tag     = 1;
  required int32  conn_id = 2;  // identifies which LF connection
  required bytes  payload = 3 [(nanopb).max_size = 832];
}
```

- A `FederatedConnectionBundle` multiplexes multiple LF connections over a single physical channel, reducing the number of open sockets.
- **Supported transports**: TCP/IP, UART, CoAP/UDP, S4NoC network-on-chip, custom.
- **Channel modes**: polled (safe for MCU scheduler loops) and async (interrupt-driven callbacks).
- **Transient federates**: a federate that crashes can re-join a live federation without restarting the whole system.
- **Built-in PTP-like clock synchronization**, configurable via `@clock_sync`.

## Logging Infrastructure

**reactor-c** provides a single global log level, set via the `logging` target property (`error`, `warning`, `info`, `log`, `debug`). There is no per-module granularity. A custom print handler can be registered via `lf_register_print_function()`.

**uLF** provides compile-time log levels per module:

| Module | Controls |
|--------|----------|
| `ENV` | Environment lifecycle |
| `SCHED` | Scheduler decisions |
| `QUEUE` | Event and reaction queues |
| `FED` | Federated coordination |
| `TRIG` | Trigger firing |
| `PLATFORM` | Platform HAL calls |
| `CONN` | Logical connections |
| `NET` | Network channels |
| `CLOCK_SYNC` | Clock synchronization |

Each module level can be set independently in a `CMakeLists.txt` or via compile flags:

```cmake
target_compile_definitions(app PRIVATE
  LF_LOG_LEVEL_SCHED=LF_LOG_LEVEL_DEBUG
  LF_LOG_LEVEL_NET=LF_LOG_LEVEL_WARN
)
```

Defining `LF_LOG_DISABLE` removes all logging macros at compile time, leaving zero overhead in production builds. Log output includes colorization and logical timestamps by default, both configurable.

## Runtime Abstractions: Vtable vs Direct Calls

**reactor-c** uses direct C function calls on a flat `environment_t` struct. The scheduler is embedded as `lf_scheduler_t*` and swapping scheduler policies (GEDF_NP, NP, adaptive) requires recompiling with a different `.c` file. There is no runtime polymorphism.

**uLF** exposes three clean vtable-based plug-in points:

```c
struct Platform {
  instant_t (*get_physical_time)(Platform*);
  lf_ret_t  (*wait_until)(Platform*, instant_t);
  lf_ret_t  (*wait_for)(Platform*, interval_t);
  void      (*notify)(Platform*);
};

struct Scheduler {
  lf_ret_t (*schedule_at)(Scheduler*, Event*);
  void     (*run)(Scheduler*);
  void     (*do_shutdown)(Scheduler*, tag_t);
  tag_t    (*current_tag)(Scheduler*);
  void     (*prepare_timestep)(Scheduler*, tag_t);
  lf_ret_t (*add_to_reaction_queue)(Scheduler*, Reaction*);
};

struct NetworkChannel {
  lf_ret_t (*open_connection)(NetworkChannel*);
  lf_ret_t (*send_blocking)(NetworkChannel*, const FederateMessage*);
  void     (*register_receive_callback)(NetworkChannel*, callback_fn, bundle);
  bool     (*is_connected)(NetworkChannel*);
  void     (*free)(NetworkChannel*);
};
```

Porting to a new MCU means implementing `Platform`; adding a new transport means implementing `NetworkChannel`. The rest of the runtime is untouched. This also makes unit testing straightforward — mock any vtable in isolation.

## Annotations Instead of Target Properties

**reactor-c** configures the entire runtime through a `target { }` block at the top of the `.lf` file:

```lf
target C {
  timeout: 5 sec,
  fast: true,
  logging: debug,
  workers: 4,
  cmake-include: ["extra.cmake"],
  protobufs: ["msg.proto"],
  auth: true,
  docker: true
}
```

This is a monolithic block — not composable, duplicated across federates, and mixing concerns (build system, runtime, security, deployment) in one place.

**uLF** replaces all target properties with regular LF annotations placed next to the component they configure:

```lf
// Runtime behaviour
@timeout(SEC(5))
@fast(true)
@keepalive(true)
@logging("DEBUG")

// Per-federate platform
@platform("ZEPHYR")
sensor = new Sensor()

// Network interfaces on each federate
@interface_tcp(name="eth0", address="192.168.1.10")
@interface_uart(name="uart0", baud_rate=115200)
controller = new Controller()

// Binding LF connections to channels
@link(left="eth0", right="eth0", server_side="right", server_port=4200)
sensor.out -> controller.in

// Per-connection timing
@maxwait(100 ms)
sensor.out -> controller.in
```

Annotations are composable, live next to the code they affect, and work identically for non-federated and federated programs. There is no `target` block at all.

## When to Use Which

### Use reactor-c when

- Targeting **Linux, macOS, or Windows** and want to exploit multiple CPU cores with GEDF or adaptive scheduling.
- Your messages are **dynamically sized** or require heap-allocated complex types with custom destructors.
- Running **large-scale federations** that benefit from a central RTI (uniform clock authority, RTI-level authorization, coordinated shutdown).
- You need the **full LF ecosystem**: Rust, Python, or TypeScript targets; modal models; the Epoch IDE; built-in tracing and profiling.
- A **mature, widely-deployed** codebase with extensive test coverage is the priority.

### Use uLF when

- Deploying on **bare-metal or RTOS** devices: Zephyr, RIOT, FreeRTOS, Pico SDK, ESP-IDF, Patmos, FlexPRET, or ADuCM355.
- **Static memory** is required — no heap, deterministic WCET, or safety-critical certification.
- Federated communication must run over **UART, CoAP, or other link-layer protocols** that a central RTI cannot reach.
- You want **native toolchain integration**: `west build`, `make all`, or pico-sdk CMake without custom wrapper scripts.
- **Readable generated code** and **granular per-module logging** matter for debugging on hardware with no OS debugger.
- The system must run **without a coordinator process** — autonomous nodes, offline operation, or air-gapped networks.
