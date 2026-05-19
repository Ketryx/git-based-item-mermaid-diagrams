MMDC ?= ./node_modules/.bin/mmdc
MMDC_FLAGS := --outputFormat svg --quiet --puppeteerConfigFile puppeteer-config.json

MMD_FILES := $(shell find items -name '*.mmd')
SVG_FILES := $(MMD_FILES:.mmd=.svg)

.PHONY: all clean check

all: $(SVG_FILES)

%.svg: %.mmd
	$(MMDC) --input $< --output $@ $(MMDC_FLAGS)

# CI safety net: every .mmd must have a committed .svg next to it, and the .mmd
# must still render without errors. We don't byte-compare against the committed
# .svg because mermaid's text layout depends on the host's available fonts —
# the same .mmd renders to slightly different SVG coordinates on macOS vs Linux.
# The pre-commit hook is the real guarantee that .svg matches .mmd at commit time.
check:
	@status=0; \
	for mmd in $(MMD_FILES); do \
		svg=$${mmd%.mmd}.svg; \
		if [ ! -f $$svg ]; then \
			echo "missing: $$svg (run \`make\` and commit)"; status=1; continue; \
		fi; \
		tmp=$$(mktemp -d)/check.svg; \
		if ! $(MMDC) --input $$mmd --output $$tmp $(MMDC_FLAGS); then \
			echo "render-error: $$mmd"; status=1; \
		fi; \
	done; \
	exit $$status

clean:
	rm -f $(SVG_FILES)
