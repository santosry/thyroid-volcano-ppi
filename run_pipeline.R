# ═══════════════════════════════════════════════════════════════════════════════
# run_pipeline.R — Master runner | thyroid-volcano-ppi
#
# THCA Transcriptomic Analysis: differential expression (limma),
# Volcano Plot, and STRING PPI network of DEGs.
#
# Two graphical outputs (PNG 600 dpi, Nature Communications standard):
#   1. Fig1_Volcano_THCA_vs_Normal.png
#   2. Fig2_PPI_Network_THCA_DEGs.png
#
# Usage:
#   Rscript run_pipeline.R
#   source("run_pipeline.R")
#
# Repository: https://github.com/santosry/thyroid-volcano-ppi
# ═══════════════════════════════════════════════════════════════════════════════

# Detect project root
if (!requireNamespace("here", quietly = TRUE))
  install.packages("here", repos = "https://cloud.r-project.org")
library(here)
PROJECT_ROOT <- here::here()

# ═══════════════════════════════════════════════════════════════════════════════
# DATA FILE VERIFICATION
# ═══════════════════════════════════════════════════════════════════════════════

DATA_FILE <- file.path(PROJECT_ROOT, "data", "raw", "XENA_THCA.tsv")
DOWNLOAD_SCRIPT <- file.path(PROJECT_ROOT, "scripts", "download_data.R")

if (!file.exists(DATA_FILE)) {
  cat("\n")
  cat("╔══════════════════════════════════════════════════════════════╗\n")
  cat("║  ⚠  DATA FILE NOT FOUND                                    ║\n")
  cat("╠══════════════════════════════════════════════════════════════╣\n")
  cat("║                                                            ║\n")
  cat("║  The file 'data/raw/XENA_THCA.tsv' is required.            ║\n")
  cat("║  It contains the gene expression matrix                    ║\n")
  cat("║  (TCGA THCA + GTEx Normal) used in the analysis.           ║\n")
  cat("║                                                            ║\n")
  cat("║  How to obtain the file:                                   ║\n")
  cat("║  1. Go to Xena Browser:                                   ║\n")
  cat("║     bit.ly/thyroid-volcano-ppi-data                        ║\n")
  cat("║  2. Click 'Download' in the top-right corner              ║\n")
  cat("║  3. Select 'Download current visualization data'          ║\n")
  cat("║  4. Save as: data/raw/XENA_THCA.tsv                       ║\n")
  cat("║                                                            ║\n")
  cat("║  Or run the automatic download script:                     ║\n")
  cat("║  Rscript scripts/download_data.R                           ║\n")
  cat("║                                                            ║\n")
  cat("║  Xena Bookmark:                                            ║\n")
  cat("║  c486b845ee2e750c3a9d2fc5145c8426                          ║\n")
  cat("╚══════════════════════════════════════════════════════════════╝\n\n")

  # Attempt automatic download if the script exists
  if (file.exists(DOWNLOAD_SCRIPT)) {
    cat("Attempting automatic download via scripts/download_data.R...\n\n")
    tryCatch({
      source(DOWNLOAD_SCRIPT)
    }, error = function(e) {
      cat("\nAutomatic download failed:", conditionMessage(e), "\n")
    })
  }

  # Re-check after download attempt
  if (!file.exists(DATA_FILE)) {
    stop(
      "\n❌ PIPELINE ABORTED: Data file missing.\n",
      "   Expected path: ", DATA_FILE, "\n",
      "   Please download the file manually from Xena Browser and try again.\n",
      "   Full instructions in README.md\n"
    )
  } else {
    cat("✓ Automatic download successful! Proceeding...\n\n")
  }
}

# Validate minimum file size
f_info <- file.info(DATA_FILE)
if (f_info$size < 1000) {
  stop("❌ Data file too small (", f_info$size,
       " bytes). File may be corrupted.\n",
       "   Please re-download from Xena Browser.")
}

cat("\n")
cat("╔══════════════════════════════════════════════════════╗\n")
cat("║  thyroid-volcano-ppi — THCA DEG + PPI Analysis      ║\n")
cat("║  Output: Volcano Plot + PPI Network                  ║\n")
cat("║  Standard: Nature Communications / Cell Press        ║\n")
cat("╚══════════════════════════════════════════════════════╝\n\n")

# ── Execute pipeline modules ─────────────────────────────────────────────────
source(here::here("R", "00_setup.R"))     # Parameters, packages, colors, typography
source(here::here("R", "01_functions.R")) # Core utility functions
source(here::here("R", "02_import.R"))    # Data import & QC
source(here::here("R", "03_deg.R"))       # Differential expression (limma)
source(here::here("R", "04_volcano.R"))   # ★ Figure 1: Volcano Plot
source(here::here("R", "05_ppi.R"))       # ★ Figure 2: PPI Network

# ── Session info ─────────────────────────────────────────────────────────────
sink(file.path(DIRS$logs, "session_info.txt"))
sessionInfo()
sink()

# ── Final summary ────────────────────────────────────────────────────────────
cat("\n")
cat("╔══════════════════════════════════════════════════════╗\n")
cat("║  PIPELINE COMPLETED SUCCESSFULLY                     ║\n")
cat("╚══════════════════════════════════════════════════════╝\n\n")
cat("Outputs:\n")
cat("  ★ Fig1: Volcano Plot     → results/figures/Fig1_Volcano_THCA_vs_Normal.png\n")
cat("  ★ Fig2: PPI Network      → results/figures/Fig2_PPI_Network_THCA_DEGs.png\n")
cat("  Tables (7)               → results/tables/\n")
cat("  Network metadata (4)     → results/network/\n")
cat("  Session info             → logs/session_info.txt\n")
cat("\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
