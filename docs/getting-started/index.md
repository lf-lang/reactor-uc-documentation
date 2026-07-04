# Getting Started

This guide walks you through setting up your first micro-LF project.

## Prerequisites

The code generator requires:

- **Git** - [git-scm.com](https://git-scm.com/)
- **Java 17** - [openjdk.org](https://openjdk.org/projects/jdk/17/) (for the Lingua Franca compiler)

Platform-specific tools:

| Platform | Additional Requirements |
|----------|------------------------|
| Native | cmake |
| Zephyr | Python 3, west, Zephyr SDK |
| RIOT | make 4.0+, ARM cross-compiler |
| Pico | CMake, ARM cross-compiler, picotool |
| FreeRTOS | CMake, ARM cross-compiler |
| ESP-IDF | Python 3, CMake, ESP-IDF toolchain |

## Quick Start

### 1. Clone micro-LF

```bash
git clone https://github.com/lf-lang/reactor-uc.git --recurse-submodules
export REACTOR_UC_PATH=$(pwd)/reactor-uc
```

### 2. Clone a template repository

Choose a template for your target platform (except "Native", which does not need a template repo):

<div class="grid cards" markdown>

-   ![Zephyr](../assets/logos/zephyr.svg){: style="height:48px"}

    ---

    **Zephyr** · West

    [:octicons-arrow-right-24: ulf-zephyr-template](https://github.com/lf-lang/ulf-zephyr-template)

-   ![RIOT](../assets/logos/RIOT.png){: style="height:48px"}

    ---

    **RIOT** · Make

    [:octicons-arrow-right-24: ulf-riot-template](https://github.com/lf-lang/ulf-riot-template)

-   ![Pico](../assets/logos/pico.svg){: style="height:48px"}

    ---

    **Raspberry Pi Pico** · CMake

    [:octicons-arrow-right-24: ulf-pico-template](https://github.com/lf-lang/ulf-pico-template)

-   ![FreeRTOS](../assets/logos/freertos.svg){: style="height:48px"}

    ---

    **FreeRTOS** · CMake

    [:octicons-arrow-right-24: ulf-freertos-template](https://github.com/lf-lang/ulf-freertos-template)

-   **ESP-IDF** · CMake

    ---

    [:octicons-arrow-right-24: ulf-esp-idf-template](https://github.com/lf-lang/ulf-esp-idf-template)

-   :fontawesome-brands-linux:{ style="font-size: 48px" }

    ---

    [:octicons-arrow-right-24: POSIX (Linux / macOS)](../platforms/posix/index.md)

</div>

=== "Zephyr"

    ```bash
    git clone https://github.com/lf-lang/ulf-zephyr-template.git my-project
    cd my-project
    python3 -m venv venv && source venv/bin/activate
    pip install west
    west update
    pip install -r deps/zephyr/scripts/requirements.txt
    west zephyr-export
    ```

=== "RIOT"

    ```bash
    git clone https://github.com/lf-lang/ulf-riot-template.git my-project
    cd my-project
    git submodule update --init --recursive
    ```

=== "Pico"

    ```bash
    git clone https://github.com/lf-lang/ulf-pico-template.git my-project
    cd my-project
    git submodule update --init --recursive
    ```

=== "ESP-IDF"

    ```bash
    git clone https://github.com/lf-lang/ulf-esp-idf-template.git my-project
    cd my-project
    git submodule update --init --recursive
    cd esp-idf && ./install.sh esp32 && source ./export.sh && cd ..
    ```

### 3. Build and run

=== "Native"

    ```bash
    ulfc src/MyProgram.lf
    bin/MyProgram
    ```
    
=== "Zephyr"

    ```bash
    west build -t run  # Native simulation
    # Or for hardware:
    west build -b <board> -p always
    west flash
    ```

=== "RIOT"

    ```bash
    make BOARD=native all term  # Native simulation
    # Or for hardware:
    make BOARD=<board> flash
    ```

=== "Pico"

    ```bash
    cmake -Bbuild
    cmake --build build
    picotool load -x build/Blink.elf
    ```

=== "ESP-IDF"

    ```bash
    cmake -Bbuild -DESP_IDF_BOARD=esp32 \
          -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-esp32.cmake \
          -GNinja
    cmake --build build
    cd build && ninja flash
    ```

## Your First Reactor

Each template includes example applications. Here's a simple Blinky reactor:

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
    // Toggle LED based on self->led_on
  =}
}
```

This reactor:

1. Declares a **timer** `t` that fires immediately (`0`) and repeats every `500 ms`
2. Maintains **state** `led_on` to track the LED status
3. Has a **reaction** to `startup` for initialization
4. Has a **reaction** to timer `t` that toggles the LED

To build a different application, set the `LF_MAIN` variable:

=== "Zephyr"

    ```bash
    west build -p always -- -DLF_MAIN=MyApp
    ```

=== "RIOT"

    ```bash
    make LF_MAIN=MyApp all
    ```

=== "Pico / ESP-IDF"

    ```bash
    cmake -Bbuild -DLF_MAIN=MyApp
    cmake --build build
    ```

## Next Steps

<div class="grid cards" markdown>

-   **Platforms**

    ---

    Detailed setup instructions for each supported platform.

    [:octicons-arrow-right-24: Platforms](../platforms/index.md)

-   **Philosophy**

    ---

    Understand the reactor model, logical time, and deterministic concurrency.

    [:octicons-arrow-right-24: Philosophy](../design/index.md)

-   **Documentation**

    ---

    API reference, annotations, and compile flags.

    [:octicons-arrow-right-24: Documentation](../documentation/annotations.md)

</div>
