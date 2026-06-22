# thyroid-volcano-ppi

**Differential Expression and Protein-Protein Interaction Network Analysis in Thyroid Carcinoma (THCA)**

[![R >= 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![renv](https://img.shields.io/badge/renv-locked-blueviolet)](renv.lock)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](Dockerfile)

---

> This README is written for healthcare professionals.
> If you have never used R or GitHub, each step is explained below.

---

## For Healthcare Professionals

### What this project does

This project compares gene activity changes in thyroid tumors (papillary thyroid carcinoma, THCA) against normal thyroid tissue.

We use public data from **TCGA** (The Cancer Genome Atlas) and **GTEx** (Genotype-Tissue Expression), totaling **783 samples**: 504 tumor and 279 normal.

The focus is the **thyroid hormone signaling pathway** (KEGG hsa04919), with 121 genes analyzed.

### Main results

| Figure | What it shows |
|--------|-------------|
| **Figure 1: Volcano Plot** | Which genes are **upregulated** (more active) or **downregulated** (less active) in the tumor, and their statistical significance |
| **Figure 2: PPI Network** | How the **proteins** encoded by these genes interact, forming a contact network, and which proteins are the network "hubs" (central nodes) |

### What this analysis does NOT do

- Does **NOT** establish causality (association is not causation)
- Does **NOT** identify validated therapeutic targets
- Does **NOT** replace experimental validation (PCR, Western blot, etc.)
- Does **NOT** correct for batch effects between TCGA and GTEx
- PPI network **hubs** are exploratory centrality metrics; they **do not** imply proven biological importance or druggability

### What you need to install

#### 1. Install R

R is a free statistical analysis program.

- Go to: **https://cran.r-project.org/**
- Click **"Download R for Windows"** (or macOS, depending on your system)
- Click **"base"** and then **"Download R-X.X.X for Windows"**
- Run the installer and follow the steps: **Next, Next, Finish**

#### 2. Install VS Code (recommended) or RStudio

R can be used with two main interfaces. **VS Code** is the best option as it is more modern and versatile. **RStudio** also works.

**VS Code:**
- Go to: **https://code.visualstudio.com/**
- Download and install normally
- Then install the **R** extension (search for "R" in the extensions tab, shortcut `Ctrl+Shift+X`)
- Also install the **R Debugger** extension

**RStudio:**
- Go to: **https://posit.co/download/rstudio-desktop/**
- Download the free version (RStudio Desktop, Open Source Edition)
- Install normally

### Step-by-step to run the script

#### Before starting: download the repository

You can download the entire project in two ways:

**Option A: If you do NOT have Git installed (easiest):**
1. At the top of this GitHub page, click the green **"<> Code"** button
2. Click **"Download ZIP"**
3. Extract the `.zip` file to a folder on your computer (e.g., `C:\Users\YourName\Downloads\thyroid-volcano-ppi`)
4. This extracted folder will be your **working directory**

**Option B: If you have Git installed:**
```bash
git clone https://github.com/santosry/thyroid-volcano-ppi.git
```

#### STEP 1: Download the data file (REQUIRED)

The script **will not run** without the gene expression file. You have two options:

**Option 1: Automatic download (recommended):**
1. Open VS Code (or RStudio)
2. In the top menu, click **File, Open File**
3. Navigate to the project folder and open the file `run_pipeline.R`
4. In the terminal (or R console), type:
```r
source("scripts/download_data.R")
```
5. The download will proceed automatically (~5 MB). Wait for the confirmation message.

**Option 2: Manual download:**
1. Go to: **https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426**
2. In the top right corner, click the **"Download"** button
3. Select **"Download current visualization data"**
4. Save the file exactly as: **`XENA_THCA.tsv`**
5. Move the file to: `data/raw/` (inside the project folder)

> The file MUST be located at: `thyroid-volcano-ppi/data/raw/XENA_THCA.tsv`

#### STEP 2: Install required packages

The first time you run it, the script installs everything automatically. To install beforehand:

1. Open VS Code (or RStudio)
2. In the terminal (or R console), copy and paste:
```r
install.packages("renv")
renv::restore()
```
3. Wait for the installation to finish (5 to 15 minutes, depending on your internet)
4. Many packages will be installed; seeing many messages is normal

> The `renv::restore()` command installs the exact same package versions the authors used. This ensures reproducible results.

#### STEP 3: Run the script

1. In VS Code (or RStudio), open the file `run_pipeline.R`
2. Run the script: in VS Code press `Ctrl+Shift+S`, or in RStudio click **"Source"** (top right corner)
   - Or type in the console:
```r
source("run_pipeline.R")
```
3. Wait **3 to 5 minutes** (the script needs internet to access STRING and KEGG databases)
4. If successful, you will see: **"PIPELINE COMPLETED SUCCESSFULLY"**

#### STEP 4: View the results

All results are in the `results/` folder:

- **Figures:** `results/figures/`
  - `Fig1_Volcano_THCA_vs_Normal.png` (and `.pdf`) : Volcano Plot
  - `Fig2_PPI_Network_THCA_DEGs.png` (and `.pdf`) : PPI Network
- **Tables:** `results/tables/`
- **Network metadata:** `results/network/`

---

## Study Design

### Methods

| Step | Method | Tool |
|------|--------|------|
| Differential expression | Linear model + empirical Bayes | limma (Bioconductor) |
| Contrast | THCA vs Normal (GTEx) | makeContrasts |
| Multiple testing correction | Benjamini-Hochberg (FDR) | topTable |
| PPI network | STRING REST API v12.0 | httr + jsonlite |
| Centrality | Betweenness, degree, closeness, hub score | igraph |
| Visualization | Volcano Plot + PPI Network (Cell Press standard) | ggplot2 + ggrepel + ggraph |

### Data Sources

| Source | Description | Access |
|--------|-------------|--------|
| **TCGA THCA** | 504 papillary thyroid carcinoma samples | UCSC Xena Browser |
| **GTEx Thyroid** | 279 normal thyroid tissue samples | UCSC Xena Browser |
| **KEGG hsa04919** | Thyroid hormone signaling pathway | KEGG REST API |
| **STRING v12.0** | Protein-protein interactions (high confidence >= 700) | STRING REST API |

### Analysis Parameters

| Parameter | Value | Meaning |
|-----------|-------|---------|
| Minimum |log2FC| | 1.0 | At least 2-fold change in expression |
| Maximum FDR | 0.05 | Maximum 5% false positives (Benjamini-Hochberg) |
| Expression filter | >0.5 in >=10% | Genes must have detectable signal |
| Minimum STRING score | 700 | High confidence in protein interaction |
| KEGG pathway | hsa04919 | Thyroid hormone signaling |
| STRING version | 12.0 | Latest database release |
| Seed | 42 | Ensures reproducible results |

### How to Interpret the Results

#### Figure 1: Volcano Plot

The Volcano Plot is the most common graph in gene expression studies.

| Element | Meaning |
|----------|---------|
| **X axis** | `log2(fold change)`: direction and magnitude of change. **Positive** = gene more expressed in tumor. **Negative** = gene less expressed in tumor |
| **Y axis** | `-log10(adjusted p-value)`: statistical significance. The **higher** the point, the **more reliable** the difference |
| **Blue points** | Genes **upregulated** in the tumor (9 genes). Activity increased in cancer |
| **Magenta points** | Genes **downregulated** in the tumor (20 genes). Activity decreased in cancer |
| **Grey points** | Genes with no significant difference (90 genes) |
| **Dashed lines** | Statistical thresholds: vertical line = 2-fold change; horizontal line = 5% false discovery rate (FDR) |
| **Open circles** | Genes belonging to the KEGG thyroid hormone pathway (hsa04919) |
| **Gene labels** | Most relevant genes identified with ggrepel |

**Summary:** Genes in the upper right = more active in tumor, with high statistical confidence. Genes in the upper left = less active in tumor. In total, **29 genes** showed significant difference (9 up, 20 down).

#### Figure 2: Protein-Protein Interaction (PPI) Network

The PPI network shows how the proteins of altered genes physically interact with each other.

| Element | Meaning |
|----------|---------|
| **Each circle (node)** | A protein encoded by a differentially expressed gene |
| **Node colors** | Each color represents a **functional module**: proteins working together in the same biological function (detected by the walktrap algorithm) |
| **Node size** | Proportional to **degree centrality**: how many other proteins it interacts with. Larger = more connected |
| **Thick dark border** | **Hub protein**: central network protein with many connections. 5 hubs identified |
| **Lines between nodes** | Physical interaction between two proteins, per STRING v12.0 (score >= 700) |
| **Grey lines** | Interactions within the same functional module |
| **Light pink lines** | Interactions between different modules |

**IMPORTANT:** **Hubs** are identified by network centrality metrics (betweenness, degree). They **do not** represent validated therapeutic targets, **do not** imply causality, and **do not** replace experimental validation. They are hypotheses generated by exploratory computational methods.

---

## Limitations

This analysis has important limitations to consider when interpreting results:

1. **TCGA/GTEx batch effect:** Tumor (TCGA) and normal (GTEx) samples come from different sources with distinct sequencing protocols. No batch effect correction was applied. Observed differences may partially reflect technical bias.

2. **Association vs. causality:** Differential expression indicates statistical association, not causal relationship. Identified DEGs may be a consequence (not a cause) of the neoplastic process.

3. **In silico PPI network:** Protein-protein interactions are predicted/inferred by the STRING database (combined evidence: text mining, experiments, co-expression, etc.). There is no direct experimental validation.

4. **Exploratory hubs:** Hub proteins are defined by network centrality metrics. They should **not** be interpreted as therapeutic targets or biomarkers without additional validation.

5. **Generalizability:** Results apply to the specific THCA (papillary carcinoma) context with TCGA/GTEx data. Extrapolation to other histological subtypes requires caution.

6. **External API dependency:** The pipeline requires internet for STRING and KEGG. Changes to these APIs may affect future reproducibility.

---

## Pipeline Structure

```
thyroid-volcano-ppi/
├── run_pipeline.R              Main script (just run this!)
├── R/
│   ├── 00_setup.R              Parameters, packages, colors, internet check
│   ├── 01_functions.R          Core functions (KEGG, STRING, export)
│   ├── 02_import.R             Data import and validation
│   ├── 03_deg.R                Differential expression (limma + empirical Bayes)
│   ├── 04_volcano.R            Figure 1: Volcano Plot (PNG + PDF)
│   ├── 05_ppi.R                Figure 2: PPI Network (PNG + PDF)
│   └── 06_supplementary.R      Supplementary tables S1-S4
├── data/
│   ├── raw/                    Place XENA_THCA.tsv here
│   ├── processed/              Intermediate data
│   └── string_cache/           STRING cache
├── scripts/
│   ├── download_data.R         Automatic data download
│   └── setup_renv.R            renv initialization
├── results/
│   ├── figures/                600 dpi PNGs + vector PDFs
│   ├── tables/                 TSV tables (7 main + 4 supplementary)
│   └── network/                PPI network metadata
├── tests/
│   ├── testthat.R              Test runner
│   └── testthat/               Unit tests (with and without internet)
├── docs/                       Supplementary documentation
├── logs/                       Execution logs + sessionInfo()
├── Dockerfile                  Reproducible Docker container
├── renv.lock                   Exact R package versions
├── LICENSE                     MIT
└── CITATION.cff                Citation metadata
```

---

## How to Run

```bash
# 1. Clone the repository
git clone https://github.com/santosry/thyroid-volcano-ppi.git
cd thyroid-volcano-ppi

# 2. Download data (automatic or manual)
Rscript scripts/download_data.R

# 3. Restore R environment (recommended)
R -e 'install.packages("renv"); renv::restore()'

# 4. Run the pipeline
Rscript run_pipeline.R

# 5. Run tests (optional)
R -e 'testthat::test_dir("tests/testthat")'
```

**Estimated time:** 3-5 minutes with internet.

---

## Outputs and Interpretation

### Main Tables (`results/tables/`)

| File | Content |
|---------|---------|
| `T01_sample_composition.tsv` | Sample counts by type (Normal vs THCA) |
| `T02_deg_summary.tsv` | Analysis summary: genes tested, DEGs found, thresholds |
| `T03_deg_full_results.tsv` | Complete results: all genes with log2FC, p-value, adjusted p-value, classification (Up/Down/NS) |
| `T04_top20_degs.tsv` | Top 20 genes with largest expression differences |
| `T05_kegg_missing_genes.tsv` | KEGG pathway genes not detected in the data |
| `T06_hub_proteins.tsv` | PPI network hub proteins with centrality metrics |
| `T07_kegg_degs_ppi.tsv` | Integrated table: KEGG DEGs + PPI network metrics |

### Network Metadata (`results/network/`)

| File | Content |
|---------|---------|
| `N01_string_mapping.tsv` | Gene to STRING protein ID mapping |
| `N02_string_interactions.tsv` | Protein-protein interactions used in the network |
| `N03_centrality_metrics.tsv` | Complete centrality metrics for each protein |
| `N04_network_summary.tsv` | Global network statistics (nodes, edges, hubs, communities) |

### Figure Specifications

Both figures follow **Nature Communications / Cell Press** editorial standards:

| Property | Specification |
|-------------|---------------|
| Format | 600 dpi PNG + vector PDF |
| Volcano Plot | 180 x 150 mm |
| PPI Network | 180 x 180 mm |
| Typography | Sans-serif (Arial/Helvetica), 14pt |
| Background | White, open axes |
| Colors | Blue `#4477AA` (Upregulated), Magenta `#AA4488` (Downregulated) |
| Labels | ggrepel with leader lines |
| PPI Network | Fruchterman-Reingold layout, walktrap communities |

---

## FAQ

### "Error: XENA_THCA.tsv file not found"

**Solution:** Go back to STEP 1 above and download the data file.

### "Automatic download failed"

**Solution:** Use the manual download (Option 2 in STEP 1).

### "Internet connection error during analysis"

**Solution:** The script checks connectivity at startup. STRING and KEGG require internet. Check your connection and try again.

### "How long does it take to run?"

About **3 to 5 minutes** with a good internet connection. First run adds 10-15 minutes for package installation.

### "What is 'log2 fold change'?"

A measure of expression change. log2FC of **+1** = gene is 2x more expressed in tumor. log2FC of **+2** = 4x more expressed. log2FC of **-1** = 2x less expressed.

### "What is 'FDR' or 'adjusted p-value'?"

The p-value measures the probability that the observed difference is due to chance. Since many genes are tested simultaneously, the p-value is adjusted (Benjamini-Hochberg correction). **FDR < 0.05** means we accept at most 5% false positives among the identified DEGs.

### "I don't know how to use R. Is there another way?"

You just need to copy and paste the commands. With VS Code or RStudio it is even easier: open the script and run it. R will do all the work.

### "I want to change the analysis parameters"

Open the file `R/00_setup.R` and modify the values in the `THRESHOLD` list:
```r
THRESHOLD <- list(
  lfc        = 1.0,     # Increase for stricter fold-change cutoff
  fdr        = 0.05,    # Decrease for more stringency (e.g., 0.01)
  string     = 700      # Decrease to include more interactions (e.g., 400)
)
```
Then run the script again.

---

## Reproducibility

- `set.seed(42)`: fixed seed ensures identical results
- All parameters in `R/00_setup.R`
- Paths via `here::here()`: no absolute paths
- `sessionInfo()` saved to `logs/`
- `renv.lock`: exact versions of all R packages
- `Dockerfile`: full reproducible Linux environment
- `CITATION.cff`: standardized citation metadata
- `results/CHECKSUMS.md`: MD5 hashes for output integrity verification
- `check_internet()`: connectivity validation before API calls

To verify output integrity after running the pipeline:
```bash
cd results && md5sum -c CHECKSUMS.md
```

---

## Tests

```r
# Run all tests
testthat::test_dir("tests/testthat")
```

Tests cover: thresholds, DEG classification, expression filtering, required columns, critical NAs, TSV export, scale validation, and STRING score filtering. Mock data tests do not require internet.

---

## Authors

| Author | ORCID | Affiliation |
|--------|-------|-----------|
| **Leticia Maria Dias Freitas** (corresponding author) | [0009-0009-9930-9588](https://orcid.org/0009-0009-9930-9588) | Escola Tecnica Estadual Joao Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ, Brazil |
| Ryan de Paulo Santos | [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001) | Instituto Federal de Educacao, Ciencia e Tecnologia Fluminense (IFFluminense), Campus Campos Guarus, Campos dos Goytacazes, RJ, Brazil |
| Thais Faria Coutinho da Silva Pereira | [0009-0005-7091-2480](https://orcid.org/0009-0005-7091-2480) | Escola Tecnica Estadual Joao Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ, Brazil |

**Corresponding author:** Leticia Maria Dias Freitas: [leticiamariadiasfreitas@gmail.com](mailto:leticiamariadiasfreitas@gmail.com)

---

## Author Contributions: CRediT Taxonomy

| Author | Contribution |
|--------|-------------|
| **Leticia Maria Dias Freitas** | Conceptualization (Lead); Methodology (Equal); Software (Equal); Formal Analysis (Equal); Data Curation (Equal); Validation (Equal); Visualization (Equal); Investigation (Equal); Writing: Original Draft (Lead); Project Administration (Supporting) |
| **Ryan de Paulo Santos** | Conceptualization (Supporting); Methodology (Equal); Software (Equal); Formal Analysis (Equal); Data Curation (Equal); Validation (Equal); Visualization (Equal); Investigation (Equal); Writing: Original Draft (Equal); Project Administration (Lead); Writing: Review & Editing (Supporting) |
| **Thais Faria Coutinho da Silva Pereira** | Supervision (Lead); Scientific Review (Lead); Validation (Supporting) |

---

## Artificial Intelligence Use Disclosure

In compliance with **CNPq Ordinance No. 2.664/2026** regarding artificial intelligence use in scientific research, we declare that the following AI tools were used as technical and methodological support:

| AI Tool | Developer | Tasks Performed |
|------------|---------------|---------|
| **DeepSeek-v4-pro** | DeepSeek | R code optimization, namespace auditing, statistical function review |
| **Codex** | OpenAI | R script generation and debugging, technical documentation support |
| **ChatGPT 5.5** | OpenAI | Text review, documentation structuring, reproducibility suggestions |
| **Grok** | xAI | Exploratory analysis, visualization prototyping, methodological support |

**In all cases**, human participation was integral and sovereign. **No scientific conclusions were derived by AI.** For the complete record, see table `S4_ai_assisted_tasks.tsv`.

---

## License

MIT License: see [LICENSE](LICENSE)

---

## How to Cite

```bibtex
@software{freitas2026thyroid,
  title        = {thyroid-volcano-ppi: Differential Expression and
                  PPI Network Analysis in Thyroid Carcinoma (THCA)},
  author       = {Leticia Maria Dias Freitas and Ryan de Paulo Santos
                  and Thais Faria Coutinho da Silva Pereira},
  year         = {2026},
  url          = {https://github.com/santosry/thyroid-volcano-ppi},
  note         = {v3.0.0}
}
```

See also `CITATION.cff` for structured citation metadata.

---

## References

1. Goldman MJ, Craft B, Hastie M, Repecka K, McDade F, Kamath A, Banerjee A, Luo Y, Rogers D, Brooks AN, Zhu J, Haussler D. Visualizing and interpreting cancer genomics data via the Xena platform. *Nature Biotechnology*. 2020;38(6):675-678. doi:[10.1038/s41587-020-0546-8](https://doi.org/10.1038/s41587-020-0546-8)

2. Ritchie ME, Phipson B, Wu D, Hu Y, Law CW, Shi W, Smyth GK. limma powers differential expression analyses for RNA-sequencing and microarray studies. *Nucleic Acids Research*. 2015;43(7):e47. doi:[10.1093/nar/gkv007](https://doi.org/10.1093/nar/gkv007)

3. Szklarczyk D, Kirsch R, Koutrouli M, Nastou K, Mehryary F, Hachilif R, Gable AL, Fang T, Doncheva NT, Pyysalo S, Bork P, Jensen LJ, von Mering C. The STRING database in 2023: protein-protein association networks and functional enrichment analyses for any sequenced genome of interest. *Nucleic Acids Research*. 2023;51(D1):D638-D646. doi:[10.1093/nar/gkac1000](https://doi.org/10.1093/nar/gkac1000)

4. Cancer Genome Atlas Research Network. Integrated genomic characterization of papillary thyroid carcinoma. *Cell*. 2014;159(3):676-690. doi:[10.1016/j.cell.2014.09.050](https://doi.org/10.1016/j.cell.2014.09.050)

5. Kanehisa M, Furumichi M, Sato Y, Kawashima M, Ishiguro-Watanabe M. KEGG for taxonomy-based analysis of pathways and genomes. *Nucleic Acids Research*. 2023;51(D1):D587-D592. doi:[10.1093/nar/gkac963](https://doi.org/10.1093/nar/gkac963)

6. Csardi G, Nepusz T, Traag V, Horvat S, Zanini F, Noom D, Muller K. igraph: Network Analysis and Visualization. R package version 2.0.3. CRAN; 2024. Available at: [https://CRAN.R-project.org/package=igraph](https://CRAN.R-project.org/package=igraph)

7. Pedersen TL. ggraph: An Implementation of Grammar of Graphics for Graphs and Networks. R package version 2.2.1. CRAN; 2024. Available at: [https://CRAN.R-project.org/package=ggraph](https://CRAN.R-project.org/package=ggraph)

---

## Source Code Audit Trail (June 22, 2026)

### Critical Fixes Applied (v3.0.0)

| # | File | Issue | Resolution |
|---|---------|----------|---------|
| 1 | `01_functions.R` | `select()` conflicted with `AnnotationDbi::select` | `dplyr::select()` |
| 2 | `05_ppi.R` | `components()` / `degree()` unqualified | `igraph::components()`, `igraph::degree()` |
| 3 | `01_functions.R` | `hub_score()` deprecated (igraph 2.0.3) | `igraph::hits_scores()` |
| 4 | `00_setup.R` | Bioconductor via `install.packages()` | `BiocManager::install()` |
| 5 | `run_pipeline.R` / `00_setup.R` | Duplicated here/PROJECT_ROOT detection | Unified in `00_setup.R` |
| 6 | `04_volcano.R` | Incorrect KEGG filter comparison | Fixed |
| 7 | `05_ppi.R` | Layout computed twice | Single computation |
| 8 | `02_import.R` | No duplicate or NA checks | Added `anyDuplicated()`, `na_frac` |
| 9 | `00_setup.R` | No internet connectivity check | Added `check_internet()` |
| 10 | `04_volcano.R` / `05_ppi.R` | No PDF export | Added vector PDF |
| 11 | `run_pipeline.R` | No causality disclaimer | Added at pipeline end |
| 12 | `05_ppi.R` | Hubs without interpretation caveat | Added warning about exploratory nature |

### Reproducibility Checklist

| Check | Status |
|-------------|--------|
| No absolute paths | [x] `here::here()` |
| Fixed seed | [x] `set.seed(42)` |
| Centralized parameters | [x] `00_setup.R` |
| Session info captured | [x] `logs/session_info.txt` |
| Version lockfile | [x] `renv.lock` |
| Docker container | [x] `Dockerfile` |
| Unit tests | [x] `tests/testthat/` |
| Data documented | [x] Bookmark + auto-download |
| Citation metadata | [x] `CITATION.cff` |
| Internet check | [x] `check_internet()` |
| Causality disclaimer | [x] README + pipeline end |

---

*Pipeline maintained by [Ryan de Paulo Santos](https://github.com/santosry), ORCID: [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001)*
