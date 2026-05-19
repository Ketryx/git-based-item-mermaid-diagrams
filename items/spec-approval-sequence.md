---
itemId: spec-approval-sequence
itemType: Software Item Spec
---

# Approval sequence

When a reviewer approves a Git-based item, Ketryx records the e-signature, transitions the item state, and recomputes the traceability matrix downstream.

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
