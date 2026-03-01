.PHONY: help install dev stop check seed neutrality

help:
	@echo "Available commands:"
	@echo "  install      - Install dependencies for api, etl, and frontend"
	@echo "  dev          - Start the development environment with Docker Compose"
	@echo "  stop         - Stop the development environment"
	@echo "  check        - Run static analysis and type checking"
	@echo "  seed         - Generate the synthetic demo dataset"
	@echo "  neutrality   - Run neutrality, privacy, and compliance gates"

install:
	@echo "--- Installing API dependencies ---"
	(cd api && uv sync --dev)
	@echo "--- Installing ETL dependencies ---"
	(cd etl && uv sync --dev)
	@echo "--- Installing frontend dependencies ---"
	(cd frontend && npm install)

dev:
	@echo "--- Starting development environment ---"
	@echo "Run 'cp .env.example .env' and set your NEO4J_PASSWORD if you haven't."
	docker-compose -f infra/docker-compose.yml up -d

stop:
	@echo "--- Stopping development environment ---"
	docker-compose -f infra/docker-compose.yml down

check:
	@echo "--- Running quality checks ---"
	(cd api && ruff check . && mypy .)
	(cd etl && ruff check . && mypy .)

seed:
	@echo "--- Generating synthetic demo dataset ---"
	python3 scripts/generate_demo_dataset.py
	@echo "NOTE: This command generates 'data/demo/synthetic_graph.json'."
	@echo "The mechanism to load this data into the database is not specified in the project."

neutrality:
	@echo "--- Neutrality Audit & Public Release Gates ---"
	python3 scripts/check_public_privacy.py --repo-root .
	python3 scripts/check_compliance_pack.py --repo-root .
	python3 scripts/check_open_core_boundary.py --repo-root .
	@echo "--- All neutrality and privacy gates passed ---"
