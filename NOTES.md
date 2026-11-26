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

- Rolled back to sha 18505db6d2ee0d7e9fd009124c3df2bd6e735757 : started 9:10 AM, smoke passed 9:11 AM (approximately 1 min)
- Rolled forward to sha 2414b8c123fa5cec25847828b3891044c73378b7 : 1 min
- During the rollback, the database stayed on the newer schema. Why is that safe here?
  The rollback changes only the application code, not the database schema.
  The older application version is compatible with the newer backward-compatible database schema.

### Where my secrets live

- Neon string: GitHub Secret DATABASE_URL + Render environment. Not in Git, not in the image.
- Render deploy hook: GitHub Secret RENDER_DEPLOY_HOOK only.

### Monitoring

- UptimeRobot checks /health every 5 minutes; alerts go to my email.
- One thing that would make my live app faster on its first request: Use an always-on Render instance to avoid cold starts and improve the first request response time.


## D06 · Collecting the corpus

- Start target: PLFS annual reports for 3 years
- Collected today: 10 files, 4770 pages, 260.3 MB (from DATASET.md)
- Doors used: Door 1: URL list using data/sources.csv

### Licence check

| Source | Licence or terms, in my words | May I show full text in answers? |
| MoSPI | Public MoSPI publications. Cite report, table and period. | Full-text reuse permission is not confirmed. Use relevant answers with citations. |
| Microdata | Source identified, but no documents collected from it yet. | Not applicable yet. |

### robots.txt

- Site: https://mospi.gov.in/ . Its robots.txt says: The robots.txt file could not be retrieved as readable text; the server returned the website HTML instead.
- Was anything blocked for my bot? What did I do about it? No. 0 downloads were blocked. The fetcher was configured to respect robots.txt.

### Kill and resume

- Run 1: I pressed Ctrl+C after 4 files
- Run 2: downloaded=4 skipped=6
- Run 3: downloaded=0 skipped=10

### Capacity (from docs/CAPACITY.md)

- Tokens per page, measured: 665
- Full corpus: 5.32 M tokens, 12239 chunks, embedding about Rs 116, vectors 50 MB
- The number that surprised me most, and why: The estimated embedding cost is only Rs 116 for 8,000 pages.
I was surprised because processing such a large dataset is very affordable.

### One thing that went wrong today, and how I fixed it

The first download run was interrupted after 10 seconds. I restarted the fetcher, and it downloaded the remaining 7 files while skipping 3 already downloaded files. On the third run, it skipped all 10 files. There were no partial files, and the resume test passed.

## D07 · Parser comparison

<!-- parsers:start -->
| File | Parsers (A / B) | Pages | A found | B found | Time (A / B) | Better, why |
|---|---|---|---|---|---|---|
| annual-report-2024-25-r-0b3e6b77.pdf | PyMuPDF / pypdf | - | FAILED: no_text_layer | FAILED: no_text_layer | 216.49 s / 201.52 s | Neither: both failed with no_text_layer; OCR is required. |
| annual-report-plfs-2019-20f1-69b67da0.pdf | PyMuPDF / pypdf | 721 | 2,527,975 chars, 1804 headings, 230 tables | 2,279,484 chars, 0 headings, 0 tables | 46.96 s / 160.11 s | PyMuPDF: 2,527,975 chars, 1,804 headings and 230 tables; much faster (46.96s vs 160.11s). |
| annualreportplfs2021-22f1-13e1cf12.pdf | PyMuPDF / pypdf | 758 | 2,726,897 chars, 1799 headings, 275 tables | 2,337,986 chars, 2 headings, 0 tables | 42.60 s / 50.11 s | PyMuPDF: 2,726,897 chars, 1,799 headings and 275 tables; faster (42.60s vs 50.11s). |
| annual-report-plfs-2020-21-0-7338f625.pdf | PyMuPDF / pypdf | 754 | 2,622,392 chars, 1609 headings, 212 tables | 2,313,189 chars, 0 headings, 0 tables | 38.70 s / 47.04 s | PyMuPDF: more characters, 1,609 headings and 212 tables; faster (38.70s vs 47.04s). |
| annualreport-plfs2023-24l2-79e6f100.pdf | PyMuPDF / pypdf | 572 | 1,753,667 chars, 4413 headings, 135 tables | 1,526,468 chars, 0 headings, 0 tables | 30.76 s / 27.20 s | PyMuPDF: 4,413 headings and 135 tables; slightly slower than pypdf. |
| ar-plfs-2022-23n-04c5cd2e.pdf | PyMuPDF / pypdf | 435 | 1,402,875 chars, 3837 headings, 131 tables | 1,178,623 chars, 0 headings, 0 tables | 58.37 s / 21.83 s | PyMuPDF: 3,837 headings and 131 tables; better structure despite slower processing. |
| annual-report-plfs-2018-19-hl-c37c1220.pdf | PyMuPDF / pypdf | 618 | 2,194,062 chars, 1105 headings, 206 tables | 1,906,645 chars, 0 headings, 0 tables | 20.01 s / 108.11 s | PyMuPDF: 1,105 headings and 206 tables; much faster (20.01s vs 108.11s). |
| annual-report-plfs-2017-18-31052019-6173cf25.pdf | PyMuPDF / pypdf | 643 | 3,675,031 chars, 330 headings, 650 tables | 1,814,629 chars, 0 headings, 0 tables | 777.13 s / 123.00 s | PyMuPDF: 650 tables and 330 headings; pypdf is faster (123s vs 777.13s). |
| annualreport-2023-24-5dd24e0d.pdf | PyMuPDF / pypdf | 116 | 242,742 chars, 249 headings, 31 tables | 228,027 chars, 1 headings, 0 tables | 28.71 s / 4.37 s | PyMuPDF: 249 headings and 31 tables; pypdf is faster but detects no tables. |
| press-note-ar-plfs-2023-24-22092024-3136d6c4.pdf | PyMuPDF / pypdf | 10 | 74,027 chars, 33 headings, 12 tables | 16,755 chars, 0 headings, 0 tables | 1.09 s / 0.53 s | PyMuPDF: 33 headings and 12 tables; pypdf extracts fewer characters and detects no tables. |
<!-- parsers:end -->

