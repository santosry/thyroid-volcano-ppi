# ═══════════════════════════════════════════════════════════════════════════════
# R/04_volcano.R — Volcano Plot (Cell Press standard)
# thyroid-volcano-ppi — MAIN OUTPUT 1/2
#
# Design: Cell Press editorial — open axes, no box, minimal ink,
#         dark sober palette, labels with leader lines, inset legend.
#
# AUDIT: ✓ No absolute legend positions  ✓ Label criteria documented
#        ✓ Axis styling consistent  ✓ Export 600dpi PNG only
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── M3: Volcano Plot (Cell Press) ──\n")

# ── 3.1. Data preparation ────────────────────────────────────────────────────
deg$pval_plot <- pmax(deg$adj.P.Val, .Machine$double.xmin)
deg$log_pval  <- -log10(deg$pval_plot)

# Plot bounds (symmetric x, padded y)
x_lim <- max(abs(deg$logFC), na.rm = TRUE) * 1.08
y_lim <- max(deg$log_pval, na.rm = TRUE) * 1.06

# ── 3.2. Label selection (reproducible multi-criteria) ───────────────────────
top_fdr  <- deg |> dplyr::filter(regulation != "NS") |>
  dplyr::arrange(pval_plot) |> dplyr::slice_head(n = 8) |> dplyr::pull(gene_symbol)

top_lfc  <- deg |> dplyr::filter(regulation != "NS") |>
  dplyr::arrange(dplyr::desc(abs(logFC))) |> dplyr::slice_head(n = 6) |>
  dplyr::pull(gene_symbol)

top_kegg <- deg |> dplyr::filter(regulation != "NS", in_kegg) |>
  dplyr::arrange(pval_plot) |> dplyr::slice_head(n = 6) |> dplyr::pull(gene_symbol)

label_set <- union(union(top_fdr, top_lfc), top_kegg)
if (exists("cent") && is.data.frame(cent)) {
  hubs <- cent |> dplyr::filter(is_hub) |> dplyr::pull(gene_symbol)
  label_set <- union(label_set, intersect(hubs, deg$gene_symbol))
}
deg$label <- ifelse(deg$gene_symbol %in% label_set, deg$gene_symbol, "")

cat(sprintf("  Labels: %d genes\n", length(label_set)))

# ── 3.3. Volcano Plot — Cell Press aesthetic ─────────────────────────────────
# Key: open axes (no box), thin tick marks inward, small precise points,
#      labels with leader lines, inset legend with counts.
p <- ggplot(deg, aes(x = logFC, y = log_pval)) +

  # NS points — very light, small, behind
  geom_point(
    data = subset(deg, regulation == "NS"),
    size = 0.35, alpha = 0.30, color = CELL_COLORS$ns, shape = 16
  ) +

  # Significant points — colored, slightly larger
  geom_point(
    data = subset(deg, regulation != "NS"),
    aes(color = regulation),
    size = 0.75, alpha = 0.82, shape = 16
  ) +

  # KEGG pathway highlight — subtle ring
  geom_point(
    data = subset(deg, regulation != "NS" & in_kegg),
    shape = 1, size = 2.0, stroke = 0.35, color = "#666666", show.legend = FALSE
  ) +

  # Threshold lines — thin, dashed, grey
  geom_vline(xintercept = c(-THRESHOLD$lfc, THRESHOLD$lfc),
             linetype = "dotted", linewidth = 0.2, color = CELL_COLORS$line) +
  geom_hline(yintercept = -log10(THRESHOLD$fdr),
             linetype = "dotted", linewidth = 0.2, color = CELL_COLORS$line) +

  # Labels — ggrepel with leader lines to sides
  ggrepel::geom_text_repel(
    data = subset(deg, label != ""),
    aes(label = label, color = regulation),
    size = 2.4, fontface = "italic",
    max.overlaps = 50,
    box.padding = 0.5, point.padding = 0.25,
    segment.size = 0.2, segment.color = "grey60", segment.alpha = 0.8,
    min.segment.length = 0.02,
    force = 4, force_pull = 0.5,
    nudge_x = 0.2, nudge_y = 0.2,
    direction = "both",
    seed = 42, show.legend = FALSE
  ) +

  # Colors
  scale_color_manual(
    values = c("Up" = CELL_COLORS$up, "Down" = CELL_COLORS$down)
  ) +

  # Axes
  scale_x_continuous(
    limits = c(-x_lim, x_lim),
    breaks = pretty(c(-x_lim, x_lim), 6),
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    limits = c(0, y_lim),
    expand = c(0, 0)
  ) +

  labs(
    x = expression(log[2] ~ "fold change (THCA / Normal)"),
    y = expression(-log[10] ~ "(adjusted " * italic(P) * "-value)")
  ) +

  # Cell Press theme: open axes, no box, minimal
  theme_classic(base_size = 8) +
  theme(
    text            = element_text(family = "sans", color = "black", size = 8),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid      = element_blank(),
    panel.border    = element_blank(),
    axis.line       = element_line(color = "black", linewidth = 0.3),
    axis.ticks      = element_line(color = "black", linewidth = 0.3),
    axis.ticks.length = unit(1.2, "mm"),
    axis.text       = element_text(color = "black", size = 7),
    axis.title      = element_text(color = "black", size = 8),
    legend.position = "none",
    plot.margin     = margin(6, 8, 4, 4)
  )

# ── 3.4. Inset legend (top-right, clean annotation) ──────────────────────────
# Position relative to data coordinates — top-left area
lg_x <- -x_lim * 0.72
lg_y <- y_lim * 0.97
dy   <- y_lim * 0.058

p <- p +
  annotate("point", x = lg_x, y = lg_y, size = 2.2,
           color = CELL_COLORS$up, fill = CELL_COLORS$up, shape = 21, stroke = 0.5) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y,
           label = paste0("Upregulated (", n_up, ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans") +

  annotate("point", x = lg_x, y = lg_y - dy, size = 2.2,
           color = CELL_COLORS$down, fill = CELL_COLORS$down, shape = 21, stroke = 0.5) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y - dy,
           label = paste0("Downregulated (", n_down, ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans") +

  annotate("point", x = lg_x, y = lg_y - dy * 2, size = 2.2,
           color = CELL_COLORS$ns, fill = CELL_COLORS$ns, shape = 21, stroke = 0.5) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y - dy * 2,
           label = paste0("Not significant (", sum(deg$regulation == "NS"), ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans")

# ── 3.5. Export — PNG 600dpi only ────────────────────────────────────────────
ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.png"),
       p, width = 180, height = 150, units = "mm", dpi = 600, bg = "white")

cat(sprintf("  ✓ Volcano: %d genes | %d DEGs\n", nrow(deg), n_deg))
