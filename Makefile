# Top-level Makefile: forwards targets to a design directory.
#
#   make sim                      # counter testbench
#   make sim DESIGN=fir           # any design under designs/
#   make synth DESIGN=counter     # pick a design explicitly
#   make check                    # lint + sim + synth for every design (what CI runs)
#   make check-sky130             # sky130 synthesis for every design
#   make check-cocotb             # Python (cocotb) testbenches for every design
#   make doctor                   # check which tools are installed
#   make slides                   # learning decks as HTML (slides/*.html), needs Node.js
#   make slides-site              # deck index site in build/slides-site/, needs Node.js + Chrome
#   make slides-pdf               # learning decks as PDF (slides/pdf/), needs Node.js + Chrome
#   make ppa                      # area/timing/power dashboard for every design (ppa/index.html)

DESIGN  ?= counter
DESIGNS := $(notdir $(wildcard designs/*))
TARGETS := all sim waves lint verilator cocotb synth show synth-sky130 pnr pnr-gui plot clean

.PHONY: $(TARGETS) check check-sky130 check-cocotb doctor slides slides-site slides-pdf ppa

$(TARGETS):
	$(MAKE) -C designs/$(DESIGN) $@

check:
	@for d in $(DESIGNS); do $(MAKE) -C designs/$$d lint sim synth || exit 1; done

check-sky130:
	@for d in $(DESIGNS); do $(MAKE) -C designs/$$d synth-sky130 || exit 1; done

# Designs without a cocotb/ folder are skipped
check-cocotb:
	@for d in $(DESIGNS); do \
		if [ -d designs/$$d/cocotb ]; then $(MAKE) -C designs/$$d cocotb || exit 1; \
		else echo "check-cocotb: $$d has no cocotb/ testbench, skipped"; fi; \
	done

# PPA dashboard from whatever has been built: sky130 synthesis always runs,
# timing and power appear for designs where `make pnr` has run.
ppa: check-sky130
	python3 python/ppa_dashboard.py --out ppa

doctor:
	@for t in iverilog vvp verilator yosys gtkwave dot python3 cocotb-config docker openroad klayout; do \
		if command -v $$t >/dev/null 2>&1; then printf '  ok       %s\n' $$t; \
		else printf '  missing  %s\n' $$t; fi; \
	done

# ---- Learning decks (Marp) -------------------------------------------------
MARP       ?= npx --yes @marp-team/marp-cli@4.5.1
DECKS      := $(basename $(notdir $(wildcard slides/[0-9]*.md)))
MARP_FLAGS := --theme-set slides/theme/course.css --html --allow-local-files

# HTML goes next to each deck so the relative image paths keep working.
# stdin is redirected because marp reads Markdown from a pipe when it has one.
slides:
	@for d in $(DECKS); do $(MARP) $(MARP_FLAGS) slides/$$d.md -o slides/$$d.html < /dev/null || exit 1; done

# Browsable site: an index page with a card per deck, the decks, their images
# and title-slide thumbnails, in build/slides-site/ (open index.html).
SITE := build/slides-site
slides-site: slides
	@python3 scripts/build_slides_site.py
	@mkdir -p $(SITE)/thumbs
	@for d in $(DECKS); do $(MARP) $(MARP_FLAGS) --image png --image-scale 0.5 slides/$$d.md -o $(SITE)/thumbs/$$d.png < /dev/null || exit 1; done

slides-pdf:
	@mkdir -p slides/pdf
	@for d in $(DECKS); do $(MARP) $(MARP_FLAGS) --pdf slides/$$d.md -o slides/pdf/$$d.pdf < /dev/null || exit 1; done
