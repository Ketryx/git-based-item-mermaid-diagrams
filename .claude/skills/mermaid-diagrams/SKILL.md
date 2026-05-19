---
name: mermaid-diagrams
description: How to write mermaid diagrams in Ketryx Git-based markdown items. Trigger when authoring or editing .md files in repos that have .github/workflows/render-mermaid.yml and a render-mermaid GitHub label.
---

# Mermaid diagrams in Git-based items

This repo splits each item into two files:

- `items/<name>.md` — the **source**, authored by humans. Has inline ```` ```mermaid ```` blocks.
- `items/<name>.doc.md` — the **rendered document**, produced by the bot. Has image links instead of ```` ```mermaid ```` blocks. Ketryx reads this file.

When a PR is labeled `render-mermaid`, a GitHub Action regenerates every `.doc.md` from its source `.md`. The bot never modifies source `.md` files.

## Detect the convention

Active if:
- `.github/workflows/render-mermaid.yml` exists.
- `@mermaid-js/mermaid-cli` is in `package.json`.
- Pairs of `<name>.md` and `<name>.doc.md` files exist in `items/`.

## Rules

- **Edit only `.md` source files** when adding or changing diagrams. Write inline ```` ```mermaid ```` blocks.
- **Never hand-edit `.doc.md` or `.doc-N.png` files.** The bot regenerates them on every render and your changes will be lost.
- **Never hand-author image links.** They appear in `.doc.md`, which the bot owns.
- **To edit an existing diagram:** open the `.md` source file, edit the ```` ```mermaid ```` block inline, and tell the user to re-apply the `render-mermaid` label.

## Before finishing a task

If you added or changed a `.md` source file, leave the inline ```` ```mermaid ```` block as-is. Tell the user the PR needs the `render-mermaid` label applied to regenerate the `.doc.md`. Don't run the renderer yourself unless the user asks.
