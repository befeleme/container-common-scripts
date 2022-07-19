SHELL := /usr/bin/env bash

all:
	@echo >&2 "Only 'make shellcheck', 'make test', or 'make test-openshift-4' are allowed"

.PHONY: test all check-failures check-squash check-latest-imagestream test test-openshift-4

TEST_LIB_TESTS = \
	path_foreach \
	random_string \
	test_npm \
	image_availability \
	public_image_name

$(TEST_LIB_TESTS):
	@echo "  RUN TEST '$@'" ; \
	$(SHELL) tests/test-lib/$@ || $(SHELL) -x tests/lib/$@

test-lib-foreach:

check-test-lib: $(TEST_LIB_TESTS)

test: check-failures check-squash check-latest-imagestream
	TESTED_SCENARIO=test tests/remote-containers.sh

test-openshift-4: check-failures check-squash check-latest-imagestream
	TESTED_SCENARIO=test-openshift-4 tests/remote-containers.sh

shellcheck:
	./run-shellcheck.sh `git ls-files *.sh`

pre-commit-check:
	pre-commit run --all
	[[ -d "./.git/hooks" && -n `find ./.git/hooks/ -name "pre-commit"` ]] || \
	  echo "Note: Install pre-commit hooks by 'pre-commit install' and you'll never have to run this check manually again."

check-failures: check-test-lib
	cd tests/failures/check && make tag && ! make check && make clean
	cd tests/failures/check && ./check_skip_squash.sh

check-squash:
	./tests/squash/squash.sh

check-latest-imagestream:
	cd tests && ./check_imagestreams.sh

check-betka:
	cd tests && ./check_betka.sh
