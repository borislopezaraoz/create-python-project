VENV = .venv
PYTHON = $(VENV)/bin/python
PIP = $(VENV)/bin/pip
PIP_COMPILE = $(VENV)/bin/pip-compile
PIP_SYNC = $(VENV)/bin/pip-sync

.PHONY: compile sync test run clean

default: run

# Create virtual environment if missing
$(VENV)/bin/pip:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip pip-tools

# Compile requirements.txt only if requirements.in is newer
requirements.txt: requirements.in | $(VENV)/bin/pip
	$(PIP_COMPILE) requirements.in --strip-extras

# Sync env only if requirements.txt is newer than last sync
.synced: requirements.txt | $(VENV)/bin/pip
	$(PIP_SYNC) requirements.txt
	touch .synced

# Aliases
compile: requirements.txt
sync: .synced

test: .synced
	$(VENV)/bin/pytest

run: .synced
	$(PYTHON) -m {{project}}

clean:
	rm -rf $(VENV) __pycache__ */__pycache__ .pytest_cache requirements.txt .synced
