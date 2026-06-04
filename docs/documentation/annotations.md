# Annotations

Annotations in micro-LF allow you to configure reactor components, specify platform details, and set up network communication. They refine system behavior and enable runtime optimizations across different hardware platforms.

## Build Configuration

Configure how the reactor system is compiled and built.

- **`@build_type("<type>")`**
    
    Specifies the build type for compilation optimization and debug symbols. This is only supported for the `Native` platform. 
    
    **Valid values:**

    - `"DEBUG"`: Include debug symbols and disable optimizations
    - `"RELEASE"`: Enable optimizations and omit debug symbols

## Runtime Configuration

Configure global runtime behavior and system-wide options.

- **`@logging("<level>")`**
    
    Sets the logging verbosity level for the runtime system.
    
    **Valid values:**

    - `"ERROR"`: Only log errors
    - `"WARN"`: Log warnings and errors
    - `"INFO"`: Log general information
    - `"DEBUG"`: Log detailed debug information

- **`@timeout(<time_value>)`**
    
    Specifies a global timeout for reactor execution. The program will shutdown after this amount of logical time.
    
    **Parameters:**

    - `<time_value>`: Logical time duration in appropriate time unit (e.g., `MSEC(5000)`, `SEC(5)`)

- **`@fast(<boolean>)`**
    
    When enabled, the reactor system runs as fast as possible without waiting for physical time to advance. Useful for simulation and testing.
    
    **Parameters:**

    - `<boolean>`: `true` to enable fast execution, `false` for real-time execution

- **`@keepalive(<boolean>)`**
    
    Controls whether the reactor keeps running when there are no more scheduled events. When disabled, the reactor may shut down prematurely.
    
    **Parameters:**

    - `<boolean>`: `true` to keep the reactor alive, `false` to allow shutdown

- **`@clock_sync("<mode>")`**
    
    Globally enables or disables clock synchronization across a federation.
    
    **Valid values:**

    - `"on"`: Enable clock synchronization
    - `"off"`: Disable clock synchronization

## Reactor Components

Annotations for configuring individual reactor components and connections.

- **`@max_pending_event(<number>)`**
    
    Specifies the maximum number of elements that can be queued in a logical action's buffer. This controls memory usage and prevents unbounded growth of pending events.
    
    **Parameters:**
    - `<number>`: Maximum queue size (positive integer)

- **`@buffer(<number>)`**
    
    Specifies the maximum number of elements that can be in transit across a delayed connection. Useful for controlling backpressure in pipelines.
    
    **Parameters:**

    - `<number>`: Maximum buffer size (positive integer)

## Platform Configuration

Specify which platforms a federate should be compiled for in multi-platform federations.

- **`@platform("<platform_name>")`**
    
    Generic platform annotation for specifying target platforms.
    
    **Valid platforms:**
    - `"NATIVE"`: Native/Linux platform
    - `"PICO"`: Raspberry Pi Pico
    - `"ZEPHYR"`: Zephyr RTOS
    - `"RIOT"`: RIOT OS
    - `"FLEXPRET"`: FlexPRET
    - `"PATMOS"`: Patmos hardware
    - `"ESP-IDF"`: ESP-IDF framework
    - `"FREERTOS"`: FreeRTOS


!!! warning "Deprecation Notice"
    These annotations may be deprecated in a future release.

- **`@platform_riot()`** - Compile for RIOT OS
- **`@platform_zephyr()`** - Compile for Zephyr RTOS
- **`@platform_patmos()`** - Compile for Patmos hardware
- **`@platform_native()`** - Compile for native/Linux platform

## Network Interfaces

Define physical network interfaces on federates. These annotations are translated by the code generator into **network channels** (e.g., TCP/IP sockets, UART links). Use the `@link` annotation on LF connections to specify which network channel should carry the data.

**Workflow:**

1. Define interfaces on each federate using `@interface_*` annotations
2. Use `@link` on LF connections to bind them to specific network channels
3. Multiple LF connections can be multiplexed over a single network channel

