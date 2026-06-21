# ═══════════════════════════════════════════════════════════════════════════════
# R/04_volcano.R — Volcano Plot (Cell Press publication standard)
# thyroid-volcano-ppi — MAIN OUTPUT 1/2
#
# Design philosophy: Cell Press editorial style
# - White background, no grid, minimal theme
# - Small dense points with alpha blending
# - Labels on sides connected by discrete segment lines
# - Dark editorial red (Up) / dark blue (Down) / light grey (NS)
# - Legend with counts inset
# - Sans-serif typography throughout
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── Module 3: Volcano Plot (Cell Press standard) ──\n")

# ── 3.1. Prepare data ─────────────────────────────────────────────────────────
deg$pval_plot <- pmax(deg$adj.P.Val, .Machine$double.xmin)

# Cap logFC for display symmetry
logfc_max  <- max(abs(deg$logFC), na.rm = TRUE) * 1.1
y_max      <- max(-log10(deg$pval_plot), na.rm = TRUE) * 1.05

# ── 3.2. Gene label selection (objective, multi-criteria) ─────────────────────
# Criteria:
#   a) Top 8 by -log10(FDR) among DEGs
#   b) Top 6 by |log2FC| among DEGs  
#   c) KEGG pathway DEGs (up to 6, by significance)
#   d) Hub genes from PPI network (if available)
# Union of all criteria

top_fdr <- deg |>
  filter(regulation != "NS") |>
  arrange(pval_plot) |>
  slice_head(n = 8) |>
  pull(gene_symbol)

top_lfc <- deg |>
  filter(regulation != "NS") |>
  arrange(desc(abs(logFC))) |>
  slice_head(n = 6) |>
  pull(gene_symbol)

top_kegg <- deg |>
  filter(regulation != "NS", in_kegg) |>
  arrange(pval_plot) |>
  slice_head(n = 6) |>
  pull(gene_symbol)

label_set <- union(union(top_fdr, top_lfc), top_kegg)

# Add hub genes if PPI centrality exists (loaded from 05_ppi.R later, 
# but we check here in case modules run independently)
if (exists("cent")) {
  hub_genes_volcano <- cent |>
    filter(is_hub) |>
    pull(gene_symbol)
  label_set <- union(label_set, intersect(hub_genes_volcano, deg$gene_symbol))
}

deg$label <- ifelse(deg$gene_symbol %in% label_set, deg$gene_symbol, "")

cat(sprintf("  Genes labeled: %d (top FDR: %d | top LFC: %d | KEGG: %d)\n",
            length(label_set), length(top_fdr), length(top_lfc), length(top_kegg)))

# ── 3.3. Build Volcano Plot ──────────────────────────────────────────────────
p <- ggplot(deg, aes(x = logFC, y = -log10(pval_plot))) +

  # Layer 1: NS genes — very light, small, behind
  geom_point(
    data = subset(deg, regulation == "NS"),
    size = 0.5, alpha = 0.35,
    color = CELL_COLORS$ns
  ) +

  # Layer 2: Significant genes — larger, colored
  geom_point(
    data = subset(deg, regulation != "NS"),
    aes(color = regulation),
    size = 1.3, alpha = 0.80
  ) +

  # Layer 3: KEGG pathway highlights — subtle ring
  geom_point(
    data = subset(deg, regulation != "NS" & in_kegg),
    shape = 1, size = 2.6, stroke = 0.5,
    color = "#444444",
    show.legend = FALSE
  ) +

  # Threshold lines — thin, dashed, dark grey
  geom_vline(
    xintercept = c(-THRESHOLD$lfc, THRESHOLD$lfc),
    linetype = "dashed", linewidth = 0.2, color = "grey40"
  ) +
  geom_hline(
    yintercept = -log10(THRESHOLD$fdr),
    linetype = "dashed", linewidth = 0.2, color = "grey40"
  ) +

  # Gene labels — ggrepel with segments, placed to sides
  geom_text_repel(
    data = subset(deg, label != ""),
    aes(label = label, color = regulation),
    size = 2.7,
    fontface = "italic",
    max.overlaps = 50,
    box.padding = 0.6,
    point.padding = 0.3,
    segment.size = 0.25,
    segment.color = "grey55",
    segment.alpha = 0.7,
    min.segment.length = 0.05,
    force = 3,
    force_pull = 0.3,
    nudge_x = 0.15,
    nudge_y = 0.15,
    seed = 42,
    show.legend = FALSE
  ) +

  # Color scale — Cell Press editorial: dark vermilion / dark steel blue
  scale_color_manual(
    values = c("Up" = CELL_COLORS$up, "Down" = CELL_COLORS$down),
    name = NULL
  ) +

  # Axes
  scale_x_continuous(
    limits = c(-logfc_max, logfc_max),
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  scale_y_continuous(
    limits = c(0, y_max),
    expand = expansion(mult = c(0.01, 0.03))
  ) +

  labs(
    x = expression(log[2] ~ "fold change (THCA / Normal)"),
    y = expression(-log[10] ~ "(adjusted " * italic(P) * "-value)")
  ) +

  # Minimal Cell Press theme
  theme_classic(base_size = 9) +
  theme(
    text            = element_text(family = "sans", color = "black"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid      = element_blank(),
    panel.border    = element_rect(fill = NA, color = "black", linewidth = 0.4),
    axis.line       = element_blank(),
    axis.ticks      = element_line(color = "black", linewidth = 0.3),
    axis.ticks.length = unit(1.5, "mm"),
    axis.text       = element_text(color = "black", size = 8),
    axis.title      = element_text(color = "black", size = 9),
    legend.position = "none",
    plot.margin     = margin(10, 12, 8, 8)
  )

# ── 3.4. Add manual legend annotation (Cell Press style) ──────────────────────
# Placed as inset text in the plot area, with colored dots
y_top <- y_max * 0.97
x_left <- -logfc_max * 0.75

p <- p +
  # Upregulated
  annotate("point", x = x_left, y = y_top, size = 2.5,
           color = CELL_COLORS$up, fill = CELL_COLORS$up, shape = 21, stroke = 0.6) +
  annotate("text",  x = x_left + logfc_max * 0.08, y = y_top,
           label = paste0("Upregulated (", n_up, ")"),
           size = 2.8, hjust = 0, color = "black", family = "sans") +
  # Downregulated
  annotate("point", x = x_left, y = y_top - y_max * 0.055, size = 2.5,
           color = CELL_COLORS$down, fill = CELL_COLORS$down, shape = 21, stroke = 0.6) +
  annotate("text",  x = x_left + logfc_max * 0.08, y = y_top - y_max * 0.055,
           label = paste0("Downregulated (", n_down, ")"),
           size = 2.8, hjust = 0, color = "black", family = "sans") +
  # Not significant
  annotate("point", x = x_left, y = y_top - y_max * 0.11, size = 2.5,
           color = CELL_COLORS$ns, fill = CELL_COLORS$ns, shape = 21, stroke = 0.6) +
  annotate("text",  x = x_left + logfc_max * 0.08, y = y_top - y_max * 0.11,
           label = paste0("Not significant (", sum(deg$regulation == "NS"), ")"),
           size = 2.8, hjust = 0, color = "black", family = "sans")

# ── 3.5. Export (PNG only, 600 dpi, 180mm wide) ───────────────────────────────
ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.png"),
       p, width = 180, height = 150, units = "mm", dpi = 600, bg = "white")

cat("  Volcano Plot exported: Fig1_Volcano_THCA_vs_Normal.png\n")
cat(sprintf("    %d genes | %d DEGs | %d labeled\n", nrow(deg), n_deg, length(label_set)))
