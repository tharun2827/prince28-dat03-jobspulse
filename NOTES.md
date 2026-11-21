# Engineering notes: JobsPulse

## D03 · PostgreSQL

### Migrations (upgrade, downgrade, upgrade)

```text
D:\Documents\GenAI\prince28-dat03-jobspulse>uv run alembic downgrade -1
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running downgrade 484a50902b76 -> eb6379f3aea2, add gin index on metadata

D:\Documents\GenAI\prince28-dat03-jobspulse>uv run alembic current
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
eb6379f3aea2

D:\Documents\GenAI\prince28-dat03-jobspulse>uv run alembic upgrade head
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade eb6379f3aea2 -> 484a50902b76, add gin index on metadata

D:\Documents\GenAI\prince28-dat03-jobspulse>uv run alembic history
eb6379f3aea2 -> 484a50902b76 (head), add gin index on metadata
<base> -> eb6379f3aea2, create documents and pages
```

### The loader is idempotent

```text
run 1: records=20 inserted=17 updated=0 unchanged=3

run 2: records=20 inserted=0 updated=0 unchanged=20

run 3 (after editing one record): records=20 inserted=0 updated=1 unchanged=19
```

### EXPLAIN for ?report=VALUE

```text
-- 1) What the planner chooses on its own:
Seq Scan on documents  (cost=0.00..11.00 rows=1 width=36) (actual time=1.199..1.199 rows=0.00 loops=1)
  Filter: (metadata @> '{"report": "VALUE"}'::jsonb)
  Rows Removed by Filter: 20
  Buffers: shared read=2 dirtied=2
Planning:
  Buffers: shared hit=143 read=8 dirtied=1
Planning Time: 5.270 ms
Execution Time: 1.229 ms

-- 2) Seq scan switched off, to prove the index can be used:
Bitmap Heap Scan on documents  (cost=12.81..16.82 rows=1 width=36) (actual time=1.500..1.501 rows=0.00 loops=1)
  Recheck Cond: (metadata @> '{"report": "VALUE"}'::jsonb)
  Buffers: shared hit=1 read=2
  ->  Bitmap Index Scan on ix_documents_metadata_gin  (cost=0.00..12.81 rows=1 width=0) (actual time=1.476..1.476 rows=0.00 loops=1)
        Index Cond: (metadata @> '{"report": "VALUE"}'::jsonb)
        Index Searches: 1
        Buffers: shared hit=1 read=2
Planning:
  Buffers: shared hit=1
Planning Time: 0.088 ms
Execution Time: 1.546 ms
```

Why did the planner choose a Seq Scan on my table? (2 lines, your own words)
The table contains only 20 records, so a Sequential Scan is cheaper than using an index. PostgreSQL can scan the entire table quickly without the extra overhead of an index lookup.

When would it switch to the GIN index? (1 line)
It may switch to the GIN index when the table grows larger and the query becomes selective enough that an index scan is cheaper than scanning the entire table.


## D04 · Docker, Compose and tests

### The image

```text
docker images jobspulse:dev
                                                                                                          i Info →   U  In Use
IMAGE           ID             DISK USAGE   CONTENT SIZE   EXTRA
jobspulse:dev   e78d58bead90        300MB           70MB


docker run --rm jobspulse:dev id

uid=999(app) gid=999(app) groups=999(app)
```

- Size: 300 MB (target: under 400 MB)
- First build: 37.3 s. After changing one line of code: 14.5 s.
- Which step said CACHED, and why?
- The `uv sync --locked --no-install-project` step shows CACHED because the dependencies haven't changed, so Docker reused the previously built dependency layer.

### The stack

```text
docker compose ps -a

NAME                  IMAGE                    COMMAND                  SERVICE   CREATED         STATUS                     PORTS
jobspulse-api-1       jobspulse-api            "sh -c 'exec uvicorn…"   api       2 minutes ago   Up 2 minutes (healthy)     0.0.0.0:8000->8000/tcp, [::]:8000->8000/tcp
jobspulse-db-1        pgvector/pgvector:pg17   "docker-entrypoint.s…"   db        2 minutes ago   Up 2 minutes (healthy)     0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
jobspulse-migrate-1   jobspulse-migrate        "sh -c 'alembic upgr…"   migrate   2 minutes ago   Exited (0) 2 minutes ago
jobspulse-redis-1     redis:7-alpine           "docker-entrypoint.s…"   redis     2 minutes ago   Up 2 minutes (healthy)     0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp

docker compose logs migrate   (first up, then after down + up)

migrate-1  | INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
migrate-1  | INFO  [alembic.runtime.migration] Will assume transactional DDL.
migrate-1  | records=20 inserted=0 updated=0 unchanged=20
```

