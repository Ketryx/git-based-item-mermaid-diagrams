# Git-based item mermaid diagrams

Render [mermaid](https://mermaid.js.org/) diagrams in Ketryx Git-based configuration items, while keeping the mermaid source visible in your authored Markdown.

## How it works

Each item is two files:

- `items/spec-foo.md` — the **source**. You author this. Has inline ```` ```mermaid ```` blocks.
- `items/spec-foo.doc.md` — the **rendered document**. The bot produces this. Has image links instead of ```` ```mermaid ```` blocks. **Ketryx reads this file.**

When your PR is ready, apply the `render-mermaid` label. A GitHub Action copies each `items/*.md` to `items/*.doc.md`, runs the official `@mermaid-js/mermaid-cli` on the copy, and commits the result. The bot never modifies your source `.md`.

Editing a diagram is just editing the source `.md` and re-applying the label. The mermaid source is right there — no git archaeology required.

See it in action: [PR #5](https://github.com/Ketryx/git-based-item-mermaid-diagrams/pull/5) is a permanent demo PR.

## Example

`items/spec-foo.md` (your source, never touched):

````markdown
---
itemId: spec-foo
itemType: Software Item Spec
---

# Foo

```mermaid
flowchart LR
    A --> B
```
````

`items/spec-foo.doc.md` (bot output, Ketryx reads this):

```markdown
---
itemId: spec-foo
itemType: Software Item Spec
---

# Foo

![diagram](./spec-foo.doc-1.png)
```

And `items/spec-foo.doc-1.png` sits next to it.

## Ketryx glob pattern

Point your project's glob at `items/**/*.doc.md`. The bare `.md` source files are ignored by Ketryx — they exist only for human authoring.

## Running it locally

```bash
git clone https://github.com/Ketryx/git-based-item-mermaid-diagrams.git
cd git-based-item-mermaid-diagrams
npm install
find items -name '*.md' -not -name '*.doc.md' | while read md; do
    doc="${md%.md}.doc.md"
    cp "$md" "$doc"
    ./node_modules/.bin/mmdc \
      --input "$doc" --output "$doc" \
      --outputFormat png --scale 2 --quiet \
      --puppeteerConfigFile puppeteer-config.json
done
```

## Adopting in your own repo

Copy:

- `package.json`
- `puppeteer-config.json`
- `.github/workflows/render-mermaid.yml`

Create a `render-mermaid` label. In your Ketryx project, set the items glob to `**/*.doc.md`. If your items live somewhere other than `items/`, adjust the `find` path in the workflow.

The Action commits to the PR branch using the default `GITHUB_TOKEN`, which works for PRs from branches in the same repo. PRs from forks won't get auto-rendering — fork contributors run the rendering step locally and commit the result before opening the PR.

## Claude skill

If you use [Claude Code](https://claude.com/claude-code), copy `.claude/skills/mermaid-diagrams/` into your repo. The skill tells Claude to edit only `.md` source files and never touch `.doc.md` or PNGs by hand.
