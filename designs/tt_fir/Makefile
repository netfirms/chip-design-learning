# tt_fir: the FIR filter as a Tiny Tapeout project (Module 9, capstone).
# See mk/design.mk for the targets (make sim, lint, synth, synth-sky130, pnr, ...)
# and README.md for the Tiny Tapeout targets below.
TOP := tt_um_chipcourse_fir
RTL := src/project.v src/fir.v
TB  := tb/tt_fir_tb.v
include ../../mk/design.mk

# ---- Tiny Tapeout --------------------------------------------------------
#   make tt-test                 cocotb test in test/, as the template's CI runs it
#   make tt-export TT_REPO=dir   copy the project into a clone of your repo made
#                                from the Tiny Tapeout template (fir.v is copied,
#                                not linked, because the template needs real files)
TT_REPO ?=
.PHONY: tt-test tt-export

tt-test:
	$(MAKE) -C test -B

tt-export:
	@test -n "$(TT_REPO)" || { echo "usage: make tt-export TT_REPO=../my-tt-repo"; exit 1; }
	@test -f "$(TT_REPO)/info.yaml" || { echo "$(TT_REPO) is not a Tiny Tapeout template clone (no info.yaml)"; exit 1; }
	mkdir -p $(TT_REPO)/src $(TT_REPO)/test $(TT_REPO)/docs
	cp info.yaml $(TT_REPO)/
	cp -L src/project.v src/fir.v $(TT_REPO)/src/
	cp test/Makefile test/tb.v test/test.py $(TT_REPO)/test/
	cp docs/info.md $(TT_REPO)/docs/
	@echo "Copied. Keep the template's src/config.json and .github/. Next: rename the top module, fill in info.yaml, commit, push."