### Breaking the database on purpose

```text
db stopped:  /health → {"status":"ok","app":"jobspulse","env":"local"}
db stopped:  /ready  → {"status":"not_ready","checks":{"database":false}}
db started:  /ready  → {"status":"ready","checks":{"database":true}}
```

Why should a load balancer stop sending traffic here but not restart the app?

The load balancer should stop sending traffic because the database is unavailable, making the app temporarily not ready. It should not restart the app because the application is still running correctly and will recover when the database is available again.

### Tests and coverage

```text
uv run poe test              → 16 passed in 0.37s
uv run poe test-integration  → 7 passed in 3.83s
coverage TOTAL, unit only    →

============================================================================ tests coverage =============================================================================
___________________________________________________________ coverage: platform win32, python 3.12.16-final-0 ____________________________________________________________

Name                              Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------
src\jobspulse\api\deps.py            25      9      0      0    64%   21-22, 26, 31-36
src\jobspulse\api\middleware.py      21      3      0      0    86%   22-24
src\jobspulse\config.py              22      1      0      0    95%   34
src\jobspulse\db\repository.py       34     22     10      0    27%   16, 29-37, 42, 47-62, 65-66
src\jobspulse\db\url.py              12      0      4      1    94%   10->12
src\jobspulse\logging_setup.py       22      1      6      1    93%   27
-----------------------------------------------------------------------------
TOTAL                               254     36     26      2    83%

10 files skipped due to complete coverage.
16 passed, 7 skipped in 3.22s

coverage TOTAL, with integration tests →

============================================================================ tests coverage =============================================================================
___________________________________________________________ coverage: platform win32, python 3.12.16-final-0 ____________________________________________________________

Name                              Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------
src\jobspulse\api\deps.py            25      2      0      0    92%   35-36
src\jobspulse\api\middleware.py      21      3      0      0    86%   22-24
src\jobspulse\db\repository.py       34      3     10      2    89%   32, 36, 66
src\jobspulse\logging_setup.py       22      7      6      0    54%   16-28
-----------------------------------------------------------------------------
TOTAL                               254     15     26      2    92%

12 files skipped due to complete coverage.
23 passed in 7.38s

```

Two files or lines my coverage report says are never run, and whether they matter:

Some lines in `logging_setup.py` and `store.py` are not covered by tests.
They may contain optional logging or unused functionality, but should be tested if they are important to application behavior.


## D05 · CI/CD and going live

- Live URL: https://jobspulse.onrender.com
- CI run for pull request 1: https://github.com/tharun2827/prince28-dat03-jobspulse/actions
- First deploy that ran by itself: https://github.com/tharun2827/prince28-dat03-jobspulse/actions/runs/
- Merge clicked at 8:03→ "Smoke test passed" 8:04 → lead time: 1 min

### Smoke test output from that CD run

```text

ok /health -> 200, version 1ec9c4485c2cb38e8a65e6d57b1c7ed4ffc71326
ok /ready -> 200 {'status': 'ready', 'checks': {'database': True}}
ok /v1/documents?limit=1 -> 200
Smoke test passed

```

### Rollback drill

- Rolled back to sha Not performed : started Not recorded, smoke passed Not recorded (Not applicable)
- Rolled forward to sha Not performed : Not applicable
- During the rollback, the database stayed on the newer schema. Why is that safe here?
The newer database schema is safe only if it remains backward-compatible with the previous application version.
This compatibility must be verified before considering the rollback safe.

### Where my secrets live

- Neon string: GitHub Secret DATABASE_URL + Render environment. Not in Git, not in the image.
- Render deploy hook: GitHub Secret RENDER_DEPLOY_HOOK only.

### Monitoring

- UptimeRobot checks /health every 5 minutes; alerts go to my email.
- One thing that would make my live app faster on its first request: Use an always-on Render instance to avoid cold starts and improve the first request response time.
