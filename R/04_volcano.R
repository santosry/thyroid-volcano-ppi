# ═══════════════════════════════════════════════════════════════════════════════
# R/04_volcano.R — Volcano Plot (Cell Press publication standard)
# thyroid-volcano-ppi — MAIN OUTPUT 1/2
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── Module 3: Volcano Plot (Cell Press standard) ──\n")

# ── 3.1. Prepare data ─────────────────────────────────────────────────────────
deg$pval_plot <- pmax(deg$adj.P.Val, .Machine$double.xmin)
deg$class     <- factor(deg$regulation, levels = c("Up", "Down", "NS"))

# ── 3.2. Select genes to label (objective, reproducible criteria) ─────────────
# Label: top 15 by |logFC| among significant DEGs OR top 5 KEGG pathway DEGs
top15_degs <- deg |>
  filter(regulation != "NS") |>
  arrange(desc(abs(logFC))) |>
  slice_head(n = 15) |>
  pull(gene_symbol)

top5_kegg <- deg |>
  filter(regulation != "NS", in_kegg) |>
  arrange(adj.P.Val) |>
  slice_head(n = 5) |>
  pull(gene_symbol)

label_genes <- union(top15_degs, top5_kegg)
deg$label <- ifelse(deg$gene_symbol %in% label_genes, deg$gene_symbol, "")

# ── 3.3. Build Volcano Plot ──────────────────────────────────────────────────
p <- ggplot(deg, aes(x = logFC, y = -log10(pval_plot))) +

  # Layer 1: non-significant genes (grey, behind)
  geom_point(
    data = subset(deg, regulation == "NS"),
    size = 0.6, alpha = 0.4, color = CELL_COLORS$ns
  ) +

  # Layer 2: significant genes (colored)
  geom_point(
    data = subset(deg, regulation != "NS"),
    aes(color = regulation), size = 1.2, alpha = 0.85
  ) +

  # Layer 3: KEGG pathway genes — open ring highlight
  geom_point(
    data = subset(deg, regulation != "NS" & in_kegg),
    shape = 1, size = 3.2, color = CELL_COLORS$kegg_ring, stroke = 0.7,
    show.legend = FALSE
  ) +

  # Threshold lines
  geom_vline(xintercept = c(-THRESHOLD$lfc, THRESHOLD$lfc),
             linetype = "dashed", linewidth = 0.25, color = "grey50") +
  geom_hline(yintercept = -log10(THRESHOLD$fdr),
             linetype = "dashed", linewidth = 0.25, color = "grey50") +

  # Labels
  geom_text_repel(
    data = subset(deg, label != ""),
    aes(label = label),
    size = 2.5,
    fontface = "italic",
    color = "black",
    max.overlaps = 30,
    box.padding = 0.35,
    point.padding = 0.2,
    segment.size = 0.2,
    segment.color = "grey60",
    min.segment.length = 0.1,
    force = 2,
    seed = 42
  ) +

  # Color scale
  scale_color_manual(
    values = c("Up" = CELL_COLORS$up, "Down" = CELL_COLORS$down),
    labels = c("Up" = paste0("Upregulated in THCA (", n_up, ")"),
               "Down" = paste0("Downregulated in THCA (", n_down, ")")),
    name = NULL
  ) +

  # Axes
  labs(
    x = expression(log[2] ~ "fold change (THCA / Normal)"),
    y = expression(-log[10] ~ "(adjusted " * italic(P) * "-value)")
  ) +

  # Theme
  CELL_THEME +
  theme(
    legend.position = c(0.22, 0.92),
    legend.direction = "vertical",
    legend.background = element_rect(fill = "white", color = "grey80", linewidth = 0.3),
    legend.margin = margin(4, 6, 4, 4),
    legend.key.size = unit(0.5, "cm"),
    legend.spacing.y = unit(0.1, "cm")
  )

# ── 3.4. Export — multiple formats ────────────────────────────────────────────
# PNG 600 dpi (Cell Press raster requirement)
ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.png"),
       p, width = 180, height = 150, units = "mm", dpi = 600, bg = "white")

# PDF (vector)
ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.pdf"),
       p, width = 180, height = 150, units = "mm", device = "pdf", bg = "white")

# SVG (vector, editable)
ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.svg"),
       p, width = 180, height = 150, units = "mm", device = "svg", bg = "white")

cat("  Volcano Plot exported: Fig1_Volcano_THCA_vs_Normal.{png,pdf,svg}\n")
cat(sprintf("    %d genes plotted | %d DEGs | %d labeled\n", nrow(deg), n_deg, length(label_genes)))
