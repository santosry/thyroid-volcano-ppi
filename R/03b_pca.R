# ═══════════════════════════════════════════════════════════════════════════════
# R/03b_pca.R — PCA plot (MDS from limma) for quality control
# thyroid-volcano-ppi v3.1.0
#
# Generates PCA/MDS plots to visualize:
#   1. Separation between THCA and Normal groups (biological signal)
#   2. Potential batch effects (TCGA vs GTEx source/study)
#
# PCA is QC/diagnostic — does NOT replace gene-level DEG with limma.
#
# Output: results/figures/Fig_QC_PCA_condition.{png,pdf}
#         results/figures/Fig_QC_PCA_source.{png,pdf}
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── QC: PCA / MDS ──\n")

# ── MDS using limma's plotMDS (designed for expression data) ──────────────────
# Use the filtered expression matrix E and metadata from 03_deg.R

# Create MDS object
mds <- limma::plotMDS(E, top = 500, plot = FALSE)

# Build plot data
pca_df <- data.frame(
  PC1 = mds$x,
  PC2 = mds$y,
  condition = meta$condition,
  study = meta$study,
  stringsAsFactors = FALSE
)

# Variance explained (approximate from eigenvalues)
var_explained <- round(mds$var.explained * 100, 1)

# ── PCA Plot by CONDITION ────────────────────────────────────────────────────
p_pca_cond <- ggplot(pca_df, aes(x = PC1, y = PC2, color = condition)) +
  geom_point(size = 1.8, alpha = 0.70, stroke = 0.3) +
  scale_color_manual(
    values = c("Normal" = "#4477AA", "THCA" = "#AA4488"),
    labels = c("Normal" = "Normal (GTEx)", "THCA" = "THCA (TCGA)")
  ) +
  labs(
    title = "PCA — Colorido por Condição",
    x = paste0("PC1 (", var_explained[1], "%)"),
    y = paste0("PC2 (", var_explained[2], "%)"),
    color = "Condição"
  ) +
  theme_minimal(base_size = FONT_SIZE, base_family = FONT_FAM) +
  theme(
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey92", linewidth = 0.15),
    panel.grid.minor = element_blank(),
    axis.line  = element_line(color = "black", linewidth = 0.35),
    axis.ticks = element_line(color = "black", linewidth = 0.35),
    axis.text  = element_text(color = "black", size = 10),
    axis.title = element_text(color = "black", size = 12),
    legend.position = "right",
    legend.background = element_rect(fill = "white", color = "grey80", linewidth = 0.2),
    legend.key = element_rect(fill = "white", color = NA),
    plot.margin = margin(8, 8, 8, 8)
  )

ggsave(here::here(DIRS$figures, "Fig_QC_PCA_condition.png"),
       p_pca_cond, width = 180, height = 140, units = "mm", dpi = 600, bg = "white")
ggsave(here::here(DIRS$figures, "Fig_QC_PCA_condition.pdf"),
       p_pca_cond, width = 180, height = 140, units = "mm", device = "pdf", bg = "white")

# ── PCA Plot by SOURCE/STUDY (batch effect assessment) ────────────────────────
p_pca_src <- ggplot(pca_df, aes(x = PC1, y = PC2, color = study)) +
  geom_point(size = 1.8, alpha = 0.70, stroke = 0.3) +
  scale_color_manual(
    values = c("TCGA" = "#CC6677", "GTEX" = "#44AA77")
  ) +
  labs(
    title = "PCA — Colorido por Fonte/Estudo (avaliação de batch effect)",
    subtitle = "TCGA (tumoral) vs GTEx (normal). Se houver separação por fonte, batch effect é significativo.",
    x = paste0("PC1 (", var_explained[1], "%)"),
    y = paste0("PC2 (", var_explained[2], "%)"),
    color = "Estudo"
  ) +
  theme_minimal(base_size = FONT_SIZE, base_family = FONT_FAM) +
  theme(
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey92", linewidth = 0.15),
    panel.grid.minor = element_blank(),
    axis.line  = element_line(color = "black", linewidth = 0.35),
    axis.ticks = element_line(color = "black", linewidth = 0.35),
    axis.text  = element_text(color = "black", size = 10),
    axis.title = element_text(color = "black", size = 12),
    legend.position = "right",
    legend.background = element_rect(fill = "white", color = "grey80", linewidth = 0.2),
    legend.key = element_rect(fill = "white", color = NA),
    plot.margin = margin(8, 8, 8, 8)
  )

ggsave(here::here(DIRS$figures, "Fig_QC_PCA_source.png"),
       p_pca_src, width = 180, height = 140, units = "mm", dpi = 600, bg = "white")
ggsave(here::here(DIRS$figures, "Fig_QC_PCA_source.pdf"),
       p_pca_src, width = 180, height = 140, units = "mm", device = "pdf", bg = "white")

cat(sprintf("  PCA: %d samples | PC1: %.1f%% | PC2: %.1f%%\n",
            nrow(pca_df), var_explained[1], var_explained[2]))
cat("  NOTE: PCA is QC only — does not replace gene-level DEG with limma.\n")
cat("  Fig_QC_PCA_condition: colored by biological condition\n")
cat("  Fig_QC_PCA_source: colored by source/study (TCGA vs GTEx)\n")
cat("  If samples cluster by study rather than condition,\n")
cat("  batch effect may dominate biological signal.\n")
cat("  WARNING: TCGA=cancer, GTEx=normal → batch is confounded with condition.\n")
cat("  ComBat/removeBatchEffect NOT applied because batch=condition perfectly.\n")
cat("  Correction would remove the biological signal itself.\n")
