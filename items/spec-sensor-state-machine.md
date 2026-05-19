---
itemId: spec-sensor-state-machine
itemType: Software Item Spec
itemFulfills: req-data-flow
---

# Sensor state machine

The sensor module is implemented as a state machine with four states: Idle, Sampling, Fault, and a transient initialization state.

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Sampling: start()
    Sampling --> Idle: stop()
    Sampling --> Fault: out-of-range
    Fault --> Idle: reset()
```

## Notes

- `out-of-range` is detected during Preprocess (see `req-data-flow`).
- `reset()` clears the fault and returns to Idle without re-initializing the sensor.
