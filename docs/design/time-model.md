# Time and Determinism

The reactor model achieves **deterministic concurrency** through a carefully designed time model. This page explains how logical time, tags, and microsteps work together to provide reproducible execution.

## Physical Time vs Logical Time

Traditional concurrent programs operate in **physical time**—the actual wall-clock time measured by the hardware. This creates problems:

- Execution order depends on scheduling decisions
- Race conditions arise from unpredictable interleavings
- Debugging is difficult because bugs may not reproduce

The uLF runtime introduces **logical time**—an abstract notion of time that progresses in discrete steps, independent of physical execution. Events occur at logical time instants, and the scheduler ensures they are processed in logical time order.

```
Physical Time:  ──────────────────────────────────────▶
                     │      │          │
                     │      │          │
Logical Time:   ─────●──────●──────────●──────────────▶
                   t=0    t=10ms     t=50ms
```

The key insight: **logical time only advances when all processing at the current logical time is complete**. This eliminates race conditions by construction.

## Tags

A **tag** is the fundamental unit of logical time in the uLF runtime. It consists of two components:

```c
typedef struct {
  instant_t time;       // Logical time (nanoseconds since start)
  microstep_t microstep; // Ordering within the same time instant
} tag_t;
```

Tags provide a **total ordering** of all events in the system. Given two tags, one is always before, after, or equal to the other:

```c
// Tag comparison
tag_t a = {.time = 100, .microstep = 0};
tag_t b = {.time = 100, .microstep = 1};
tag_t c = {.time = 200, .microstep = 0};

// a < b < c
lf_tag_compare(a, b);  // Returns -1 (a is earlier)
lf_tag_compare(b, c);  // Returns -1 (b is earlier)
```

## Microsteps

**Microsteps** solve a subtle problem: what happens when multiple events occur at the same logical time?

Consider a reaction that reads an input and immediately schedules an action with zero delay:

```
Logical Time 100ms:
  - Input port receives value
  - Reaction reads input, schedules action with delay=0
  - Action should fire... but when?
```

Without microsteps, this would create a causality paradox. With microsteps:

```
Tag (100ms, 0): Input arrives, reaction executes
Tag (100ms, 1): Zero-delay action fires, next reaction executes
Tag (100ms, 2): Another zero-delay action (if any)
...
```

Microsteps increment for each "round" of processing at the same logical time, until no more events remain at that time. Then logical time advances to the next scheduled event.

```
┌─────────────────────────────────────────────────────────┐
│                    Tag (100ms, 0)                        │
│  ┌────────────────┐                                      │
│  │ Process events │──▶ Reactions may schedule at (100ms,1)│
│  └────────────────┘                                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Tag (100ms, 1)                        │
│  ┌────────────────┐                                      │
│  │ Process events │──▶ Reactions may schedule at (100ms,2)│
│  └────────────────┘                                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
                   (no more events at 100ms)
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Tag (200ms, 0)                        │
│  ┌────────────────┐                                      │
│  │ Process events │                                      │
│  └────────────────┘                                      │
└─────────────────────────────────────────────────────────┘
```

## Logical Actions

**Logical actions** schedule events at future logical times. The scheduled time is computed relative to the current logical time:

```c
// Current tag: (100ms, 0)
lf_schedule(my_action, MSEC(50), &value);
// Schedules event at tag (150ms, 0)
```

Key properties:

- **Every call to `lf_schedule()` advances the tag by at least one microstep**. Scheduling with zero delay at tag (t, n) creates an event at tag (t, n+1), not at the current tag.
- The `min_delay` parameter specifies the minimum offset before the action triggers
- The `min_spacing` parameter enforces a minimum logical time interval between successive events

### Action Policies

When scheduling conflicts occur, **action policies** determine the behavior:

| Policy | Behavior |
|--------|----------|
| `DEFER` | Adjust the scheduled time to satisfy constraints |
| `DROP` | Discard the new event if it conflicts |
| `REPLACE` | Replace the pending event's payload with the new value |
| `UPDATE` | Cancel the pending event and schedule the new one |

```c
// Example: UPDATE policy
// Event scheduled at t=100ms with value=1
lf_schedule(action, MSEC(100), &value1);
// Later, before t=100ms, schedule with value=2
lf_schedule(action, MSEC(50), &value2);
// With UPDATE: cancels (100ms, value1), schedules (50ms, value2)
```

## Physical Actions

**Physical actions** bridge the gap between physical time and logical time. They are triggered by external events—interrupts, network packets, user input—that occur at unpredictable physical times.

```c
// In an interrupt handler:
void sensor_isr(void) {
  int reading = read_adc();
  lf_schedule(sensor_action, 0, &reading);
}
```

When a physical action is scheduled:

1. The current physical time is captured
2. An event is created at a logical time ≥ current physical time
3. The event is inserted into the event queue
4. The scheduler may be woken from sleep

Physical actions require special handling because they can arrive at any time, potentially during reaction execution. The uLF runtime uses **critical sections** to protect the event queue from concurrent access.

## Determinism Guarantees

The time model provides **determinism** under specific conditions:

### When is execution deterministic?

✅ **Deterministic** when:

- All inputs arrive in the same order with the same values
- Reactions are pure functions of their inputs and reactor state
- Physical actions are not used (or arrive at predictable times)

⚠️ **Non-deterministic** when:

- Physical actions arrive at varying physical times
- Reactions have side effects on shared external state
- Deadlines are violated and handler behavior varies

### Practical determinism

Even with physical actions, the uLF runtime maintains **logical determinism**:

- Given the same sequence of events (with their tags), execution is deterministic
- Physical actions add events to this sequence
- Recording and replaying event sequences enables reproducible debugging

## Deadlines

**Deadlines** constrain the physical time by which a reaction must complete:

```c
struct Reaction {
  interval_t deadline;  // Maximum allowed lag
};
```

The **lag** is the difference between physical time and logical time:

```
lag = physical_time - logical_time
```

If `lag > deadline` when a reaction is about to execute, the deadline is violated. This can trigger:

- A deadline handler function
- Logging for post-mortem analysis
- Graceful degradation behavior

```
Physical Time:  ──────────────────────────────────────▶
                              │
                              │ physical_time
                              │
Logical Time:   ──────●───────┼───────────────────────▶
                    t=100ms   │
                              │
                   ◀──────────┤
                      lag
```

## Time Utilities

The uLF runtime provides convenience macros for time values:

```c
// Time literals
NSEC(100)   // 100 nanoseconds
USEC(100)   // 100 microseconds
MSEC(100)   // 100 milliseconds
SEC(1)      // 1 second
MINUTE(1)   // 1 minute
HOUR(1)     // 1 hour
DAY(1)      // 1 day
WEEK(1)     // 1 week

// Special values
NEVER       // Time that never occurs
FOREVER     // Infinite duration
ZERO_TAG    // Tag (0, 0)
```

