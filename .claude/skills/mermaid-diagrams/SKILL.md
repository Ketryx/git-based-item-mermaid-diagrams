---
name: mermaid-diagrams
description: How to write mermaid diagrams in Ketryx Git-based markdown items. Trigger when authoring or editing .md files in repos that have .github/workflows/render-mermaid.yml and a render-mermaid GitHub label.
---

# Mermaid diagrams in Git-based items

This repo uses a label-driven rendering flow. Authors write inline ```` ```mermaid ```` blocks in `.md` items as normal. When a PR is labeled `render-mermaid`, a GitHub Action runs the official `@mermaid-js/mermaid-cli` against each `.md`. The CLI extracts each block, renders it to PNG, and rewrites the `.md` to reference the PNG.

## Detect the convention

Active if:
- `.github/workflows/render-mermaid.yml` exists.
- `@mermaid-js/mermaid-cli` is in `package.json`.

## Rules

- **Write inline ```` ```mermaid ```` blocks** in the `.md`. This is the source-of-truth form when authoring or editing.
- **Never hand-author the image link** (`![](./foo-1.png)`). The bot writes those when it renders.
- **To edit a previously rendered diagram:** find the original mermaid source in git history (the commit that introduced the inline block), paste it back into the `.md` as a fresh ```` ```mermaid ```` block, and re-apply the `render-mermaid` label.

## Before finishing a task

If you edited a `.md` to add or modify mermaid blocks, leave them inline. Tell the user the PR needs the `render-mermaid` label applied to render the diagrams — don't try to run the renderer yourself unless the user asks.
