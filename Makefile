# SHELL=/bin/bash
PY_FOLDERS = src/*.py
PY_FOLDERS_TESTS =

.PHONY: all venv clean format lint test security

VENV_PATH = .venv/bin/python3
APP_NAME = webcolors

all: format lint test security

venv:
	find . -type d -name ".venv" -exec rm -rf {} +
	uv venv

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name "*.egg" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".ruff_cache" -exec rm -rf {} +

clean-all: clean venv

format:
	uv run ruff format --preview src/

lint: format
	uv run ruff check --preview src/
	uv run ty check src/

test:
	uv run pytest -v ./tests/

security:
	uv run bandit -r src/
	uv run pip-audit
	hadolint Dockerfile
	trivy fs --skip-dirs=./.venv/ .
