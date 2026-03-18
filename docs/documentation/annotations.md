# Annotations

In reactor-uc different languages components can be annotated, in order to refine the behavior, configure the system, and enabling runtime components.

## Reactor Components

- `@max_pending_event(<number>)`
    Tells how many elements should be able to be stored inside a logical actions.  

- `@buffer(<number>)`
    Tells how many elements at maximum should be able in transit across a delayed connection.

## Platform Annotations

These annotations are used for multi-platform federations to correclty compile the source code with the correct platform.

- `@platform_riot()`
- `@platform_zephyr()`
- `@platform_patmos()`
- `@platform_native()`

## Network Interfaces

- `@interface_tcp(name="string", address="127.0.0.1:4200")`
- `@interface_uart(name="uart0", uart_device=0, baud_rate=115200, data_bits=8, parity="", stop_bits=1, async=false)`
- `@interface_coap(name="coap0", address="10.0.0.1")`
- `@interface_s4noc(core=0)`
- `@interface_custom(name="c1", args="blabla", include="my_network.h")`

## Network Configuration

- `@link(left="tcp0", right="tcp1")`
    The link property tells the code-generator which network channels should be used to transmit values. Here the `left` and `right` side refer to the names of the interfaces previosuly defines.
- `@maxwait(time)`
    The maxwait is a time value, defined on a network channel, and tells the federate how much longer, it should wait for a value from this particular federate.
- `joining_policy(policy="<policy>")`
    The two possible values are "TIMER_ALIGNED" and "IMMEDIATELY".

## Clock Synchronisation

- `@clock_sync(grandmaster=true, period=3500000000, max_adj=512000, kp=0.5, ki=0.1)`

## Not Supported Legacy Annotations

- `@label()`
- `@sparse()`
- `@icon("value")`
- `@side("value")`
- `@layout(option="string", value="any") e.g. @layout(option="port.side", value="WEST")`
- `@enclave(each=boolean)`
- `@property(name="<property_name>", tactic="<induction|bmc>", spec="<SMTL_spec>", CT=0, expect=true)`
    SMTL is the safety fragment of Metric Temporal Logic (MTL).
- `@_c_body`
- `@_tpoLevel`
- `@_networkReactor`
