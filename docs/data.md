# Data and reproduction

## Sources and public extract

The original University of California, Merced team delivery from the 2018 CCES contains 1,625 pre-election respondents; the matched delivery contains 1,000 of those respondents. The survey was administered by YouGov. See the [official study guide](https://sda.berkeley.edu/sdaweb/docs/cces2018/DOC/CCES%2BGuide%2B2018.pdf) for fieldwork, matching, and weighting procedures.

`data/raw/cces2018.csv` contains one row per respondent, a synthetic sequential `row_id`, a `matched` indicator, and 17 numeric source fields. There are no email addresses, IP addresses, free text, or original respondent identifiers in this extract. No analysis records are dropped. The full original files remain separately retained by the authors; the export does not modify them.

The [dictionary](data_dictionary.csv) records original variable labels and value labels. Empty cells in the CSV mean system missing. Numeric skip and not-asked codes are retained for transparent reconstruction and are handled in `R/data.R`, not silently converted during export. The [source manifest](source_manifest.csv) records SHA-256 hashes, rows, and columns of both original SAV files. The original full DTA and SAV agree on the retained analysis fields; the DTA requires its legacy character encoding when imported.

The supplied team weight is present exactly for the matched sample. It is positive for every matched respondent and missing otherwise. The analysis never imputes weights for unmatched respondents. The complete original questionnaires, codebook, and stimulus images are in `data/materials/`. Extra income images with no assigned arm are preserved as materials and do not become invented experimental observations.

## Coding and joins

- Original deliveries are joined by their unique vendor `caseid` before that identifier is omitted from the extract. Every matched respondent joins once; all 17 retained fields agree between deliveries.
- Highway responses: 1 Smith (larger allocation), 2 Williams (smaller allocation), 8 skipped, 9 not asked. Pre-election `pid7` codes 1–3 and 5–7 define Democrats and Republicans including leaners. Other respondents were not asked.
- Income arms: `UCMincrease_treat` codes 1–4 as documented in [design.md](design.md). `tookpost=2` identifies post-election participants. Their post-election party is defined by `CC18_421a` and `CC18_421b`.
- Income support: `25 * (5 - UCMincrease)` for responses 1–5. Binary support is responses 1–2; binary opposition is 4–5. Missing codes never count as opposition.
- Jobs support: `20 * (6 - UCMjobs)` for responses 1–6. Code 8 is skipped and excluded from both means and observed denominators. `UCMjobstreat=1` indicates the Black-advantage version.

Generated sample counts and assignments are in `tabs/sample_flow.csv`, `completion.csv`, `income_routing.csv`, and `party_transition.csv`. The raw extract is an immutable input to the normal build; cleaning creates in-memory columns.

## Reproduction

Install R 4.6.0, GNU Make, XeLaTeX, and `latexmk`, then run:

```sh
make restore
make check
```

`renv.lock` pins R package dependencies. `make check` runs the analysis, figure and table generation, manuscript compilation, linting, and tests. It also regenerates README from `docs/README.md.in` and computed values. `make format` applies the R formatter. No proprietary software, credentials, or network data retrieval is required after installing dependencies.

Authors with the complete original deliveries can optionally regenerate the public extract, dictionary, and manifest:

```sh
Rscript scripts/prepare_data.R /absolute/path/to/original/data
```

This step reads the originals and writes only the public allowlisted outputs. Ordinary reproduction does not need the originals. `private-data/` is ignored by Git. No copy of a full original delivery is required in the public release.

The permutation check uses 9,999 reassignments and seed 20261004. CSV results and TeX fragments are deterministic for the pinned environment. `tabs/session_info.txt` records the actual analysis environment; PDF metadata and platform font rendering can differ between systems without changing estimates.
