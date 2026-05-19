MMDC ?= ./node_modules/.bin/mmdc

MMD_FILES := $(shell find items -name '*.mmd')
SVG_FILES := $(MMD_FILES:.mmd=.svg)

.PHONY: all clean check

all: $(SVG_FILES)

%.svg: %.mmd
	$(MMDC) --input $< --output $@ --outputFormat svg --quiet

# CI safety net: re-render every .mmd into a temp file and diff against the
# committed .svg. Fails if any .svg is stale or missing.
check:
	@status=0; \
	for mmd in $(MMD_FILES); do \
		svg=$${mmd%.mmd}.svg; \
		if [ ! -f $$svg ]; then \
			echo "missing: $$svg (run \`make\` and commit)"; status=1; continue; \
		fi; \
		tmp=$$(mktemp -d)/check.svg; \
		$(MMDC) --input $$mmd --output $$tmp --outputFormat svg --quiet; \
		if ! diff -q $$tmp $$svg >/dev/null; then \
			echo "stale:   $$svg (re-render with \`make\` and commit)"; status=1; \
		fi; \
	done; \
	exit $$status

clean:
	rm -f $(SVG_FILES)
