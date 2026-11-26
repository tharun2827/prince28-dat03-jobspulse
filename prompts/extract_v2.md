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

- `doc_kind`: The document type. Use one of the allowed values.
- `year`: The publication year explicitly stated in the document. Use null if it is not stated. Do not use the survey period's ending year as the publication year.
- `language`: The main language of the document.
- `summary`: One or two sentences describing the document's contents.
- `topics`: 1 to 6 short subject topics covered by the document.
- `period`: The survey or reference period explicitly covered by the document.
- `state`: State or UT names only when explicitly identified as the document's specific coverage. Do not list every state just because a national report contains state-level tables.
- `area`: Geographic coverage categories explicitly shown.
- `gender`: Gender categories explicitly shown.
- `age_group`: Age categories explicitly shown.

Important extraction rules:

- Read the report's overview, highlights, tables, table headings, notes and appendices before extracting metadata.
- Capture `area`, `gender` and `age_group` whenever the document explicitly includes those dimensions, even if they appear only in tables.
- For `area`, use only: `rural`, `urban`, `rural and urban`, or `other`. If the report explicitly contains rural, urban and combined rural+urban estimates, include the applicable values.
- For `gender`, use short values such as `male` and `female` when explicitly shown.
- For `age_group`, capture actual age categories shown, such as `15-29 years`, `15 years and above`, or `all ages`.
- Do not leave a field empty when the corresponding dimension is explicitly present.
- Do not invent values or infer details the report does not support.
- Keep list values short and factual, not sentences.
