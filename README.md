# thyroid-volcano-ppi

**Differential Expression & Protein-Protein Interaction Network Analysis in Thyroid Carcinoma (THCA)**

Transcriptomic analysis of THCA using TCGA & GTEx data, focused on the thyroid hormone signaling pathway (KEGG hsa04919).

[![R ≥ 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![renv](https://img.shields.io/badge/renv-locked-blueviolet)](renv.lock)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](Dockerfile)

---

## Authors

| Author | ORCID | Affiliation |
|--------|-------|-------------|
| **Ryan de Paulo Santos** | [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001) | 1 |
| **Letícia Maria Dias Freitas** | [0009-0009-9930-9588](https://orcid.org/0009-0009-9930-9588) | 2 |
| **Thaís Faria Coutinho da Silva Pereira** | [0009-0005-7091-2480](https://orcid.org/0009-0005-7091-2480) | 3 |

---

## Author Contributions (CRediT Taxonomy)

| Author | Contribution |
|--------|-------------|
| **Ryan de Paulo Santos** | Conceptualization (Lead); Methodology (Lead); Software (Lead); Formal Analysis (Lead); Data Curation (Lead); Validation (Lead); Visualization (Lead); Investigation (Lead); Writing – Original Draft (Lead); Project Administration (Lead); Writing – Review & Editing (Supporting) |
| **Letícia Maria Dias Freitas** | Methodology (Equal); Software (Equal); Formal Analysis (Equal); Data Curation (Equal); Validation (Equal); Visualization (Equal); Investigation (Equal); Writing – Original Draft (Equal); Writing – Review & Editing (Supporting) |
| **Thaís Faria Coutinho da Silva Pereira** | Validation (Supporting); Writing – Review & Editing (Lead); Supervision (Supporting); Domain Expertise and Biological Interpretation (Lead); Biological Validation (Lead); Scientific Review (Lead) |

---

## Scientific Focus

1. **Differential expression**: THCA tumors vs normal thyroid (GTEx) — limma + empirical Bayes
2. **Volcano Plot**: DEG visualization with statistical thresholds, Nature Communications editorial standard
3. **PPI Network**: STRING v12.0 protein-protein interaction network of DEGs
4. **Hub identification**: Centrality-based ranking (betweenness, degree, closeness, hub score)

---

## ⚠ Required Data File

**The pipeline WILL NOT run without `data/raw/XENA_THCA.tsv`.**

This file contains the gene expression matrix (783 samples × 121 KEGG hsa04919 pathway genes) extracted from UCSC Xena Browser.

### How to obtain the file:

#### Option 1 — Automatic download (recommended):
```bash
Rscript scripts/download_data.R
```

#### Option 2 — Manual download:
1. Access Xena Browser via the bookmark:
   **[bit.ly/thyroid-volcano-ppi-data](https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426)**
2. Click the **"Download"** button (top-right corner)
3. Select **"Download current visualization data"**
4. Save exactly as: **`data/raw/XENA_THCA.tsv`**

> **⚠ If the file is missing, the pipeline will abort with an explanatory message and attempt automatic download.**

| Property | Value |
|----------|-------|
| Source | TCGA THCA + GTEx normal thyroid |
| Pipeline | TOIL RSEM recompute |
| Values | log₂(norm_count + 1) |
| Samples | 783 (279 Normal + 504 THCA) |
| Genes | 121 (KEGG hsa04919 pathway) |
| Bookmark | `c486b845ee2e750c3a9d2fc5145c8426` |
| Citation | Goldman et al. (2020) *Nature Biotechnology* 38:675–678 |

---

## Data Availability

- **Raw data**: UCSC Xena Browser — bookmark `c486b845ee2e750c3a9d2fc5145c8426` (public access)
- **Processed data**: Available in this repository under `results/tables/` and `results/network/`
- **Figures**: `results/figures/` — PNG 600 dpi, publication-ready
- **Computational environment**: Locked via `renv.lock`; Docker container available

---

## Repository Structure

```
thyroid-volcano-ppi/
├── README.md                   ← You are here
├── LICENSE                     (MIT)
├── CITATION.cff                Citation metadata
├── Dockerfile                  Reproducible container
├── renv.lock                   Exact R package versions
├── .gitignore
├── run_pipeline.R              ← Master runner (Rscript run_pipeline.R)
├── R/
│   ├── 00_setup.R              Parameters, packages, colors & typography
│   ├── 01_functions.R          Core functions (KEGG, STRING, network, layout)
│   ├── 02_import.R             Data import & quality control
│   ├── 03_deg.R                Differential expression (limma)
│   ├── 04_volcano.R            ★ Figure 1: Volcano Plot
│   ├── 05_ppi.R                ★ Figure 2: PPI Network
│   └── 06_supplementary.R      Supplementary tables S1–S4
├── data/
│   ├── raw/XENA_THCA.tsv       ← ⚠ REQUIRED FILE (download first)
│   ├── processed/              Intermediate data
│   └── string_cache/           STRING cache
├── scripts/
│   ├── download_data.R         Automatic Xena Browser download
│   └── setup_renv.R            renv initialization script
├── results/
│   ├── figures/                PNG 600 dpi figures
│   ├── tables/                 TSV tables (7 main + 4 supplementary)
│   └── network/                PPI network metadata
├── docs/                       Supplementary documentation
├── logs/                       Execution logs + sessionInfo()
└── tests/
    ├── testthat.R              Test runner
    └── testthat/                Unit tests (testthat)
```

---

## Installation

### Option 1 — renv (recommended for full reproducibility)

```r
# Install renv if needed
install.packages("renv")

# Restore exact environment from lockfile
renv::restore()
```

### Option 2 — Manual installation

```r
# CRAN
install.packages(c(
  "here", "dplyr", "stringr", "tibble", "tidyr", "purrr", "readr",
  "ggplot2", "ggrepel", "igraph", "ggraph", "httr", "jsonlite"
))

# Bioconductor
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c("limma", "KEGGREST", "org.Hs.eg.db", "AnnotationDbi"))
```

### Option 3 — Docker

```bash
docker build -t thyroid-volcano-ppi .
docker run --rm -v "$(pwd)/data:/home/rstudio/thyroid-volcano-ppi/data" \
           -v "$(pwd)/results:/home/rstudio/thyroid-volcano-ppi/results" \
           thyroid-volcano-ppi
```

---

## Usage

```bash
# 1. Ensure the data file exists:
ls -lh data/raw/XENA_THCA.tsv

# 2. (Optional) Restore the renv environment:
R -e 'renv::restore()'

# 3. Run the pipeline:
Rscript run_pipeline.R
```

**Runtime**: ~3–5 minutes (internet connection required for STRING/KEGG APIs).

**What the pipeline does:**
1. Checks that `XENA_THCA.tsv` exists (aborts with instructions if missing)
2. Auto-installs packages if needed
3. Imports and validates data (quality control)
4. Runs differential expression analysis (limma)
5. Generates the Volcano Plot (Figure 1)
6. Builds the PPI network via STRING API (Figure 2)
7. Exports 11 result and metadata tables
8. Saves `sessionInfo()` for full reproducibility

---

## Analysis Parameters

| Parameter | Value | Justification |
|-----------|-------|---------------|
| \|log₂FC\| threshold | 1.0 | Standard 2-fold change |
| FDR threshold | 0.05 | Benjamini-Hochberg, 5% FDR |
| Expression filter | >0.5 in ≥10% | log₂ detection floor |
| STRING score | ≥700 | High confidence (top ~25%) |
| KEGG pathway | hsa04919 | Thyroid hormone signaling |
| STRING version | 12.0 | Latest stable release |
| Seed | 42 | Full reproducibility |

---

## Output Tables

### Main tables

| Table | Content |
|-------|---------|
| `T01_sample_composition.tsv` | Sample counts by condition, study, and tissue type |
| `T02_deg_summary.tsv` | DEG analysis parameters and counts |
| `T03_deg_full_results.tsv` | Complete limma results (119 genes) |
| `T04_top20_degs.tsv` | Top 20 DEGs by \|log₂FC\| |
| `T05_kegg_missing_genes.tsv` | KEGG pathway genes absent from expression data |
| `T06_hub_proteins.tsv` | Hub proteins — centrality metrics |
| `T07_kegg_degs_ppi.tsv` | KEGG DEGs with PPI centrality (integrated) |

### PPI network metadata

| File | Content |
|------|---------|
| `N01_string_mapping.tsv` | Gene → STRING protein ID mapping |
| `N02_string_interactions.tsv` | Filtered PPI edges |
| `N03_centrality_metrics.tsv` | Full centrality metrics |
| `N04_network_summary.tsv` | Global network statistics |

### Supplementary tables (S1–S4)

| Table | Content |
|-------|---------|
| `S1_computational_environment.tsv` | Computational environment (R, packages, versions) |
| `S2_external_databases.tsv` | External databases used |
| `S3_pipeline_audit_trail.tsv` | Complete pipeline audit trail |
| `S4_ai_assisted_tasks.tsv` | AI-assisted tasks and human validation |

---

## Figure Standards

Both figures follow **Nature Communications / Cell Press** editorial guidelines:

| Property | Specification |
|----------|---------------|
| Format | PNG 600 dpi |
| Volcano | 180 × 150 mm |
| PPI Network | 180 × 180 mm |
| Typography | Sans-serif (Arial/Helvetica), 14pt base |
| Background | White, open axes |
| Palette | Blue `#4477AA` (Upregulated), Magenta `#AA4488` (Downregulated) |
| Labels | ggrepel with leader lines, most relevant genes only |
| PPI Network | Fruchterman-Reingold layout, walktrap communities |

---

## Reproducibility

- `set.seed(42)` at initialization
- All parameters centralized in `R/00_setup.R`
- All paths via `here::here()` — no absolute paths
- `sessionInfo()` captured to `logs/` after each run
- **`renv.lock`** — exact versions of all R packages
- **`Dockerfile`** — full reproducible Linux environment
- **`CITATION.cff`** — standardized citation metadata
- Fully modular pipeline — each `R/` script can run independently

---

## Tests

```r
# Run all unit tests
testthat::test_dir("tests/testthat")

# Or via script
source("tests/testthat.R")
```

Tests cover: expression scale validation (`validate_expression_scale`), KEGG gene extraction (`fetch_kegg_genes`), graph construction (`build_igraph`), centrality metrics (`compute_centrality`), and TSV export (`export_tsv`).

---

## AI Use Disclosure

Artificial Intelligence (Grok, xAI) was used as a methodological, computational, and documentation support tool in this project, including: R code optimization, namespace auditing, structured documentation generation, and reproducibility best-practice suggestions. **No scientific conclusions were derived by AI.** Full responsibility for all results, analyses, biological interpretations, and final content remains exclusively with the human authors. For complete details, see table `S4_ai_assisted_tasks.tsv`.

---

## License

MIT License — see [LICENSE](LICENSE)

---

## How to Cite

```bibtex
@software{santos2026thyroid,
  title        = {thyroid-volcano-ppi: Differential Expression and
                  PPI Network Analysis in Thyroid Carcinoma (THCA)},
  author       = {Ryan de Paulo Santos and Letícia Maria Dias Freitas
                  and Thaís Faria Coutinho da Silva Pereira},
  year         = {2026},
  url          = {https://github.com/santosry/thyroid-volcano-ppi},
  note         = {v1.0.0}
}
```

See also `CITATION.cff` for structured citation metadata.

---

## References

- **Xena Browser**: Goldman et al. (2020) *Nature Biotechnology* 38:675–678
- **limma**: Ritchie et al. (2015) *Nucleic Acids Research* 43:e47
- **STRING**: Szklarczyk et al. (2023) *Nucleic Acids Research* 51:D638–D646
- **TCGA**: Cancer Genome Atlas Research Network (2014) *Cell* 159:676–690
- **KEGG**: Kanehisa et al. (2023) *Nucleic Acids Research* 51:D587–D592
- **igraph**: Csárdi et al. (2024) *CRAN*
- **ggraph**: Pedersen (2024) *CRAN*

---

## Audit Trail

### Source Code Audit (June 21, 2026)

**Scope**: All 7 R scripts, `run_pipeline.R`, `scripts/download_data.R`.

#### Critical Fixes Applied

| # | File | Issue | Resolution |
|---|------|-------|------------|
| 1 | `01_functions.R` | `select()` masked by `AnnotationDbi::select` | → `dplyr::select()` |
| 2 | `05_ppi.R` | `components()` / `degree()` unqualified | → `igraph::components()`, `igraph::degree()` |
| 3 | `01_functions.R` | `hub_score()` deprecated (igraph 2.0.3) | → `igraph::hits_scores()` |
| 4 | `00_setup.R` | Bioconductor via `install.packages()` | → `BiocManager::install()` |
| 5 | `00_setup.R` | `CELL_THEME` defined but overridden (dead code) | Removed |
| 6 | `01_functions.R` | Unused parameter in `map_string_ids()` | Removed |
| 7 | `04_volcano.R` | KEGG filter with incorrect comparison | Fixed |
| 8 | `05_ppi.R` | Layout computed twice | Single computation |
| 9 | `02_import.R` | No duplicate ID or NA checks | Added `anyDuplicated()`, `na_frac` |
| 10 | `run_pipeline.R` | `stopifnot()` without helpful message | Robust check + auto-download |
| 11 | `04_volcano.R` | Gray background, small fonts | White background, 14pt base, 5.2mm labels |
| 12 | `05_ppi.R` | No communities, small font | Walktrap, 14pt base, 4.8mm labels |

#### Namespace Conflicts

| Package | Symbol | Resolution |
|---------|--------|------------|
| `AnnotationDbi` | `select` | → `dplyr::select` |
| `igraph` | `components`, `degree` | → `igraph::*` |

#### Reproducibility Checklist

| Check | Status |
|-------|--------|
| No absolute paths | ✓ `here::here()` |
| Fixed seed | ✓ `set.seed(42)` |
| Centralized parameters | ✓ `00_setup.R` |
| Session info captured | ✓ `logs/session_info.txt` |
| Version lockfile | ✓ `renv.lock` |
| Docker container | ✓ `Dockerfile` |
| Unit tests | ✓ `tests/testthat/` |
| Data documented | ✓ Bookmark + auto-download |
| Citation metadata | ✓ `CITATION.cff` |

---

*Pipeline maintained by [Ryan de Paulo Santos](https://github.com/santosry) — ORCID: [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001)*
