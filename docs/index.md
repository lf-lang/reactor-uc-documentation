# micro-LF

**Deterministic concurrency for embedded systems.** micro-LF brings the [reactor model of computation](https://lf-lang.org) to resource-constrained microcontrollers—eliminating race conditions, deadlocks, and non-determinism.

## Key Features

<div class="grid cards" markdown>

-   :material-sync:{ .lg .middle } **Deterministic Concurrency**

    ---

    Logical time ensures reproducible behavior. Given the same inputs, your program produces the same outputs—every time.

-   :material-memory:{ .lg .middle } **Resource Efficient**

    ---

    No dynamic allocation at runtime. All memory is pre-allocated, making the uLF runtime suitable for safety-critical systems.

-   :material-chip:{ .lg .middle } **Multi-Platform**

    ---

    Write once, run on Zephyr, RIOT, FreeRTOS, ESP-IDF, Raspberry Pi Pico, or bare metal with minimal changes.

-   :material-lan:{ .lg .middle } **Federated Execution**

    ---

    Distribute reactors across multiple nodes while maintaining determinism through coordinated scheduling.

</div>

## Supported Platforms

<div class="grid cards" markdown>

-   ![Zephyr](assets/logos/zephyr.svg){: style="height:48px"}

    ---

    [:octicons-arrow-right-24: Zephyr](platforms/zephyr/index.md)

-   ![RIOT](assets/logos/RIOT.png){: style="height:48px"}

    ---

    [:octicons-arrow-right-24: RIOT](platforms/riot/index.md)

-   ![Pico](assets/logos/pico.svg){: style="height:48px"}

    ---

    [:octicons-arrow-right-24: Pico](platforms/pico/index.md)

-   ![FreeRTOS](assets/logos/freertos.svg){: style="height:48px"}

    ---

    [:octicons-arrow-right-24: FreeRTOS](platforms/freertos/index.md)

-   :fontawesome-brands-linux:{ style="font-size: 48px" }

    ---

    [:octicons-arrow-right-24: POSIX (Linux / macOS)](platforms/posix/index.md)

</div>

## Lingua Franca

<div class="grid" markdown>

<div markdown>

![Lingua Franca](assets/logos/lf.svg#only-light){ width="120" }
![Lingua Franca](assets/logos/lf_white.svg#only-dark){ width="120" }

</div>

<div markdown>

[Lingua Franca](https://lf-lang.org) is a polyglot coordination language for building deterministic, concurrent systems. The uLF runtime is the embedded runtime that enables LF programs to run efficiently on microcontrollers.

[:octicons-arrow-right-24: Learn more at lf-lang.org](https://lf-lang.org)

</div>

</div>

## Quick Example

A simple blinky reactor that toggles an LED every 500ms:

```lf
target uC

main reactor {
  timer t(0, 500 ms)
  state led_on: bool = false

  reaction(startup) {=
    // Initialize LED GPIO
  =}

  reaction(t) {=
    self->led_on = !self->led_on;
    // Toggle LED
  =}
}
```

## Get Started

<div class="grid cards" markdown>

-   **Getting Started**

    ---

    Set up your first micro-LF project with our step-by-step guide.

    [:octicons-arrow-right-24: Getting Started](getting-started/index.md)

-   **Philosophy**

    ---

    Understand the reactor model, logical time, and deterministic concurrency.

    [:octicons-arrow-right-24: Design Philosophy](design/index.md)

-   **Documentation**

    ---

    API reference, annotations, and compile flags.

    [:octicons-arrow-right-24: Documentation](documentation/annotations.md)

</div>

## Community

Built by researchers and engineers from leading institutions worldwide:

<div class="grid" markdown>

![TU Dresden](assets/logos/tud.svg#only-light){ width="150" }
![TU Dresden](assets/logos/tud_white.svg#only-dark){ width="150" }

![UC Berkeley](assets/logos/berkeley.svg#only-light){ width="150" }
![UC Berkeley](assets/logos/berkeley_white.svg#only-dark){ width="150" }

![DTU](assets/logos/dtu.svg){ width="45" }

![University of Verona](assets/logos/verona.svg){ width="75" }

</div>

!!! tip "Join Us"
    This project is looking for collaborators, users, and industry partners to fully realize the potential of the reactor model for embedded systems. Join our [Google Group](https://groups.google.com/g/micro-lf) or [reach out to us](mailto: tassilo.tanneberger@tu-dresden.de)!
