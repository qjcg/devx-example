out_dev := docker-compose.yaml
out_prod := build

.PHONY: all
all: build-dev build-prod

.PHONY: build-dev
build-dev:
	devx build dev

.PHONY: build-prod
build-prod:
	devx build prod

.PHONY: clean
clean:
	rm -rf $(out_dev) $(out_prod)
