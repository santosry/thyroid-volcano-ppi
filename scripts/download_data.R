#!/usr/bin/env Rscript
# ═══════════════════════════════════════════════════════════════════════════════
# scripts/download_data.R — Download XENA_THCA.tsv from UCSC Xena Browser
#
# This script downloads the TCGA THCA + GTEx Thyroid expression matrix
# used in the thyroid-volcano-ppi analysis.
#
# Source: UCSC Xena Browser
# Bookmark: c486b845ee2e750c3a9d2fc5145c8426
# Data: log2(norm_count + 1) RSEM expected_count from TOIL recompute
#
# Usage:
#   Rscript scripts/download_data.R
# ═══════════════════════════════════════════════════════════════════════════════

# Detect project root
if (!requireNamespace("here", quietly = TRUE)) install.packages("here", repos = "https://cloud.r-project.org")
library(here)
PROJECT_ROOT <- here::here()

# ── Xena Browser download URLs ────────────────────────────────────────────────
# The expression matrix can be exported from:
#   https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426
#
# Direct download URL (TCGA THCA + GTEx Thyroid, gene expression RNAseq, log2(norm_count+1)):
XENA_URL <- paste0(
  "https://toil-xena-hub.s3.us-east-1.amazonaws.com/download/",
  "TcgaTargetGtex_rsem_gene_tpm.gz"
)

# Alternative: if the user has a local copy, place it at data/raw/XENA_THCA.tsv

output_path <- file.path(PROJECT_ROOT, "data", "raw", "XENA_THCA.tsv")

cat("╔══════════════════════════════════════════════════╗\n")
cat("║   Data Download — thyroid-volcano-ppi           ║\n")
cat("╚══════════════════════════════════════════════════╝\n\n")

if (file.exists(output_path)) {
  cat("✓ Data file already exists:", output_path, "\n")
  cat("  Size:", file.info(output_path)$size, "bytes\n")
  quit(save = "no", status = 0)
}

cat("Attempting download from Xena Browser...\n")
cat("URL:", XENA_URL, "\n\n")
cat("NOTE: If download fails, please manually download from:\n")
cat("  https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426\n")
cat("  → Click 'Download' → 'Download current visualization data'\n")
cat("  → Save as: data/raw/XENA_THCA.tsv\n\n")

tryCatch({
  options(timeout = 600)
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  
  download.file(
    url = XENA_URL,
    destfile = output_path,
    mode = "wb"
  )
  
  cat("✓ Download complete:", output_path, "\n")
  cat("  Size:", file.info(output_path)$size, "bytes\n")
}, error = function(e) {
  cat("✗ Download failed:", conditionMessage(e), "\n\n")
  cat("Please manually download the data file from Xena Browser:\n")
  cat("  1. Go to: https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426\n")
  cat("  2. Click the download button\n")
  cat("  3. Save as: data/raw/XENA_THCA.tsv\n")
})
