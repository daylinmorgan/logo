SRC := $(shell find logo/ -type f)
CONDA := source $$(conda info --base)/etc/profile.d/conda.sh; conda activate;
SVGS := $(shell find -type f -wholename "./docs/*.svg")
PNGS := $(patsubst ./docs/svg/%.svg,./docs/png/%.png, $(SVGS))
REV := $(shell date +'%Y.%m.%d-' )$(shell git describe --always --dirty | sed s'/dirty/dev/')


.PHONY: all
all:
	@echo "==> Generating SVGs <=="
	@mkdir -p docs/svg
	@$(MAKE) svgs
	@echo "==> Generating PNGs <=="
	@mkdir -p docs/png
	@$(MAKE) docs/png/index.html
	@$(MAKE) pngs

.PHONY: pngs
pngs: $(PNGS) ## generate all of the logo pngs

docs/png/index.html: docs/index.html
	@cat docs/index.html |\
		sed 's/svg/png/g' |\
		sed 's/\.\/png/\./g' |\
		sed s'/My Logos/My Logos but PNG/g' \
		> docs/png/index.html

docs/png/%.png: docs/svg/%.svg
	@inkscape --export-filename=$@ $<

.PHONY: logos
svgs: $(SRC) ## generate all of the logo svgs
	./generate-all.py $(REV)

.PHONY: lint
lint: ## apply isort/black/flake8
	@isort logo
	@black logo
	@flake8 logo

.PHONY: bootstrap pdm-env conda-env
bootstrap: pdm-env ## bootstrap the conda environment

conda-env:
	$(CONDA) CONDA_ALWAYS_YES="true" mamba create -p ./env python --force

pdm-env: conda-env
	$(CONDA) conda activate ./env; \
		pip install pdm; \
		pdm install

.PHONY: clean
clean: ## remove old files
	rm -f *.svg *.png
	rm -f docs/*.svg
	rm -f docs/svg/*
	rm -f docs/png/*

-include .task.cfg.mk
