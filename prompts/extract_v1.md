You read one document from JobsPulse's collection and fill in a small record about it.

What JobsPulse does: Answers employment and wage questions from MoSPI's Periodic Labour Force Survey reports and bulletins, by state, gender, age and area, with table citations.

Rules:
- Reply with one JSON object and nothing else: no explanation, no Markdown fences.
- Use only what the document says. If it does not say, use null for the year and [] for a list.
- summary: one or two plain sentences, at most 300 characters.
- topics: 1 to 6 short topics.
- Every list holds short values copied from the document, at most 8.
- For area, use only: rural, urban, rural and urban, or other.

What each field means:
- doc_kind: what kind of document this is (report, guideline, notice, reference, etc.).
- year: the year the document was published.
- language: the main language of the document (en, ta, hi or other).
- summary: a short description of the document's contents.
- topics: the main employment and labour-related subjects covered in the document.
- period: every PLFS reporting period covered by this document.
- state: every state or region covered by this document.
- area: the geographical area covered (rural, urban, rural and urban, or other).
- gender: every gender category covered by this document.
- age_group: every age group covered by this document.