For practical examples and usage patterns, see [Federated Execution - Configuring Network Interfaces](../design/federated.md#configuring-network-interfaces).

- **`@interface_tcp(name="string", address="127.0.0.1:4200")`**
    
    TCP/IP network interface for federate communication.
    
    **Parameters:**
    - `name`: Interface identifier
    - `address`: Host and port (format: "host:port")

- **`@interface_uart(name="uart0", uart_device=0, baud_rate=115200, data_bits=8, parity="", stop_bits=1, async=false)`**
    
    UART/serial interface for embedded systems communication.
    
    **Parameters:**

    - `name`: Interface identifier
    - `uart_device`: Device number
    - `baud_rate`: Communication speed (e.g., 115200)
    - `data_bits`: Bits per character (typically 8)
    - `parity`: Parity mode (e.g., "", "even", "odd")
    - `stop_bits`: Stop bits (typically 1 or 2)
    - `async`: Whether to use asynchronous mode

- **`@interface_coap(name="coap0", address="10.0.0.1")`**
    
    CoAP (Constrained Application Protocol) interface for IoT communication.
    
    **Parameters:**

    - `name`: Interface identifier
    - `address`: Server address

- **`@interface_s4noc(core=0)`**
    
    S4NoC network-on-chip interface for tightly-coupled embedded systems.
    
    **Parameters:**

    - `core`: Core identifier

- **`@interface_custom(name="c1", args="blabla", include="my_network.h")`**
    
    Custom network interface for user-defined communication protocols.
    
    **Parameters:**

    - `name`: Interface identifier
    - `args`: Custom arguments passed to the interface
    - `include`: Header file containing the interface implementation

## Network Configuration

Configure how LF connections are mapped to network channels. These annotations work together with [Network Interfaces](#network-interfaces) to establish federated communication.

For a comprehensive overview of federated execution, see [Federated Execution](../design/federated.md).

- **`@link(left="<interface>", right="<interface>", ...)`**

    Binds an LF connection (logical connection between reactor ports) to a specific network channel. This annotation tells the code generator that the following LF connection should be transmitted over the specified network interfaces (defined via `@interface_*` annotations).

    Multiple LF connections can share the same network channel by using the same `@link` configuration - they will be multiplexed over a single physical connection.

    **Parameters:**

    - `left`: Name of the interface on the sending (upstream) federate
    - `right`: Name of the interface on the receiving (downstream) federate
    - `server_side` (optional): Which side acts as server (`"left"` or `"right"`)
    - `server_port` (optional): Port number for the server

    **Example:**
    ```lf
    federated reactor {
      @interface_tcp(name="if1", address="127.0.0.1")
      r1 = new Src()

      @interface_tcp(name="if1", address="127.0.0.1")
      r2 = new Dst()

      // This LF connection will use the TCP network channel
      @link(left="if1", right="if1", server_side="right", server_port=1042)
      r1.out -> r2.in
    }
    ```

    For more details, see [Federated Execution - Configuring Network Interfaces](../design/federated.md#configuring-network-interfaces).

- **`@maxwait(<time_value>)`**

    Controls how long a federate waits for messages from neighboring federates before advancing to a new tag. This is checked during tag acquisition: if an input connection hasn't received a message for the requested tag (`last_known_tag < next_tag`), the scheduler waits up to `maxwait` before proceeding.

    This is distinct from STP (Safe-To-Process) violations, which occur when a message arrives for a tag that has already been processed.

    Can be applied to:

    - **Federate instantiations**: Sets the baseline maxwait for all incoming connections
    - **Individual connections**: Overrides the baseline for specific connections

    **Parameters:**

    - `<time_value>`: Duration (e.g., `100 ms`, `1 sec`) or special values:
        - `0`: No waiting; advance immediately regardless of unresolved inputs
        - `forever`: Wait indefinitely until a message arrives for the tag

    **Example:**
    ```lf
    federated reactor {
      r1 = new Src()
      @maxwait(0)        // Baseline: no waiting
      r2 = new Dst()
      @maxwait(forever)  // Override: wait indefinitely for this connection
      r1.out -> r2.in
    }
    ```

    For detailed usage, see [Federated Execution - Tag Acquisition and @maxwait](../design/federated.md#tag-acquisition-and-maxwait).

- **`@joining_policy(policy="<policy>")`**
    
    Controls how federates synchronize when joining a federation.
    
    **Policies:**
    - `"TIMER_ALIGNED"`: Synchronize to a common time reference
    - `"IMMEDIATELY"`: Begin execution immediately

## Clock Synchronization

Configure distributed clock synchronization across federated systems.

- **`@clock_sync(grandmaster=true, period=3500000000, max_adj=512000, kp=0.5, ki=0.1)`**
    
    Enable and configure clock synchronization using a PTP-like protocol for precise time alignment across federates.
    
    **Parameters:**
    
    - `grandmaster`: Whether this federate is the time reference (true/false)
    - `period`: Synchronization period in nanoseconds
    - `max_adj`: Maximum clock adjustment per sync cycle (nanoseconds)
    - `kp`: Proportional controller gain
    - `ki`: Integral controller gain

## Legacy Annotations (Not Supported)

The following annotations are from earlier Lingua Franca versions and are not currently supported in micro-LF:

- `@label()`
- `@sparse()`
- `@icon("value")`
- `@side("value")`
- `@layout(option="string", value="any")` — e.g., `@layout(option="port.side", value="WEST")`
- `@enclave(each=boolean)`
- `@property(name="<property_name>", tactic="<induction|bmc>", spec="<SMTL_spec>", CT=0, expect=true)` - SMTL is the safety fragment of Metric Temporal Logic (MTL)
- `@_c_body`
- `@_tpoLevel`
- `@_networkReactor`
