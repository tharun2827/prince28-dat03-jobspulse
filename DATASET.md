# Dataset: JobsPulse

Answers employment and wage questions from MoSPI's Periodic Labour Force Survey reports and bulletins, by state, gender, age and area, with table citations.

- **Start target:** PLFS annual reports for 3 years
- **Full target:** All annual reports + quarterly and monthly bulletins (8,000+ pages)
- **Collected by:** `scripts/fetch.py` as `examate-student-bot` (https://github.com/tharun2827/prince28-dat03-jobspulse): robots.txt respected, at most 4 requests at once, 0.5 s between requests to one site.

## Where the documents come from

- https://mospi.gov.in/
- https://microdata.gov.in/

## Terms I follow

Public MoSPI publications. Cite report, table and period.

- Every answer links to the original document.
- No personal data is collected.

<!-- generated:start -->
## Sources (generated 2026-11-23 13:27 UTC by scripts/dataset_report.py)

| Source | Licence / terms | Files | MB | Pages* | How | Fetched | Example URL |
|---|---|---|---|---|---|---|---|
| mospi | Public MoSPI publication. Cite report, table and period. | 10 | 260.3 | 4,770 | http | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual%20Report%2C%20PLFS%202017-18_31052019.pdf?download=1 |

**Total:** 10 files, 260.3 MB, 4,770 pages. Not downloaded: 0 blocked by robots.txt, 0 failed.

*Pages = PDF pages, plus one page per 3,000 characters of text or HTML.

## Files (first 10 of 10)

The complete list, with a sha256 fingerprint of every file, is `data/manifest.jsonl`.

| # | Title / file | Source | Pages | Fetched | URL |
|---|---|---|---|---|---|
| 1 | MoSPI Annual Report 2024-25 | mospi | 143 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual_Report_2024-25_R.pdf |
| 2 | PLFS Annual Report 2017-18 | mospi | 643 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual%20Report%2C%20PLFS%202017-18_31052019.pdf?download=1 |
| 3 | PLFS Annual Report 2018-19 Highlights | mospi | 618 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual_Report_PLFS_2018_19_HL.pdf |
| 4 | PLFS Annual Report 2019-20 | mospi | 721 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual_Report_PLFS_2019_20F1.pdf |
| 5 | PLFS Annual Report 2020-21 | mospi | 754 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/Annual_Report_PLFS_2020%2021_0.pdf |
| 6 | MoSPI Annual Report 2023-24 | mospi | 116 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/AnnualReport_2023-24.pdf |
| 7 | PLFS Annual Report 2023-24 | mospi | 572 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/AnnualReport_PLFS2023-24L2.pdf |
| 8 | PLFS Annual Report 2021-22 | mospi | 758 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/AnnualReportPLFS2021-22F1.pdf |
| 9 | PLFS Annual Report 2022-23 | mospi | 435 | 2026-11-23 | https://mospi.gov.in/sites/default/files/publication_reports/AR_PLFS_2022_23N.pdf |
| 10 | PLFS 2023-24 Press Note | mospi | 10 | 2026-11-23 | https://mospi.gov.in/sites/default/files/press_release/Press_note_AR_PLFS_2023_24_22092024.pdf |
<!-- generated:end -->

## Known gaps

- The start target of PLFS annual reports for 3 years has been achieved (2021-22, 2022-23 and 2023-24).
- Additional PLFS documents include reports from 2017-18, 2019-20 and 2020-21, and the 2018-19 Highlights PDF.
- Quarterly and monthly PLFS bulletins are not yet collected.
- The full target of 8,000+ pages is not yet reached (currently 4,770 pages).
- One PDF has almost no extractable text and may require OCR.
- Two collected documents are general MoSPI annual reports, and one is a PLFS press note, not a PLFS annual report.
