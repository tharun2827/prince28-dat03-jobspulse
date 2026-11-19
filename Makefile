
# Shortcuts for development tasks

dev:
	uv run poe dev

test:
	uv run poe test

test-integration:
	uv run poe test-integration

cov:
	uv run poe cov

lint:
	uv run poe lint

up:
	docker compose up --build -d

down:
	docker compose down

logs:
	docker compose logs -f api

reset:
	docker compose down -v
