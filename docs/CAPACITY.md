# Capacity plan: JobsPulse

Full corpus target: All annual reports + quarterly and monthly bulletins (8,000+ pages)

<!-- generated:start -->
## Measured on my start corpus (2026-11-23 13:27 UTC)

| What | Value |
|---|---|
| Files | 10 |
| Size on disk | 260.3 MB |
| Pages (PDF pages + 1 per 3,000 characters of text/HTML) | 4,770 |
| Characters of text | 12,691,639 |
| Estimated tokens (characters / 4) | 3,172,910 |
| Tokens per page | 665 |
| PDFs with almost no text (scanned? OCR is Day 7) | 1 |
| Files not measured (zip, xlsx, unreadable) | 0 |

## Estimate for the full corpus (target: 8,000 pages)

| What | How | Value |
|---|---|---|
| Scale factor | target / measured | x 1.7 |
| Tokens | measured tokens x scale | 5.32 M |
| Raw files | measured MB x scale | 437 MB |
| Chunks | tokens / 500 x 1.15 overlap | 12,239 |
| Embedding cost, one time | tokens x 1.15 x $0.2 per 1M | $1.22 = Rs 116 |
| Vector storage | chunks x 1024 numbers x 4 bytes | 50 MB |
| Text in Postgres | characters x scale x 1.2 | 26 MB |

Assumptions: 4 characters per token, 500-token chunks, 1024-dimension embeddings at $0.2 per 1M tokens, Rs 95 per US dollar.
<!-- generated:end -->


## What I conclude

1. Is embedding cost a problem for this product?

   No. The estimated one-time embedding cost for the 8,000-page corpus is only $1.22 (approximately Rs 116), so it is affordable.

2. Do the vectors and text fit in my free Postgres?

   The estimated vector storage is 50 MB and text storage is 26 MB, totaling approximately 76 MB. This excludes database indexes and metadata overhead. I will check the available storage in my Postgres dashboard before confirming the free-tier capacity.

3. Which number above am I least sure about, and how will I measure it better?

   The estimated token count is the least certain because it uses 4 characters per token. I will measure actual token counts using the tokenizer on extracted document text.

4. What changes if the corpus grows 10 times?

   The corpus would grow to approximately 80,000 pages, 53.2 million tokens and 122,390 chunks.
   Raw files would require approximately 4.37 GB, vector storage 500 MB, text storage 260 MB and one-time embedding cost approximately $12.20 (Rs 1,159). More storage and processing capacity would be required.
