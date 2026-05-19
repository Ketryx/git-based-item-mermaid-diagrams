---
itemId: spec-build-pipeline
itemType: Software Item Spec
---

# Build pipeline

The build pipeline transforms source commits into versioned release artifacts via four stages: Build, Test, Package, Release.

![diagram](../.mermaid/items/spec-build-pipeline/1.png)

## Trigger flow

A push to the source repository triggers the pipeline via webhook. The CI system runs the stages and publishes the result to the artifact registry.

![diagram](../.mermaid/items/spec-build-pipeline/2.png)
