# ═══════════════════════════════════════════════════════════════════════════════
# R/00_setup.R — Project setup, parameters, packages
# thyroid-volcano-ppi — THCA DEG analysis with Volcano Plot and PPI Network
# ═══════════════════════════════════════════════════════════════════════════════

# ── 0.1. Project root (portable) ──────────────────────────────────────────────
if (!exists("PROJECT_ROOT")) {
  if (!requireNamespace("here", quietly = TRUE)) install.packages("here", repos = "https://cloud.r-project.org")
  library(here)
  PROJECT_ROOT <- here::here()
}

# ── 0.2. Output directory structure ───────────────────────────────────────────
DIRS <- list(
  tables  = "results/tables",
  figures = "results/figures",
  network = "results/network",
  logs    = "logs"
)
invisible(lapply(DIRS, dir.create, recursive = TRUE, showWarnings = FALSE))

# ── 0.3. Analysis parameters (biologically and statistically justified) ───────
THRESHOLD <- list(
  lfc        = 1.0,     # |log2FC| > 1 → 2-fold change, standard biological significance
  fdr        = 0.05,    # Benjamini-Hochberg adjusted p-value, 5% FDR
  string     = 700,     # STRING combined_score ≥ 700 → high confidence (top ~25% of interactions)
  expr_min   = 0.5,     # log2(norm_count+1) minimum expression for detection
  expr_frac  = 0.1      # gene must be expressed in ≥ 10% of samples
)

# Pathway of interest
KEGG_ID       <- "hsa04919"   # Thyroid hormone signaling pathway
STRING_TAXON  <- 9606         # Homo sapiens
STRING_V      <- "12.0"       # STRING version

# ── 0.4. Reproducibility ─────────────────────────────────────────────────────
set.seed(42)
options(
  scipen            = 999,
  digits            = 4,
  timeout           = 600,
  stringsAsFactors  = FALSE,
  repr.plot.width   = 8,
  repr.plot.height  = 7
)

# ── 0.5. Required packages ───────────────────────────────────────────────────
REQUIRED_PKGS <- c(
  "here", "dplyr", "stringr", "tibble", "tidyr", "purrr", "readr",
  "limma", "ggplot2", "ggrepel",
  "igraph", "ggraph",
  "KEGGREST", "org.Hs.eg.db", "AnnotationDbi",
  "httr", "jsonlite"
)

for (pkg in REQUIRED_PKGS) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (interactive()) {
      install.packages(pkg, repos = "https://cloud.r-project.org")
    } else {
      stop("Missing package: ", pkg, ". Install manually or run interactively.")
    }
  }
}

suppressPackageStartupMessages({
  library(here)
  library(dplyr)
  library(stringr)
  library(tibble)
  library(tidyr)
  library(purrr)
  library(readr)
  library(limma)
  library(ggplot2)
  library(ggrepel)
  library(igraph)
  library(ggraph)
  library(KEGGREST)
  library(org.Hs.eg.db)
  library(AnnotationDbi)
  library(httr)
  library(jsonlite)
})

# ── 0.6. Cell Press visual standards ─────────────────────────────────────────
# Color palette: publication-grade, colorblind-friendly, consistent
CELL_COLORS <- list(
  up        = "#B02525",   # Dark vermilion — upregulated in THCA
  down      = "#1B5F8C",   # Dark steel blue — downregulated in THCA
  ns        = "#C8C8C8",   # Light grey — not significant
  edge      = "#E0E0E0",   # Very light grey — PPI edges
  highlight = "#222222",   # Near-black — borders, highlights
  kegg_ring = "#333333"    # Dark grey — KEGG pathway highlight ring
)

# Typography: sans-serif for Cell Press compatibility
CELL_THEME <- theme_classic(base_size = 9) +
  theme(
    text            = element_text(family = "sans"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid      = element_blank(),
    axis.line       = element_line(color = "black", linewidth = 0.3),
    axis.ticks      = element_line(color = "black", linewidth = 0.3),
    axis.text       = element_text(color = "black", size = 8),
    axis.title      = element_text(color = "black", size = 9),
    legend.background = element_rect(fill = "white", color = NA),
    legend.key      = element_rect(fill = "white", color = NA),
    legend.text     = element_text(size = 8),
    legend.title    = element_text(size = 8, face = "bold"),
    plot.title      = element_blank(),   # No embedded titles
    plot.subtitle   = element_blank(),
    plot.caption    = element_blank(),
    strip.background = element_rect(fill = "grey95", color = "black", linewidth = 0.3),
    strip.text      = element_text(size = 8, face = "bold")
  )

# ── 0.7. Logging ──────────────────────────────────────────────────────────────
log_file <- file.path(DIRS$logs, paste0("pipeline_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log"))
log_con  <- file(log_file, open = "wt")
sink(log_con, split = TRUE)
# message sink separately to avoid connection conflict
msg_file <- file.path(DIRS$logs, paste0("pipeline_msgs_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".log"))
msg_con  <- file(msg_file, open = "wt")
sink(msg_con, type = "message")

cat("\n═══════════════════════════════════════════════════\n")
cat("thyroid-volcano-ppi — THCA DEG + PPI Analysis\n")
cat("KEGG Pathway:", KEGG_ID, "| STRING v", STRING_V, "\n", sep = "")
cat("Project root:", PROJECT_ROOT, "\n")
cat("Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("═══════════════════════════════════════════════════\n\n")