### Parsing stats

- Files in the manifest: 10 · parsed: 9 · failed: 1 · pages in Postgres: 4,627
- Parsing coverage: 90% of files

### Failures by reason

| Reason | Files | What I did |
|---|---:|---|
| no_text_layer | 1 | Identified as a scanned/image-based PDF; OCR is required |

- The one I fixed: **None**. File `annual-report-2024-25-r-0b3e6b77.pdf`, reason `no_text_layer`, fix: Not fixed because the PDF contains image-based pages without a text layer; OCR is required.

### What I saw when I read my parsed pages

- A page where the heading path is right (document, page, path): MoSPI Annual Report 2023-24, page 112, Other Activities → Redressal of Public Grievances → Publications brought out during 2023-24 by Social Statistics Division.
- Something that came out wrong (document, page, what): PLFS Annual Report 2019-20, page 2, Hindi characters were corrupted and mixed with English text.
- A table: Markdown grid or loose text? (document, page): MoSPI Annual Report 2023-24, page 115, Markdown-like grid with fragmented rows and columns.

### My parser choice

- For PDFs I use **PyMuPDF** because it extracted more characters, headings and tables than pypdf. Across the 9 successfully parsed PDFs, PyMuPDF detected 1,882 tables in total, while pypdf detected zero tables.
- A kind of document in my corpus that neither parser handles well: Scanned/image-based PDFs without a text layer.

### One thing that went wrong today, and how I fixed it

- One PDF could not be parsed because it was image-based and had no text layer. I identified the issue as `no_text_layer`. It remains unresolved because OCR is required for text extraction.


### D08 · LLM gateway

- Primary: gemini-3.5-flash (Gemini) · fallback: openai/gpt-oss-20b (Groq)
- First question on my laptop: first words after 7.05 s, total 9.71 s, tokens in 197 / out 87, cost Rs 0.0000
- Same question on my live URL (second, awake request): first words after 28.41 s. Day 1 target: under 1.5 s

### Tokens: English against Tamil

| Message | tokens in |
|---|---|
| "Hi" (baseline: mostly my system prompt) | 173 |
| The English sentence | 181 |
| The same sentence in Tamil | 189 |

- The Tamil message needs about 2 times the tokens of the English one.

### What the model does without my documents

- Question 6 ("How many jobs will Chennai IT companies add next year?"): Yes, it admitted it can't know. Its exact words: "I am not sure."
- A detail it got wrong or invented (question → what it said → what is true): No invented figures observed.
- The off-topic question: Yes, it declined in one sentence.

### Fallback and circuit breaker

- With the primary broken: provider Groq , fallback YES , first words after 4.23 s
- The question at which "llm call gemini … error" stopped appearing in the log: number 4

### The bill

- /v1/usage today: calls 25 , errors 6 , fallbacks 7 , cost Rs 0.032
- Average per answered question: Rs 0.0017 (my Day 1 target: under Rs 0.50)

### One thing that went wrong today, and how I fixed it

- Gemini gemini-3.8-flash failed; changed to gemini-3.5-flash, tested fallback and circuit breaker, then restored Gemini successfully.
