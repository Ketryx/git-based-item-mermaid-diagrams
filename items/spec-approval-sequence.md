---
itemId: spec-approval-sequence
itemType: Software Item Spec
---

# Approval sequence

When a reviewer approves a Git-based item, Ketryx records the e-signature, transitions the item state, and recomputes the traceability matrix downstream.

## Sequence

![diagram](.diagrams/1581afe97cca.svg)
<details><summary>Mermaid source</summary>

```mermaid
sequenceDiagram
    participant Reviewer
    participant Ketryx
    participant Repo as Git Repo
    participant RTM as Traceability Matrix

    Reviewer->>Ketryx: Approve item (e-signature)
    Ketryx->>Ketryx: Verify reviewer permissions
    Ketryx->>Repo: Record approval at commit SHA
    Ketryx->>RTM: Recompute coverage
    RTM-->>Reviewer: Updated matrix view
```

</details>
