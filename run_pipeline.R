# ═══════════════════════════════════════════════════════════════════════════════
# run_pipeline.R — Master runner | thyroid-volcano-ppi
#
# THCA Transcriptomic Analysis: differential expression (limma),
# Volcano Plot, and STRING PPI network of DEGs.
#
# Only two graphical outputs (PNG 600dpi, Cell Press standard):
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
if (!requireNamespace("here", quietly = TRUE)) install.packages("here", repos = "https://cloud.r-project.org")
library(here)
PROJECT_ROOT <- here::here()

# Validate project structure
stopifnot(file.exists(file.path(PROJECT_ROOT, "data", "raw", "XENA_THCA.tsv")))

cat("\n")
cat("╔══════════════════════════════════════════════════╗\n")
cat("║  thyroid-volcano-ppi — THCA DEG + PPI Analysis  ║\n")
cat("║  Output: Volcano Plot + PPI Network              ║\n")
cat("║  Standard: Cell Press publication quality        ║\n")
cat("╚══════════════════════════════════════════════════╝\n\n")

# ── Execute pipeline modules ─────────────────────────────────────────────────
source(here::here("R", "00_setup.R"))     # Parameters, packages, Cell Press theme
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
cat("╔══════════════════════════════════════════════════╗\n")
cat("║  PIPELINE COMPLETE                               ║\n")
cat("╚══════════════════════════════════════════════════╝\n\n")
cat("Outputs:\n")
cat("  ★ Fig1: Volcano Plot     → results/figures/Fig1_Volcano_THCA_vs_Normal.png\n")
cat("  ★ Fig2: PPI Network      → results/figures/Fig2_PPI_Network_THCA_DEGs.png\n")
cat("  Tables (7)               → results/tables/\n")
cat("  Network metadata (4)     → results/network/\n")
cat("  Session info             → logs/session_info.txt\n")
cat("\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
