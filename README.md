# Git-based item mermaid diagrams

Render [mermaid](https://mermaid.js.org/) diagrams in Ketryx Git-based configuration items.

Raw ```` ```mermaid ```` blocks don't render in Ketryx-generated documents. Write them inline anyway — when your PR is ready, label it `render-mermaid` and a GitHub Action will:

1. Extract each ` ```mermaid``` ` block.
2. Render it to a PNG.
3. Replace the block in the `.md` with an image link.
4. Commit the result to your PR branch.

You author markdown the way you always do. The bot handles the rest.

## How it works

For an item at `items/spec-foo.md` with a mermaid block, the bot produces:

```
.mermaid/items/spec-foo/1.mmd     ← extracted source
.mermaid/items/spec-foo/1.png     ← rendered diagram
```

and rewrites `items/spec-foo.md`:

```diff
- ```mermaid
- flowchart LR
-     A --> B
- ```
+ ![diagram](../.mermaid/items/spec-foo/1.png)
```

The `render-mermaid` label stays on the PR after rendering as a "this PR is rendered" badge.

## Re-rendering after edits

To change a diagram, edit the `.mmd` file under `.mermaid/...` directly and commit. Or add a fresh ` ```mermaid``` ` block back to the `.md`, re-apply the label, and the bot will render again.

## Running it locally

```bash
git clone https://github.com/Ketryx/git-based-item-mermaid-diagrams.git
cd git-based-item-mermaid-diagrams
npm install
./scripts/render-mermaid.sh
```

## Adopting in your own repo

Copy:

- `scripts/render-mermaid.sh`
- `package.json`
- `puppeteer-config.json`
- `.github/workflows/render-mermaid.yml`

Create a label called `render-mermaid` in your repo. Adjust the `find` path in `scripts/render-mermaid.sh` if your items don't live under `items/`.

The Action commits to the PR branch using the default `GITHUB_TOKEN`. This works for PRs from branches in the same repo. PRs from forks won't get auto-rendering — fork contributors run the script locally.

## Claude skill

If you use [Claude Code](https://claude.com/claude-code), copy `.claude/skills/mermaid-sidecar/` into your repo. The skill tells Claude to write inline ` ```mermaid``` ` blocks and never hand-author the rendered links.
