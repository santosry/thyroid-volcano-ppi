# ═══════════════════════════════════════════════════════════════════════════════
# R/02_import.R — Data import, validation, and preprocessing
# thyroid-volcano-ppi
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── Module 1: Data Import & Quality Control ──\n")

# ── 1.1. Read expression matrix ───────────────────────────────────────────────
INPUT <- here::here("data", "raw", "XENA_THCA.tsv")

if (!file.exists(INPUT)) {
  stop("Input file not found: ", INPUT,
       "\nPlease run: Rscript scripts/download_data.R",
       "\nor manually download from Xena Browser (bookmark: c486b845ee2e750c3a9d2fc5145c8426)")
}

raw <- readr::read_tsv(INPUT, show_col_types = FALSE)
cat(sprintf("  Loaded: %d samples × %d columns\n", nrow(raw), ncol(raw)))

# ── 1.2. Standardize column names ─────────────────────────────────────────────
names(raw) <- sub("^_", "", names(raw))
if ("samples" %in% names(raw)) raw$samples <- NULL

# ── 1.3. Separate metadata and expression ─────────────────────────────────────
META_COLS <- c("sample", "primary_site", "sample_type", "study", "TCGA_GTEX_main_category")
stopifnot(all(META_COLS %in% names(raw)))

meta <- raw[, META_COLS, drop = FALSE]
expr <- as.matrix(raw[, setdiff(names(raw), META_COLS), drop = FALSE])
storage.mode(expr) <- "numeric"

# ── 1.4. Define biological condition ──────────────────────────────────────────
meta$condition <- ifelse(
  meta$TCGA_GTEX_main_category == "GTEX Thyroid", "Normal",
  ifelse(meta$TCGA_GTEX_main_category == "TCGA Thyroid Carcinoma", "THCA", NA)
)
meta$condition <- factor(meta$condition, levels = c("Normal", "THCA"))

# Remove unclassified samples
keep <- !is.na(meta$condition)
meta <- meta[keep, , drop = FALSE]
expr <- expr[keep, , drop = FALSE]

# ── 1.5. QC: validate expression scale ────────────────────────────────────────
validate_expression_scale(expr)

# ── 1.6. Sample composition ──────────────────────────────────────────────────
cat("\n  Sample composition:\n")
print(table(meta$condition))

# ── 1.7. QC table — sample summary ───────────────────────────────────────────
qc_samples <- meta |>
  group_by(condition, study, sample_type) |>
  summarise(n = n(), .groups = "drop") |>
  arrange(condition, study)

export_tsv(qc_samples, here::here(DIRS$tables, "T01_sample_composition.tsv"))

cat(sprintf("  Final: %d samples × %d genes ready for analysis\n", nrow(expr), ncol(expr)))
