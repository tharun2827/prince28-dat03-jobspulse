# Requirements: JobsPulse

## Functional (what it does)

1. A user can ask a question in plain English and get an answer drawn from my sources.
2. Every answer cites the document and page (or section) it came from.
3. If the documents do not contain the answer, the product says "I don't know" instead of guessing.
4. Signature feature: Indicator explorer: choose indicator, state, gender and age, and see a time series with each point linked to its table.
5. A user can browse and search the underlying records through GET /v1/documents.

## Non-functional (how well, with numbers)

| # | Quality | Target | How I will measure it |
|---|---|---|---|
| 1 | Speed: record lookups | p95 under 500 ms for GET /v1/documents | load test (Week 6) |
| 2 | Speed: answers | p95 under 5 s for a full answer; first token under 2 s | traces (Week 5) |
| 3 | Accuracy | Number + definition + period correct for 90%+ of 50 questions. | golden question set (Weeks 4 and 5) |
| 4 | Cost | under Rs 0.50 per answered question | llm_calls table (Week 2) |
| 5 | Availability | 99% monthly uptime of the live URL | uptime monitor from Day 5 |
