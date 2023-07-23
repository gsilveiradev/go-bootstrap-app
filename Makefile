.PHONY: all build help coverage lint test vet build directories

SHELL=/bin/bash

## Folder with all reports [tests,coverate,lint]
FOLDER_REPORT = ./reports

## Folder with binary [compiled file]
FOLDER_BIN = ./bin

## Folder to be used to download necessary tools
FOLDER_TOOLS := $(shell pwd)/tools

### Variables
PROJECT_NAME := go-bootstrap-app
VENDORFLAGS  ?= -mod=vendor
GOFLAGS  	 = -v
GOPATH   	 = $(shell go env GOPATH)
GOJUNIT  	 = $(FOLDER_TOOLS)/go-junit-report
GOCILINT 	 = ${FOLDER_TOOLS}/golangci-lint
MKDIR_P 	 = mkdir -p
LDFLAGS 	 += -s -w
LDFLAGS 	 += -X "main.BuildTime=$(shell date -u '+%Y-%m-%dT%H:%M:%S.%3N%z')"

## Latest version of linter.  https://github.com/golangci/golangci-lint/releases
## 02/04/2023 - v1.52.2
GOLANGCI_LINT_VERSION = v1.52.2

### COMMANDS
all: build

help: ## Display this help screen
	@awk 'BEGIN {FS = ":.*?##"; printf "Usage: make <target>\n"} /^[a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## Create required directories
directories: $(FOLDER_REPORT)
$(FOLDER_REPORT):
	$(MKDIR_P) $@

coverage: directories ## Generate code coverage report
	go clean -testcache
	go test $(GOFLAGS) $(VENDORFLAGS) -covermode=count -coverprofile="$(FOLDER_REPORT)/unit_coverage.out" ./...
	GOFLAGS=$(VENDORFLAGS) go tool cover -func="$(FOLDER_REPORT)/unit_coverage.out"
	GOFLAGS=$(VENDORFLAGS) go tool cover -html="$(FOLDER_REPORT)/unit_coverage.out" -o "$(FOLDER_REPORT)/unit_coverage.html"

lint: directories ## Generate lint report
	$(GOCILINT) --config ./.golangci.yml run --exclude-use-default=false
	$(GOCILINT) --config ./.golangci.yml run --exclude-use-default=false --out-format=checkstyle ./... > $(FOLDER_REPORT)/linter.xml

test: directories $(GOJUNIT) ## Run unittests
	go clean -testcache
	go test $(GOFLAGS) $(VENDORFLAGS) -race ./... | tee test.out ; [ $${PIPESTATUS[0]} -eq 0 ]
	cat test.out | $(GOJUNIT) > $(FOLDER_REPORT)/test.xml
	rm -f test.out

vet: ## Vet examines Go source code and reports suspicious constructs, such as Printf calls whose arguments do not align with the format string
	go vet ./...

clean: ## Remove previous build
	rm -rf "$(FOLDER_BIN)"
	rm -rf "$(FOLDER_REPORT)"
	rm -rf "${FOLDER_TOOLS}"
	@find . -name ".DS_Store" -print0 | xargs -0 rm -f
	go clean -i ./...

build: $(FOLDER_BIN)/$(PROJECT_NAME) ## Build/install the binary file

$(FOLDER_BIN)/$(PROJECT_NAME):
	go build -o $(FOLDER_BIN)/$(PROJECT_NAME) $(GOFLAGS) -ldflags '$(LDFLAGS)' .

tools: ## Install all tools in ./tools
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b ${FOLDER_TOOLS} $(GOLANGCI_LINT_VERSION)
	(cd /; GOBIN=${FOLDER_TOOLS} GO111MODULE=on go install github.com/jstemmer/go-junit-report@latest)

mod: tools ## run go mod tidy and go mod vendor
	go mod tidy
	go mod vendor