# JobsPulse

Answers employment and wage questions from MoSPI's Periodic Labour Force Survey reports and bulletins, by state, gender, age and area, with table citations.

**Status:** Day 1 foundation (FastAPI skeleton, quality gates). Live URL from Day 5.

## Who it's for

Policy researcher at a Chennai think tank writing on youth unemployment in Tamil Nadu.

## The problem

PLFS employment statistics vary based on definitions, reporting periods, and geographical areas. Usual status and current weekly status can produce different unemployment estimates. Annual, quarterly, and monthly reports may show different figures for the same indicator without proper verification, researchers may compare inconsistent data and draw misleading conclusions.

## Data sources

PLFS annual reports (2017-18 onward), quarterly bulletins, monthly bulletins, and concepts and definitions documents.

- https://mospi.gov.in/
- https://microdata.gov.in/
- Terms: Public MoSPI publications. Cite report, table and period.

## Hardest problem (my interview story)

Definitions and periods: usual status (ps+ss) vs current weekly status, annual vs quarterly urban vs monthly bulletins. Retrieval must filter on status type and period, and every number must be returned with them.

## Signature feature

Indicator explorer: choose indicator, state, gender and age, and see a time series with each point linked to its table.

## Target metric

Number + definition + period correct for 90%+ of 50 questions.

## Performance targets

The response-time targets were adjusted to 500 ms for record lookups and 5 seconds for complete answers to provide realistic performance goals during the initial development and testing stages.

## Run it locally

```bash
uv sync
cp .env.example .env   # Windows: copy .env.example .env
uv run uvicorn jobspulse.api.main:create_app --factory --reload
```

Then open http://localhost:8000/docs

## Checks

```bash
uv run pytest
uv run ruff check .
```

## Run locally in one command

You need Docker Desktop running. From a fresh clone:

```bash
docker compose up --build
```

This starts Postgres (with pgvector), Redis, runs the migrations and loads the sample data once, then starts the API.

- API docs: http://localhost:8000/docs
- Liveness: http://localhost:8000/health
- Readiness (checks the database): http://localhost:8000/ready

Stop with `Ctrl+C`, then `docker compose down`. Add `-v` to also delete the database volume.

## Develop and test

| Task | Mac / Linux | Windows |
|---|---|---|
| Run the API with reload | `make dev` | `uv run poe dev` |
| Unit tests (no network) | `make test` | `uv run poe test` |
| Integration tests (needs `docker compose up`) | `make test-integration` | `uv run poe test-integration` |
| Coverage report | `make cov` | `uv run poe cov` |
| Lint and format check | `make lint` | `uv run poe lint` |
