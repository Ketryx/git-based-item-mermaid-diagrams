---
itemId: req-data-flow
itemType: Requirement
---

# Data flow through the sensor module

The Sensor Module shall acquire readings from the hardware sensor, preprocess them, and transmit the result to the analysis subsystem. Out-of-range readings shall be surfaced as warnings without interrupting the stream.

## Data flow

![diagram](.diagrams/5f4b9bb3b6f3.svg)
<details><summary>Mermaid source</summary>

```mermaid
flowchart LR
    Sensor[Hardware sensor] --> Acquire[Acquire raw reading]
    Acquire --> Preprocess[Preprocess]
    Preprocess --> Transmit[Transmit to analysis subsystem]
    Preprocess -->|out-of-range| Warn[Raise sensor warning]
```

</details>
