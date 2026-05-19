---
itemId: spec-data-retention
itemType: Software Item Spec
---

# Data retention policy

The Data Retention Service expires records based on their classification tier. Tier-1 records (audit logs, regulatory submissions) are retained for 10 years. Tier-2 records (operational logs) for 90 days. Tier-3 records (cache, ephemeral metrics) for 24 hours.

```mermaid
flowchart TD
    Record[Incoming record] --> Classify{Classify tier}
    Classify -->|Tier 1| LongTerm[Long-term storage<br/>10 years]
    Classify -->|Tier 2| MidTerm[Mid-term storage<br/>90 days]
    Classify -->|Tier 3| Cache[Cache<br/>24 hours]
    LongTerm --> Audit[Audit access log]
    MidTerm --> Audit
    Cache --> Expire[Auto-expire]
```

## Expiry sequence

The expiry job runs daily, drops records past their retention window, and emits a summary event for compliance audit.

```mermaid
sequenceDiagram
    participant Scheduler
    participant Service as Retention Service
    participant Storage
    participant Audit as Audit Log

    Scheduler->>Service: Daily trigger
    Service->>Storage: Query expired records
    Storage-->>Service: Record list
    Service->>Storage: Delete records
    Service->>Audit: Emit retention summary
    Audit-->>Service: Ack
```
