.PHONY: help

APP_NAME ?= `grep 'app:' ../mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' ../mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`
COOKIE ?= 'monster'

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		--build-arg COOKIE=$(COOKIE) \
    -f Dockerfile \
		-t $(APP_NAME):$(APP_VSN)-$(BUILD) \
		-t $(APP_NAME):latest ..

up: ## Bring up the production docker-compose environment
	docker-compose -p $(APP_NAME)_prod up -d

down: ## Stop the production docker-compose environment
	docker-compose -p $(APP_NAME)_prod down

logs: ## Tail the production docker-compose logs
	docker-compose -p $(APP_NAME)_prod logs -f

console: ## Attach a remote console to the docker-compose prod environment
	docker-compose -p $(APP_NAME)_prod exec web bin/$(APP_NAME) remote_console
