# Reaction API

This page documents the functions and macros available to use within reaction bodies, deadline violation handlers and STP violation handlers. A pointer to the Environment is defined as `env` within the scope of the reactions. This enables us to access the environment API as follows: 

```lf 
reaction(t) {= 
  instant_t now = env->get_logical_time(env); 
=} 
```

## Reading logical and physical time
[Environment.get_elapsed_logical_time]()
[Environment.get_logical_time]()
[Environment.get_elapsed_physical_time]()
[Environment.get_physical_time]()
[Environment.get_lag]()

## Waiting/sleeping
[Environment.wait_for]()

## Critical sections
[Environment.enter_critical_section]()
[Environment.leave_critical_section]()

## Requesting shutdown
[Environment.request_shutdown]()

## Setting and getting ports
[lf_set]()
[lf_set_array]()
[lf_get]()
[lf_is_present]()

## Scheduling actions
[lf_schedule]()
[lf_schedule_array]()

## Logging
The runtime does logging on a per-module basis, verbosity is controlled by compile
definitions. The different verbosity levels are `LF_LOG_LEVEL_OFF`,
`LF_LOG_LEVEL_ERROR`, `LF_LOG_LEVEL_WARN`, `LF_LOG_LEVEL_INFO` and `LF_LOG_LEVEL_DEBUG`. To configure the log verbosity level to DEBUG for all modules add the following to your CMake:

```cmake
target_compile_definition(reactor-uc PUBLIC LF_LOG_LEVEL_ALL=LF_LOG_LEVEL_DEBUG)
```

You can also set the log verbosity level on individual modules, e.g. to set only logging related to the scheduler to DEBUG:

```cmake
target_compile_definition(reactor-uc PUBLIC LF_LOG_LEVEL_SCHED=LF_LOG_LEVEL_DEBUG)
```

The different modules are `LF_LOG_LEVEL_ENV`, `LF_LOG_LEVEL_SCHED`, `LF_LOG_LEVEL_QUEUE`, `LF_LOG_LEVEL_FED`, `LF_LOG_LEVEL_TRIG`, `LF_LOG_LEVEL_PLATFORM`, `LF_LOG_LEVEL_CONN`, and `LF_LOG_LEVEL_NET`.

To disable all logging, `LF_LOG_DISABLE` can be defined. The logs are by default colorized, to disable this define `LF_COLORIZE_LOGS` to 0. Timestamps are also added to the log by default, to disable define `LF_TIMESTAMP_LOGS` to 0.