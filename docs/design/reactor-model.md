# The Reactor Model

The reactor model is a component-based programming paradigm designed for concurrent and distributed systems. It provides **deterministic concurrency** by structuring programs as compositions of isolated reactive components.

## Reactors

A **reactor** is the fundamental unit of composition. Each reactor encapsulates:

- **Private state** that cannot be accessed by other reactors
- **Reactions** that define behavior in response to events
- **Ports** for communication with other reactors
- **Triggers** (timers, actions) for generating events

```c
struct Reactor {
  Reactor** children;       // Child reactors (hierarchy)
  Reaction** reactions;     // Reactions in this reactor
  Trigger** triggers;       // All triggers (timers, actions, ports)
  Environment* env;         // Execution environment
};
```

Reactors can be **hierarchical**—a reactor may contain child reactors, forming a tree structure. This enables modular design where complex systems are composed from simpler, reusable components.

<p align="center">
  <img src="/assets/images/diagrams/HierarchicalReactor.svg" alt="Hierarchical Reactor" width="80%">
</p>

## Reactions

A **reaction** is a procedure that executes atomically in response to triggering events. Reactions are the only way to modify a reactor's state or produce outputs.

```c
struct Reaction {
  Reactor* parent;           // Owning reactor
  void (*body)(Reaction*);   // The reaction code
  int level;                 // Topological level for ordering
  Trigger** effects;         // Triggers this reaction can affect
  interval_t deadline;       // Optional deadline constraint
};
```

Key properties of reactions:

- **Atomic execution**: A reaction runs to completion without interruption
- **Triggered by events**: Reactions only execute when their triggers fire
- **Ordered deterministically**: Reactions execute in tag order primarily and declaration order secondarily
- **Not callable**: Reactions cannot be called like functions—they only execute when triggered

### Reaction Ordering

When multiple reactions are triggered at the same tag, they execute in a well-defined order based on two rules:

1. **Topological ordering**: Reactions are assigned levels based on the dependency graph. A reaction that reads from a port must execute after any reaction that writes to that port.
2. **Declaration ordering**: Within the same reactor, reactions at the same level execute in the order they are declared in the source file.

```
Level 0:  [Reaction A]  [Reaction B]
              │              │
              ▼              ▼
Level 1:  [Reaction C]  [Reaction D]
              │
              ▼
Level 2:  [Reaction E]
```

## Triggers

**Triggers** are event sources that cause reactions to execute. The uLF runtime supports several trigger types:

### Timers

Timers generate events at specified times, either once or periodically.

```c
struct Timer {
  Trigger super;
  interval_t offset;   // Initial delay
  interval_t period;   // Repeat interval (0 for one-shot)
};
```

A timer with `offset=100ms` and `period=50ms` fires at logical times 100ms, 150ms, 200ms, etc.

### Actions

Actions allow reactions to schedule future events. There are two types:

**Logical Actions** schedule events at a future logical time:

```c
// Schedule an event 10ms in the future
lf_schedule(my_action, MSEC(10), &payload);
```

**Physical Actions** are triggered by external events (interrupts, callbacks) and bridge physical time into the logical time domain:

```c
// Called from an interrupt handler
lf_schedule(sensor_action, 0, &sensor_data);
```

### Startup and Shutdown

Special built-in triggers fire exactly once:

- **Startup**: Fires at the beginning of execution (time 0, microstep 0)
- **Shutdown**: Fires when the program terminates

## Ports and Connections

**Ports** are the interfaces through which reactors communicate. Each port has a type and direction:

- **Input ports** receive data from upstream reactors
- **Output ports** send data to downstream reactors

```c
struct Port {
  Trigger super;
  void* value_ptr;     // Current value
  size_t value_size;   // Size of value type
  Connection* conn_in; // Upstream connection (inputs)
  Connection** conns_out; // Downstream connections (outputs)
};
```

**Connections** wire ports together, defining the communication topology:

<p align="center">
  <img src="/assets/images/diagrams/SimpleConnection.svg" alt="Simple Connection" width="80%">
</p>

### Connection Types

**Logical Connections** propagate values immediately (within the same logical time):

```c
struct LogicalConnection {
  Connection super;
  // Value propagates at same tag
};
```

**Delayed Connections** introduce a time delay between sender and receiver. In Lingua Franca, these are specified with the `after` keyword:

```lf
source.out -> destination.in after 10 ms
```

```c
struct DelayedConnection {
  Connection super;
  interval_t delay;  // Time delay
  // Value arrives at tag + delay
};
```

**Physical Connections** (using `~>` in Lingua Franca) derive the logical time at the receiver from the physical clock rather than the sender's logical time. This is useful for modeling network communication with variable latency.

### Multicast

A single output port can connect to multiple input ports. When the output is set, all downstream inputs receive the value:

<p align="center">
  <img src="/assets/images/diagrams/MulticastPattern.svg" alt="Multicast Pattern" width="80%">
</p>

## The `is_present` Pattern

Ports and actions have an `is_present` flag that indicates whether they were set at the current logical time:

```c
void my_reaction(Reaction* self) {
  MyReactor* r = (MyReactor*)self->parent;

  if (r->input_port.super.is_present) {
    // Input was set at this tag
    int value = *(int*)r->input_port.value_ptr;
    // ... process value
  }
}
```

This pattern enables reactions to handle optional inputs and distinguish between "no value" and "value is zero."

## Hierarchy and Containment

Reactors form a tree hierarchy. The **main reactor** is the root, containing all other reactors:

<p align="center">
  <img src="/assets/images/diagrams/ReactorHierarchy.svg" alt="Reactor Hierarchy" width="80%">
</p>

Child reactors are instantiated by their parent. Connections can cross hierarchy boundaries through port forwarding:

<p align="center">
  <img src="/assets/images/diagrams/PortForwarding.svg" alt="Port Forwarding" width="80%">
</p>

