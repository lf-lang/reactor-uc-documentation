# Annotations

Annotations in reactor-uc allow you to configure reactor components, specify platform details, and set up network communication. They refine system behavior and enable runtime optimizations across different hardware platforms.

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

These annotations specify which platforms a federate should be compiled for in multi-platform federations.

- **`@platform_riot()`** - Compile for RIOT OS
- **`@platform_zephyr()`** - Compile for Zephyr RTOS
- **`@platform_patmos()`** - Compile for Patmos hardware
- **`@platform_native()`** - Compile for native/Linux platform

## Network Interfaces

Configure communication channels between federates using various network protocols.

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

Configure how federates communicate across network interfaces.

- **`@link(left="tcp0", right="tcp1")`**
    
    Specifies which network interfaces to use for transmitting values between federates. The `left` and `right` refer to previously defined interface names.

- **`@maxwait(time)`**
    
    Maximum time a federate should wait for a value from a remote federate on a network channel. Helps prevent indefinite blocking in case of communication failures.

- **`@joining_policy(policy="<policy>")`**
    
    Controls how federates synchronize when joining a federation.
    
    **Policies:**

    * `"TIMER_ALIGNED"`: Synchronize to a common time reference
    * `"IMMEDIATELY"`: Begin execution immediately

## Clock Synchronization

Configure distributed clock synchronization across federated systems.

- **`@clock_sync(grandmaster=true, period=3500000000, max_adj=512000, kp=0.5, ki=0.1)`**
    
    Enable and configure clock synchronization using a PTP-like protocol.
    
    **Parameters:**
    
    - `grandmaster`: Whether this federate is the time reference (true/false)
    - `period`: Synchronization period in nanoseconds
    - `max_adj`: Maximum clock adjustment per sync cycle (nanoseconds)
    - `kp`: Proportional controller gain
    - `ki`: Integral controller gain

## Legacy Annotations (Not Supported)

The following annotations are from earlier Lingua Franca versions and are not currently supported in reactor-uc:

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
