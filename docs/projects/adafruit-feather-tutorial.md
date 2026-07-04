# micro-lf Adafruit Feather Tutorial

A hands-on tutorial for writing federated reactor programs on the Adafruit Feather Sense using the reactor-uc runtime and RIOT OS.

## What you will learn

- Set up and build for the **Adafruit Feather Sense** (nRF52840-based board)
- Configure the **reactor-uc runtime** for a bare-metal RIOT OS target
- Read sensor data from the on-board **LSM6DS33 accelerometer**
- Write a **federated LF program** where two nodes communicate over **BLE**

## Setup

The tutorial uses RIOT OS as the underlying RTOS. reactor-uc is integrated as a RIOT module, so the standard RIOT build system (`make`) handles compilation and flashing.

```bash
git clone https://github.com/lf-lang/micro-lf-tutorial
cd micro-lf-tutorial
```

## Runtime Configuration

The target block configures the reactor-uc runtime for the Feather Sense:

```lf
target uC {
    platform: nrf52840,
    scheduler: STATIC,
    logging: WARN
}
```

RIOT OS provides the hardware abstraction for timers, BLE, and GPIO. No RTI process is needed — federates negotiate connections directly over BLE advertisement and GATT.

## Reading the Accelerometer

A dedicated reactor wraps the LSM6DS33 driver and emits acceleration vectors on a periodic timer:

```lf
reactor Accelerometer(rate: interval_t = 100msec) {
    output acc: AccelerationVec;
    timer t(0, rate);

    reaction(t) -> acc {=
        AccelerationVec v;
        lsm6ds33_read_acc(&dev, &v.x, &v.y, &v.z);
        lf_set(acc, v);
    =}
}
```

## Federated Program over BLE

Two Feather Sense boards run as separate federates. One reads the accelerometer and streams data; the other receives and drives the on-board LED based on the magnitude.

```lf
federated reactor {
    @interface_ble(name="ble0", role="peripheral", mtu=64)
    @clock_sync(grandmaster=true, period=1000000000)
    sensor_node = new SensorNode();

    @interface_ble(name="ble0", role="central", peer="sensor_node")
    @clock_sync(grandmaster=false, period=1000000000)
    display_node = new DisplayNode();

    @link(left="ble0", right="ble0")
    sensor_node.acc_out -> display_node.acc_in after 10msec;
}
```

The `@interface_ble` annotation configures the BLE transport. The central node scans for the peripheral by name and establishes the GATT channel before execution begins. `after 10msec` adds a logical delay to account for BLE connection latency.

## Repository

[:octicons-mark-github-16: lf-lang/micro-lf-tutorial](https://github.com/lf-lang/micro-lf-tutorial)
