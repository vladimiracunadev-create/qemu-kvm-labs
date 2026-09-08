PYTHON ?= python3

.PHONY: install check setup verify test verify-all clean
install:
	$(PYTHON) -m pip install -e .
check:
	bash scripts/check-host.sh
setup:
	bash scripts/setup.sh
verify:
	bash scripts/verify.sh
test:
	bash scripts/test.sh
verify-all:
	bash scripts/verify-all.sh
clean:
	bash scripts/cleanup.sh --all
