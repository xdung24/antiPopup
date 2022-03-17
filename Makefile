GO=go
DOCKER=docker
APPNAME=xdung24/anti-popup

.PHONY: help

help: ## Show this help message.
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

run-unit-tests: ## Run unit tests
	$(GO) test ./

build-docker-image: ## Build docker image
	@echo 'Building $(APPNAME)'
	$(DOCKER) image build --tag="$(APPNAME):latest" .

push-docker-image: ## Push docker image
	@echo 'Pushing $(APPNAME)'
	$(DOCKER) image push "$(APPNAME):latest"