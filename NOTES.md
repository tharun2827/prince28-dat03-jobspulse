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
