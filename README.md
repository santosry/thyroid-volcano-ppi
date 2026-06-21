# thyroid-volcano-ppi

**THCA Differential Expression & Protein-Protein Interaction Network**

Analysis of thyroid carcinoma (THCA) transcriptomic data from TCGA & GTEx, focused on the thyroid hormone signaling pathway (KEGG hsa04919). Produces publication-quality figures ready for Cell Press journals.

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.XXXXXXX-blue)](https://doi.org/)
[![R ≥ 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## Scientific Focus

1. **Differential expression analysis**: THCA tumors vs normal thyroid tissue (GTEx) using limma
2. **Volcano Plot**: Visualization of differentially expressed genes (DEGs) with statistical thresholds
3. **PPI Network**: STRING v12.0 protein-protein interaction network of DEGs
4. **Hub protein identification**: Centrality-based ranking of key regulatory proteins

---

## Repository Structure

```
thyroid-volcano-ppi/
├── README.md
├── LICENSE
├── .gitignore
├── run_pipeline.R              # Master execution script
│
├── data/
│   ├── raw/                    # Input expression matrix from Xena Browser
│   │   └── XENA_THCA.tsv
│   ├── processed/              # Intermediate processed data
│   └── string_cache/           # STRING database cache (auto-generated)
│
├── R/
│   ├── 00_setup.R              # Parameters, packages, Cell Press visual standards
│   ├── 01_functions.R          # Core functions (KEGG, STRING, network)
│   ├── 02_import.R             # Data loading & quality control
│   ├── 03_deg.R                # Differential expression (limma)
│   ├── 04_volcano.R            # Figure 1: Volcano Plot
│   └── 05_ppi.R                # Figure 2: PPI Network
│
├── scripts/
│   └── download_data.R         # Download Xena Browser expression data
│
├── results/
│   ├── figures/                # Final publication figures (PNG 600dpi)
│   │   ├── Fig1_Volcano_THCA_vs_Normal.png
│   │   └── Fig2_PPI_Network_THCA_DEGs.png
│   ├── tables/                 # Documentation tables (TSV)
│   │   ├── T01_sample_composition.tsv
│   │   ├── T02_deg_summary.tsv
│   │   ├── T03_deg_full_results.tsv
│   │   ├── T04_top20_degs.tsv
│   │   ├── T05_kegg_missing_genes.tsv
│   │   ├── T06_hub_proteins.tsv
│   │   └── T07_kegg_degs_ppi.tsv
│   └── network/                # PPI network metadata
│       ├── N01_string_mapping.tsv
│       ├── N02_string_interactions.tsv
│       ├── N03_centrality_metrics.tsv
│       └── N04_network_summary.tsv
│
├── docs/                       # Supplementary documentation
├── logs/                       # Execution logs and session info
└── tests/                      # Test scripts
```

---

## Data Source

**UCSC Xena Browser** — TCGA THCA + GTEx Thyroid RNA-seq (TOIL recompute)

- **Bookmark**: [`c486b845ee2e750c3a9d2fc5145c8426`](https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426)
- **Values**: log₂(norm_count + 1)
- **Samples**: TCGA Thyroid Carcinoma (THCA) + GTEx normal thyroid
- **Citation**: Goldman et al. (2020) *Nature Biotechnology* 38:675–678

---

## Installation

### Prerequisites
- **R** ≥ 4.1
- **Bioconductor** packages

### Setup

```r
# Install CRAN packages
install.packages(c(
  "here", "dplyr", "stringr", "tibble", "tidyr", "purrr", "readr",
  "ggplot2", "ggrepel", "igraph", "ggraph", "httr", "jsonlite"
))

# Install Bioconductor packages
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c(
  "limma", "KEGGREST", "org.Hs.eg.db", "AnnotationDbi"
))
```

### Data download

The expression matrix must be downloaded from **UCSC Xena Browser**:

1. Go to: https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426
2. Click the **Download** button (top-right corner)
3. Select **"Download current visualization data"**
4. Save the file as `data/raw/XENA_THCA.tsv` in the project directory

**Alternatively**, use the included download script:

```bash
Rscript scripts/download_data.R
```

**Data description**:
- Source: TCGA THCA (Thyroid Carcinoma) + GTEx normal thyroid tissue
- Pipeline: TOIL RNA-seq recompute
- Values: log₂(norm_count + 1)
- Samples: 783 (279 Normal + 504 THCA)
- Genes: 121 thyroid hormone signaling pathway genes (KEGG hsa04919)

---

## Usage

### Quick start

```bash
Rscript run_pipeline.R
```

Or in R/RStudio:

```r
source("run_pipeline.R")
```

**Expected runtime**: ~3–5 minutes (depending on STRING/KEGG API latency).

### Output

```
═══ PIPELINE COMPLETE ═══
  ★ Fig1: Volcano Plot     → results/figures/Fig1_Volcano_THCA_vs_Normal.png
  ★ Fig2: PPI Network      → results/figures/Fig2_PPI_Network_THCA_DEGs.png
  Tables (7)               → results/tables/
  Network metadata (4)     → results/network/
```

---

## Analysis Parameters

| Parameter | Value | Justification |
|-----------|-------|---------------|
| **\|log₂FC\| threshold** | 1.0 | Standard 2-fold change; biologically meaningful |
| **FDR threshold** | 0.05 | Benjamini-Hochberg; 5% false discovery rate |
| **Expression filter** | >0.5 in ≥10% | Removes non-expressed genes in log₂ scale |
| **STRING score** | ≥700 | High-confidence interactions (top ~25%) |
| **KEGG pathway** | hsa04919 | Thyroid hormone signaling |
| **STRING version** | 12.0 | Latest stable release |

---

## Figure Standards

All figures follow **Cell Press** publication guidelines:

- **Typography**: Sans-serif (Arial/Helvetica compatible)
- **Background**: White, no grid, no chart junk
- **Color palette**: Dark vermilion (Up), dark steel blue (Down), light grey (NS)
- **Formats**: 600 dpi PNG + PDF + SVG
- **Dimensions**: 180 × 150 mm (Volcano), 180 × 165 mm (PPI)
- **Labels**: Objective criteria — top 15 DEGs by \|log₂FC\| + top 5 KEGG pathway genes
- **PPI nodes**: Sized by degree centrality, colored by regulation
- **PPI hubs**: Dark border highlight, top 25% betweenness + degree ≥ 2

---

## Dependencies

| Package | Version (dev) | Purpose |
|---------|--------------|---------|
| R | ≥ 4.1 | Base language |
| `here` | ≥ 1.0 | Portable paths |
| `limma` | ≥ 3.56 | Differential expression |
| `ggplot2` | ≥ 3.5 | Visualization |
| `ggraph` | ≥ 2.1 | Network visualization |
| `igraph` | ≥ 1.5 | Network analysis |
| `STRINGdb` | ≥ 2.12 | STRING API interface |
| `KEGGREST` | ≥ 1.40 | KEGG pathway genes |
| `org.Hs.eg.db` | ≥ 3.17 | Human gene annotations |

Full session info is saved to `logs/session_info.txt` after each run.

---

## Reproducibility

- Random seed: `set.seed(42)`
- Parameters centralized in `R/00_setup.R`
- All paths relative via `here::here()`
- `sessionInfo()` captured to file
- No hardcoded local paths
- Pipeline is modular and independently sourceable

---

## License

MIT License — see [LICENSE](LICENSE) file.

---

## Citation

If you use this pipeline, please cite:

- **Xena Browser**: Goldman et al. (2020) *Nature Biotechnology* 38:675–678
- **limma**: Ritchie et al. (2015) *Nucleic Acids Research* 43:e47
- **STRING**: Szklarczyk et al. (2023) *Nucleic Acids Research* 51:D638–D646
- **TCGA**: Cancer Genome Atlas Research Network (2014) *Cell* 159:676–690

---

*Pipeline maintained by [@santosry](https://github.com/santosry)*
