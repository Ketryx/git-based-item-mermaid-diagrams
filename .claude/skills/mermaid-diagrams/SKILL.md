---
name: mermaid-diagrams
description: How to write mermaid diagrams in Ketryx Git-based markdown items. Trigger when authoring or editing .md files in repos that have scripts/render-mermaid.sh and a render-mermaid GitHub label.
---

# Mermaid diagrams in Git-based items

This repo uses a label-driven rendering flow. Authors write inline ```` ```mermaid ```` blocks in `.md` items as normal. When a PR is labeled `render-mermaid`, a GitHub Action extracts each block, renders it to PNG, stores the source under `.mermaid/<path>/<basename>/<N>.mmd`, and rewrites the `.md` to reference the PNG.

## Detect the convention

Active if:
- `scripts/render-mermaid.sh` exists.
- `.github/workflows/render-mermaid.yml` exists.
- `@mermaid-js/mermaid-cli` is in `package.json`.

## Rules

- **Write inline ```` ```mermaid ```` blocks.** This is the source-of-truth form when authoring or editing.
- **Never hand-author the image link** (`![](.mermaid/...png)`) or the `.mermaid/` directory. The bot owns those.
- **To edit a previously rendered diagram:** either edit the `.mmd` under `.mermaid/<path>/<basename>/<N>.mmd` directly, or paste the mermaid source back into the `.md` as an inline block (the bot will re-extract on the next render).
- **Don't delete `.mermaid/` files** unless you're also removing the corresponding image link from the `.md`.

## Before finishing a task

If you edited an `.md` to add or modify mermaid blocks, leave them inline. Tell the user the PR needs the `render-mermaid` label applied to render the diagrams — don't try to run the script yourself unless the user asks.
