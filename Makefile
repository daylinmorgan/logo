
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
	nimble run -- --background none,square,circle --style light,dark --border --output docs/svg
	nimble run -- --background none,square,circle --style light,dark --output docs/svg

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

assets/logo.svg:
	nimble run -- --background circle --style dark --animate --border --output assets/logo.svg

clean: ## remove old files
	rm -f *.svg *.png
	rm -f docs/*.svg
	rm -f docs/svg/*
	rm -f docs/png/*

-include .task.cfg.mk
