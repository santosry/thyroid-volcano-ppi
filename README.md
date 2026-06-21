# thyroid-volcano-ppi

**THCA Differential Expression & Protein-Protein Interaction Network**

Analysis of thyroid carcinoma (THCA) transcriptomic data from TCGA & GTEx, focused on the thyroid hormone signaling pathway (KEGG hsa04919).

[![R ≥ 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## Scientific Focus

1. **Differential expression**: THCA tumors vs normal thyroid (GTEx) — limma + empirical Bayes
2. **Volcano Plot**: DEG visualization with statistical thresholds, Cell Press editorial standard
3. **PPI Network**: STRING v12.0 protein-protein interaction network of DEGs
4. **Hub identification**: Centrality-based ranking (betweenness, degree, closeness, hub score)

---

## Repository Structure

```
thyroid-volcano-ppi/
├── README.md
├── LICENSE
├── .gitignore
├── run_pipeline.R
├── R/
│   ├── 00_setup.R              # Parameters, packages, Cell Press colors/typography
│   ├── 01_functions.R          # Core functions (KEGG, STRING, network, layout eval)
│   ├── 02_import.R             # Data loading & quality control
│   ├── 03_deg.R                # Differential expression (limma)
│   ├── 04_volcano.R            # ★ Figure 1: Volcano Plot
│   └── 05_ppi.R                # ★ Figure 2: PPI Network
├── data/
│   ├── raw/XENA_THCA.tsv       # Input expression matrix
│   ├── processed/              # Intermediate data
│   └── string_cache/           # STRING cache
├── scripts/download_data.R     # Xena Browser download helper
├── results/
│   ├── figures/                # PNG 600dpi figures
│   ├── tables/                 # TSV documentation tables
│   └── network/                # PPI metadata tables
├── docs/                       # Supplementary documentation
├── logs/                       # Execution logs + sessionInfo()
└── tests/                      # Test scripts
```

---

## Data Source

**UCSC Xena Browser** — TCGA THCA + GTEx Thyroid RNA-seq (TOIL recompute pipeline)

The expression matrix **must be downloaded manually** from Xena Browser:

1. Go to: https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426
2. Click the **Download** button (top-right corner)
3. Select **"Download current visualization data"**
4. Save as: `data/raw/XENA_THCA.tsv`

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

## Installation

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

---

## Usage

```bash
Rscript run_pipeline.R
```

**Runtime**: ~3–5 minutes (STRING/KEGG API calls). Internet connection required.

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

---

## Output Tables

| Table | Content |
|-------|---------|
| `T01_sample_composition.tsv` | Sample counts by condition, study, tissue type |
| `T02_deg_summary.tsv` | DEG analysis parameters and counts |
| `T03_deg_full_results.tsv` | Complete limma results (119 genes) |
| `T04_top20_degs.tsv` | Top 20 DEGs by \|log₂FC\| |
| `T05_kegg_missing_genes.tsv` | KEGG pathway genes not in expression data |
| `T06_hub_proteins.tsv` | Hub proteins — centrality metrics |
| `T07_kegg_degs_ppi.tsv` | KEGG DEGs with PPI centrality (integrated) |
| `N01_string_mapping.tsv` | Gene→STRING protein ID mapping |
| `N02_string_interactions.tsv` | Filtered PPI edges |
| `N03_centrality_metrics.tsv` | Full centrality metrics |
| `N04_network_summary.tsv` | Global network statistics |

---

## Figure Standards

Both figures follow **Cell Press** publication guidelines:

| Property | Specification |
|----------|---------------|
| Typography | Sans-serif, 8pt, consistent across figures |
| Background | White, no grid, no box |
| Palette | Deep carmine (Up), Dark steel blue (Down), Light grey (NS) |
| Format | PNG 600 dpi only |
| Volcano | 180 × 150 mm, open axes, inset legend with counts |
| PPI Network | 180 × 165 mm, auto-selected layout, hub-highlighted |

---

## Reproducibility

- `set.seed(42)` at initialization
- All parameters centralized in `R/00_setup.R`
- All paths via `here::here()` — no absolute paths
- `sessionInfo()` captured to `logs/` after each run
- Pipeline is fully modular — each `R/` script runs independently

---

## License

MIT License — see [LICENSE](LICENSE)

---

## Citation

- **Xena Browser**: Goldman et al. (2020) *Nature Biotechnology* 38:675–678
- **limma**: Ritchie et al. (2015) *Nucleic Acids Research* 43:e47
- **STRING**: Szklarczyk et al. (2023) *Nucleic Acids Research* 51:D638–D646
- **TCGA**: Cancer Genome Atlas Research Network (2014) *Cell* 159:676–690

---

## Audit Report

### Line-by-Line Code Audit (2026-06-21)

**Auditor scope**: All 6 R scripts (R/00_setup.R through R/05_ppi.R), run_pipeline.R, scripts/download_data.R.

#### Critical Fixes Applied

| # | File | Line(s) | Issue | Resolution |
|---|------|---------|-------|------------|
| 1 | 01_functions.R | 52-61 | `select()` unqualified → masked by `AnnotationDbi::select` | All occurrences → `dplyr::select()` |
| 2 | 05_ppi.R | 45 | `components()` unqualified → masked | → `igraph::components()` |
| 3 | 05_ppi.R | 48 | `degree()` unqualified → potential mask | → `igraph::degree()` |
| 4 | 01_functions.R | 95 | `hub_score()` deprecated in igraph 2.0.3 | → `igraph::hub_score()` |
| 5 | 00_setup.R | 7-10 | Bioconductor packages auto-installed via `install.packages()` (fails) | → `BiocManager::install()` |
| 6 | 00_setup.R | 75-82 | `CELL_THEME` defined but overridden in both plot modules (dead code) | Removed; each module has its own theme |
| 7 | 01_functions.R | 40 | `map_string_ids(genes, annot_df, ...)` — `genes` param unused, reads from `annot_df` | Removed unused parameter |
| 8 | 04_volcano.R | 49 | KEGG highlight filter: `"NS & in_kegg" == "TRUE"` — nonsensical comparison | Fixed to `regulation != "NS" & in_kegg` |
| 9 | 05_ppi.R | 89-131 | Layout computed twice: once for evaluation, once for plotting | Single computation; evaluation uses same `evaluate_layout()` |
| 10 | 05_ppi.R | 151 | `geom_node_text(data = . %>% filter(...))` — fragile inline function | → `data = . %>% dplyr::filter(...)` with explicit namespace |
| 11 | 04_volcano.R | 82 | Legend positions: `y_max * 0.055`, `y_max * 0.11` — arbitrary multipliers | → Data-relative positioning with `y_lim * 0.058` |
| 12 | 04_volcano.R | 74 | `panel.border` added AND `axis.line` removed — non-standard Cell Press | → Open axes with `axis.line`, no `panel.border` |
| 13 | 02_import.R | 28 | No check for duplicate sample IDs | Added `anyDuplicated()` guard |
| 14 | 02_import.R | 32 | `storage.mode(expr) <- "numeric"` without type coercion validation | Added `is.numeric()` guard |
| 15 | 02_import.R | 47 | No NA proportion check in expression data | Added `na_frac` check with warning threshold |

#### Namespace Conflicts Identified

| Package | Exported Symbol | Conflicts With | Resolution |
|---------|----------------|----------------|------------|
| `AnnotationDbi` | `select` | `dplyr::select` | All → `dplyr::select` qualified |
| `igraph` | `components` | `clusterProfiler::components` | All → `igraph::components` qualified |
| `igraph` | `degree` | Potential future conflict | Qualified as `igraph::degree` |
| `igraph` | `betweenness` | No conflict (safe) | Qualified for consistency |
| `igraph` | `closeness` | No conflict (safe) | Qualified for consistency |
| `igraph` | `hub_score` | Deprecated → `hits_scores` | Using `igraph::hub_score` with warning suppression |

#### Dead Code Removed

| Location | Code | Reason |
|----------|------|--------|
| 00_setup.R | `CELL_THEME` definition | Overridden in both plot modules |
| 00_setup.R | `kegg_ring` color | Unused after volcano redesign |
| 00_setup.R | `repr.plot.width/height` options | Not used |
| 05_ppi.R | Duplicate layout computation | Computed once, stored, reused |
| 05_ppi.R | `nicely` layout candidate | Redundant; covered by `layout_nicely` fallback |

#### Dependency Audit

| Package | Used? | Justification |
|---------|-------|---------------|
| `STRINGdb` | ✗ | REMOVED — pure REST API used |
| `plotly` | ✗ | REMOVED — no 3D network |
| `scales` | ✗ | REMOVED — manual rescale |
| `htmlwidgets` | ✗ | REMOVED — no interactive output |
| `UpSetR` | ✗ | REMOVED — out of scope |
| `pheatmap` | ✗ | REMOVED — no heatmaps |
| `shapviz` | ✗ | REMOVED — no ML |
| `xgboost` | ✗ | REMOVED — out of scope |
| `caret` | ✗ | REMOVED — out of scope |

#### Portability Audit

| Check | Status |
|-------|--------|
| No hardcoded absolute paths | ✓ `here::here()` throughout |
| No Windows-specific paths | ✓ Forward slashes only |
| No `setwd()` | ✓ Project-relative |
| Package auto-install | ✓ CRAN + Bioconductor handled |
| Data file documented | ✓ Manual download instructions + bookmark |
| Session info captured | ✓ `sessionInfo()` to `logs/` |

#### Statistical Audit

| Check | Status |
|-------|--------|
| Multiple testing correction | ✓ Benjamini-Hochberg (limma default) |
| Expression filter before testing | ✓ >0.5 in ≥10% samples |
| log₂ scale validated | ✓ max ≤ 30, non-integer fraction ≥ 1% |
| Contrast design | ✓ intercept-free + explicit contrast |
| Empirical Bayes moderation | ✓ `eBayes()` applied |
| STRING score threshold justified | ✓ 700 = high confidence |
| Hub criteria documented | ✓ Top 25% betweenness OR degree ≥ 3 |

---

*Pipeline maintained by [@santosry](https://github.com/santosry)*
