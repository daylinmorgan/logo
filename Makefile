SRC = $(shell find logo/ -type f)
CONDA = source $$(conda info --base)/etc/profile.d/conda.sh; conda activate;
SVGS = $(shell find -type f -wholename "./docs/*.svg")
PNGS = $(patsubst ./docs/svg/%.svg,./docs/png/%.png, $(SVGS))
REV := $(shell date +'%Y.%m.%d-' )$(shell git describe --always --dirty | sed s'/dirty/dev/')


.PHONY: all
all:
	@echo "==> Generating SVGs <=="
	@$(MAKE) svgs
	@echo "==> Generating PNGs <=="
	@$(MAKE) pngs

.PHONY: pngs
## generate all of the logo pngs
pngs: $(PNGS)

./docs/png/%.png: ./docs/svg/%.svg
	convert $< -scale 1024 $@

.PHONY: logos
## generate all of the logo svgs
svgs: $(SRC)
	./generate-all.py $(REV)

.PHONY: lint
## apply isort/black/flake8
lint:
	@isort logo
	@black logo
	@flake8 logo

.PHONY: bootstrap pdm-env conda-env
## bootstrap the conda environment
bootstrap: pdm-env

conda-env:
	$(CONDA) CONDA_ALWAYS_YES="true" mamba create -p ./env python --force

pdm-env: conda-env
	$(CONDA) conda activate ./env; \
		pip install pdm; \
		pdm install

.PHONY: clean
## remove old files
clean:
	rm -f *.svg *.png
	rm -f docs/*.svg
	rm -f docs/svg/*
	rm -f docs/png/*


FILL = 15
.PHONY: help
## Display this help screen
help: ## try `make help`
	@awk '/^[a-z.A-Z_-]+:/ { helpMessage = match(lastLine, /^##(.*)/); \
    if (helpMessage) { helpCommand = substr($$1, 0, index($$1, ":")-1); \
    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); printf "\033[36m%-$(FILL)s\033[0m%s\n"\
    , helpCommand, helpMessage;}} { lastLine = $$0 }' $(MAKEFILE_LIST)
