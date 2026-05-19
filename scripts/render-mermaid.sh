#!/usr/bin/env bash
# Walk every .md under items/, extract each ```mermaid``` block to
# .mermaid/<dir>/<basename>/<N>.mmd, render to ...<N>.png via mmdc,
# and rewrite the .md so the block becomes an image link.
#
# Numbered (1, 2, 3, ...) in encounter order within each .md.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MMDC="$ROOT/node_modules/.bin/mmdc"
PUPPETEER_CONFIG="$ROOT/puppeteer-config.json"

if [ ! -x "$MMDC" ]; then
    echo "mmdc not found at $MMDC — run npm install" >&2
    exit 1
fi

extract_and_render() {
    local md="$1"
    local rel="${md#$ROOT/}"               # e.g. items/spec-foo.md
    local dir="$(dirname "$rel")"          # e.g. items
    local base="$(basename "$rel" .md)"    # e.g. spec-foo
    local outdir="$ROOT/.mermaid/$dir/$base"

    # awk pass 1: split into per-block .mmd files. Returns 0 if no blocks found.
    local count
    count=$(awk -v outdir="$outdir" '
        BEGIN { n = 0; inblock = 0 }
        /^```mermaid[ \t]*$/ { inblock = 1; n++; system("mkdir -p \"" outdir "\""); fname = outdir "/" n ".mmd"; next }
        inblock && /^```[ \t]*$/ { inblock = 0; close(fname); next }
        inblock { print > fname }
        END { print n }
    ' "$md")

    if [ "$count" -eq 0 ]; then
        return 0
    fi

    # Render each .mmd → .png.
    local i
    for ((i=1; i<=count; i++)); do
        "$MMDC" --input "$outdir/$i.mmd" --output "$outdir/$i.png" \
            --outputFormat png --scale 2 --quiet \
            --puppeteerConfigFile "$PUPPETEER_CONFIG"
    done

    # awk pass 2: rewrite the .md, replacing each ```mermaid``` block with an image link.
    # Image link path is relative to the .md's directory (one level up to repo root, then into .mermaid/).
    local depth=$(echo "$dir" | tr -cd '/' | wc -c | tr -d ' ')
    local up=""
    local d
    for ((d=0; d<=depth; d++)); do up="../$up"; done   # one ../ per dir level, plus one for the .md itself
    local link_prefix="${up}.mermaid/$dir/$base"

    awk -v prefix="$link_prefix" '
        BEGIN { inblock = 0; n = 0 }
        /^```mermaid[ \t]*$/ { inblock = 1; n++; print "![diagram](" prefix "/" n ".png)"; next }
        inblock && /^```[ \t]*$/ { inblock = 0; next }
        inblock { next }
        { print }
    ' "$md" > "$md.tmp"
    mv "$md.tmp" "$md"

    echo "rendered $count diagram(s): $rel"
}

# Find every .md under items/ and process it.
while IFS= read -r -d '' md; do
    extract_and_render "$md"
done < <(find "$ROOT/items" -name '*.md' -print0)
