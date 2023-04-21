
.PHONY: all
all:
	@echo "==> Generating SVGs <=="
	@mkdir -p docs/svg
	@$(MAKE) svgs
	@echo "==> Generating PNGs <=="
	@mkdir -p docs/png
	@$(MAKE) docs/png/index.html
	@$(MAKE) pngs

svgs: ## generate all svgs
	nimble run

pngs: ## generate all of the logo pngs
	nimble pngs

ascii: ## generate all ascii variants
	./scripts/ascii.nims

docs/png/index.html: docs/index.html
	@cat docs/index.html |\
		sed 's/svg/png/g' |\
		sed 's/\.\/png/\./g' |\
		sed s'/My Logos/My Logos but PNG/g' \
		> docs/png/index.html

clean: ## remove old files
	rm -f *.svg *.png
	rm -f docs/*.svg
	rm -f docs/svg/*
	rm -f docs/png/*

-include .task.cfg.mk
