# Design Philosophy

micro-LF brings the **reactor model of computation** to resource-constrained embedded systems. This section explains the core concepts, design decisions, and trade-offs that shape the runtime.

## Why micro-LF?

Concurrent programming on embedded systems is notoriously difficult. Traditional approaches—bare-metal interrupts, RTOS tasks, or event loops—require developers to manually manage synchronization, timing, and communication. This leads to:

- **Race conditions** from unprotected shared state
- **Deadlocks** from improper lock ordering
- **Non-determinism** that makes debugging nearly impossible
- **Timing bugs** that only manifest under specific conditions

The reactor model offers a fundamentally different approach: **deterministic concurrency through logical time**. Instead of reasoning about physical time and thread interleavings, developers define reactive components that respond to events at well-defined logical instants.

## The Reactor Model

At its core, the reactor model structures programs as a composition of **reactors**—isolated components that communicate through well-defined **ports** and **connections**. Each reactor contains:

- **State** that is private and encapsulated
- **Reactions** that execute atomically in response to triggers
- **Ports** for typed communication with other reactors
- **Timers and Actions** for scheduling future events

<p align="center">
  <img src="/assets/images/diagrams/BasicReactor.svg" alt="Basic Reactor" width="80%">
</p>

This model is implemented in the [Lingua Franca](https://lf-lang.org) coordination language, and the uLF runtime serves as the execution runtime for embedded targets.

## Design Principles

### 1. Determinism Through Logical Time

Every event in the uLF runtime occurs at a **logical time**, independent of when it physically executes. Events at the same logical time are ordered by **microsteps**, providing a total ordering of all events. This means:

- Given the same inputs, the program produces the same outputs
- Debugging is reproducible—you can replay executions exactly
- Testing is meaningful—no flaky tests from timing variations

### 2. Resource Efficiency

Embedded systems have tight memory and CPU constraints. The uLF runtime is designed with this in mind:

- **No dynamic allocation at runtime**—all memory is pre-allocated
- **Minimal dependencies**—just the C standard library (and nanopb for federation)
- **Compile-time configuration**—unused features have zero overhead

### 3. Composability

Complex systems are built from simpler parts. The uLF runtime supports:

- **Hierarchical reactors**—reactors can contain child reactors
- **Typed connections**—ports enforce type compatibility
- **Modular design**—reactors are reusable building blocks

### 4. Platform Independence

The same reactor program can run on different targets:

- POSIX (Linux, macOS) for development and testing
- Zephyr RTOS for production embedded deployments
- RIOT OS for IoT devices
- Raspberry Pi Pico for hobbyist and educational use
- FreeRTOS for existing RTOS-based projects
- Bare metal for maximum control

A thin **platform abstraction layer** provides timing, synchronization, and I/O primitives for each target.

### 5. Distribution Without Sacrificing Correctness

The uLF runtime supports **federated execution**—distributing reactors across multiple nodes connected by networks. The runtime maintains determinism guarantees through:

- **Safe-To-Process (STP)** constraints that bound waiting time
- **Clock synchronization** to align physical clocks
- **Startup coordination** to ensure all nodes begin together

## What's Next?

Explore the detailed documentation for each aspect of the design:

<div class="grid cards" markdown>

-   **The Reactor Model**

    ---

    Understand reactors, reactions, ports, and connections—the building blocks of micro-LF programs.

    [:octicons-arrow-right-24: Reactor Model](reactor-model.md)

-   **Time and Determinism**

    ---

    Learn how logical time, tags, and microsteps enable deterministic concurrent execution.

    [:octicons-arrow-right-24: Time Model](time-model.md)

-   **Scheduling**

    ---

    Explore the event-driven scheduler that executes reactor programs.

    [:octicons-arrow-right-24: Scheduling](scheduling.md)

-   **Memory Management**

    ---

    Understand the pre-allocation strategy that makes the uLF runtime suitable for embedded systems.

    [:octicons-arrow-right-24: Memory](memory.md)

-   **Platform Abstraction**

    ---

    See how the uLF runtime adapts to different operating systems and hardware.

    [:octicons-arrow-right-24: Platforms](platform.md)

-   **Federated Execution**

    ---

    Distribute reactors across multiple nodes while maintaining correctness.

    [:octicons-arrow-right-24: Federation](federated.md)

</div>
