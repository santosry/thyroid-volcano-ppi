# ═══════════════════════════════════════════════════════════════════════════════
# R/03e_umap_qc.R — UMAP QC plots
# thyroid-volcano-ppi v3.1.0
#
# UMAP visualization colored by condition AND source/study.
# Used for QC: detect batch effects, outliers, and data structure.
# UMAP is QC/diagnostic — does NOT replace gene-level DEG with limma.
#
# Output: results/figures/Fig_QC_UMAP_condition.png
#         results/figures/Fig_QC_UMAP_source.png
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── QC: UMAP ──\n")

if (!requireNamespace("uwot", quietly = TRUE)) {
  install.packages("uwot", repos = "https://cloud.r-project.org")
}
library(uwot)

tryCatch({

  # ── Run UMAP on filtered expression matrix ──────────────────────────────────
  # Use the same E matrix (genes x samples) from 03_deg.R
  set.seed(42)
  # Force plain numeric matrix for uwot
  X <- as.matrix(t(E))
  mode(X) <- "numeric"
  umap_res <- uwot::umap(
    X,
    n_neighbors = 30,
    min_dist = 0.3,
    n_components = 2,
    metric = "euclidean",
    verbose = FALSE
  )

  colnames(umap_res) <- c("UMAP1", "UMAP2")
  umap_df <- data.frame(
    UMAP1 = umap_res[, 1],
    UMAP2 = umap_res[, 2],
    condition = meta$condition,
    study = meta$study,
    stringsAsFactors = FALSE
  )

  # ── UMAP by condition ──────────────────────────────────────────────────────
  p_umap_cond <- ggplot(umap_df, aes(x = UMAP1, y = UMAP2, color = condition)) +
    geom_point(size = 1.2, alpha = 0.55, stroke = 0.2) +
    scale_color_manual(
      values = c("Normal" = "#4477AA", "THCA" = "#AA4488")
    ) +
    labs(title = "UMAP — Colorido por Condição",
         subtitle = paste0(nrow(umap_df), " amostras | ", nrow(E), " genes"),
         color = "Condição") +
    theme_minimal(base_size = 12) +
    theme(
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "grey92", linewidth = 0.12),
      panel.grid.minor = element_blank(),
      axis.line  = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      axis.text  = element_text(color = "black", size = 9),
      axis.title = element_text(color = "black", size = 11),
      legend.position = "right",
      plot.margin = margin(6, 6, 6, 6)
    )

  ggsave(here::here(DIRS$figures, "Fig_QC_UMAP_condition.png"),
         p_umap_cond, width = 180, height = 140, units = "mm",
         dpi = 600, bg = "white")
  ggsave(here::here(DIRS$figures, "Fig_QC_UMAP_condition.pdf"),
         p_umap_cond, width = 180, height = 140, units = "mm",
         device = "pdf", bg = "white")

  # ── UMAP by source/study ────────────────────────────────────────────────────
  p_umap_src <- ggplot(umap_df, aes(x = UMAP1, y = UMAP2, color = study)) +
    geom_point(size = 1.2, alpha = 0.55, stroke = 0.2) +
    scale_color_manual(
      values = c("TCGA" = "#CC6677", "GTEX" = "#44AA77")
    ) +
    labs(title = "UMAP — Colorido por Fonte/Estudo",
         subtitle = "TCGA (tumoral) vs GTEx (normal) — avaliação de batch effect",
         color = "Estudo") +
    theme_minimal(base_size = 12) +
    theme(
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      panel.grid.major = element_line(color = "grey92", linewidth = 0.12),
      panel.grid.minor = element_blank(),
      axis.line  = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      axis.text  = element_text(color = "black", size = 9),
      axis.title = element_text(color = "black", size = 11),
      legend.position = "right",
      plot.margin = margin(6, 6, 6, 6)
    )

  ggsave(here::here(DIRS$figures, "Fig_QC_UMAP_source.png"),
         p_umap_src, width = 180, height = 140, units = "mm",
         dpi = 600, bg = "white")
  ggsave(here::here(DIRS$figures, "Fig_QC_UMAP_source.pdf"),
         p_umap_src, width = 180, height = 140, units = "mm",
         device = "pdf", bg = "white")

  cat("  UMAP QC: condition + source plots exported.\n")
  cat("  NOTE: If samples cluster by source (TCGA vs GTEx) rather than\n")
  cat("  condition, batch effect may be significant. The PCA (FigS1) and\n")
  cat("  UMAP plots together allow visual batch effect assessment.\n")

}, error = function(e) {
  cat("  UMAP skipped:", conditionMessage(e), "\n")
})
