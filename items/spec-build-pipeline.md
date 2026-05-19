---
itemId: spec-build-pipeline
itemType: Software Item Spec
---

# Build pipeline

The build pipeline transforms source commits into versioned release artifacts via four stages: Build, Test, Package, Release.

```mermaid
flowchart LR
    Source[Source repo] --> Build[Build job]
    Build --> Test[Test job]
    Test --> Package[Package job]
    Package --> Release[Release artifact]
```

## Trigger flow

A push to the source repository triggers the pipeline via webhook. The CI system runs the stages and publishes the result to the artifact registry.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repo
    participant CI as CI System
    participant Reg as Artifact Registry

    Dev->>Git: Push commit
    Git->>CI: Webhook
    CI->>CI: Build, test, package
    CI->>Reg: Publish artifact
    Reg-->>Dev: Notification
```
