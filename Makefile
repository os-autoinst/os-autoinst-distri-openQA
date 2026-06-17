# PROVE: Test application for Perl tests
PROVE ?= tools/prove_wrapper
PROVE_JOBS ?= $(shell nproc 2>/dev/null || echo 1)
PROVE_JOBS_ARGS ?= -j$(PROVE_JOBS)

all: help

.PHONY: help
help: ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test-checkstyle
test-checkstyle: test-yaml ## Run checkstyle checks

.PHONY: test-author
test-author: test-checkstyle test-perl-author ## Run all tests

.PHONY: test-yaml
test-yaml: ## Run yamllint checks
	yamllint --strict ./

.PHONY: test-perl-author
test-author: ## Run author tests
	"${PROVE}" $(PROVE_JOBS_ARGS) -l -r xt/

