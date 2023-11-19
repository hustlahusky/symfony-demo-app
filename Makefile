VERSION?=$(shell git describe --tags 2> /dev/null || git rev-parse --short HEAD)

#
# HELPERS
#

##help: print this help message
.PHONY: help
help:
	@echo 'Available targets:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

local.mk:
	@touch $@
	@echo "DOCKER_ALPINE_REPO=" >> $@
	@echo "DOCKER_USER_ID=" >> $@
	@echo "DOCKER_GROUP_ID=" >> $@

-include local.mk

#
# DOCKER TARGETS
#

##docker-build-prod: build docker images for production
.PHONY: docker-build-prod
docker-build-prod: BAKE_TARGETS = prod

##docker-build-dev: build docker images for development
.PHONY: docker-build-dev
docker-build-dev: BAKE_TARGETS = dev

.PHONY: @docker-build
@docker-build docker-build-dev docker-build-prod:
	@ \
	$(if $(DOCKER_ALPINE_REPO),ALPINE_REPO=$(DOCKER_ALPINE_REPO),) \
	$(if $(DOCKER_USER_ID),USER_ID=$(DOCKER_USER_ID),) \
	$(if $(DOCKER_GROUP_ID),GROUP_ID=$(DOCKER_GROUP_ID),) \
	docker buildx bake -f docker-bake.hcl $(BAKE_TARGETS)

.env:
	$(error "Configure .env file manually. Look at .env.example")

docker-compose.override.yml:
	$(error "Configure docker-compose.override.yml file manually. Look at docker-compose.example.yml")

##docker-up: spin up development environment
.PHONY: docker-up
docker-up: .env docker-compose.yml docker-compose.override.yml docker-build-dev
	docker compose up -d

##docker-down: stop development environment
.PHONY: docker-down
docker-down: docker-compose.yml
	docker compose down

##docker-clean: stop development environment and remove docker volumes
.PHONY: docker-clean
docker-clean: docker-compose.yml
	docker compose down -v
