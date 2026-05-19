---
itemId: req-data-flow
itemType: Requirement
---

# Data flow through the sensor module

The Sensor Module shall acquire readings from the hardware sensor, preprocess them, and transmit the result to the analysis subsystem. Out-of-range readings shall be surfaced as warnings without interrupting the stream.

```mermaid
flowchart LR
    Sensor[Hardware sensor] --> Acquire[Acquire raw reading]
    Acquire --> Preprocess[Preprocess]
    Preprocess --> Transmit[Transmit to analysis subsystem]
    Preprocess -->|out-of-range| Warn[Raise sensor warning]
```
