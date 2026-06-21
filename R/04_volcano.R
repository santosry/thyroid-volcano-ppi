# ═══════════════════════════════════════════════════════════════════════════════
# R/04_volcano.R — Volcano Plot (Cell Press reference style)
# thyroid-volcano-ppi — MAIN OUTPUT 1/2
#
# Style: Matches reference example — dense small points, labels on periphery
#        with leader lines, inset legend with counts, open clean axes.
#        No title. No box. Pure editorial aesthetic.
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── M3: Volcano Plot ──\n")

deg$pval_plot <- pmax(deg$adj.P.Val, .Machine$double.xmin)
deg$log_pval  <- -log10(deg$pval_plot)

x_lim <- max(abs(deg$logFC), na.rm = TRUE) * 1.08
y_lim <- max(deg$log_pval, na.rm = TRUE) * 1.08

# ── Label selection ───────────────────────────────────────────────────────────
top_fdr  <- deg |> dplyr::filter(regulation != "NS") |>
  dplyr::arrange(pval_plot) |> dplyr::slice_head(n = 8) |> dplyr::pull(gene_symbol)
top_lfc  <- deg |> dplyr::filter(regulation != "NS") |>
  dplyr::arrange(dplyr::desc(abs(logFC))) |> dplyr::slice_head(n = 6) |> dplyr::pull(gene_symbol)
top_kegg <- deg |> dplyr::filter(regulation != "NS", in_kegg) |>
  dplyr::arrange(pval_plot) |> dplyr::slice_head(n = 6) |> dplyr::pull(gene_symbol)

label_set <- union(union(top_fdr, top_lfc), top_kegg)
if (exists("cent") && is.data.frame(cent)) {
  hubs <- cent |> dplyr::filter(is_hub) |> dplyr::pull(gene_symbol)
  label_set <- union(label_set, intersect(hubs, deg$gene_symbol))
}
deg$label <- ifelse(deg$gene_symbol %in% label_set, deg$gene_symbol, "")

cat(sprintf("  Labels: %d\n", length(label_set)))

# ── Volcano Plot ──────────────────────────────────────────────────────────────
p <- ggplot(deg, aes(x = logFC, y = log_pval)) +

  # NS: tiny grey dots, very light
  geom_point(
    data = subset(deg, regulation == "NS"),
    size = 0.25, alpha = 0.30, color = CELL_COLORS$ns, shape = 16
  ) +

  # DEGs: colored, slightly larger
  geom_point(
    data = subset(deg, regulation != "NS"),
    aes(color = regulation),
    size = 0.65, alpha = 0.85, shape = 16
  ) +

  # KEGG pathway: subtle open ring
  geom_point(
    data = subset(deg, regulation != "NS" & in_kegg),
    shape = 1, size = 1.8, stroke = 0.30, color = "#555555", show.legend = FALSE
  ) +

  # Threshold lines: very light dotted
  geom_vline(xintercept = c(-THRESHOLD$lfc, THRESHOLD$lfc),
             linetype = "dotted", linewidth = 0.18, color = "#888888") +
  geom_hline(yintercept = -log10(THRESHOLD$fdr),
             linetype = "dotted", linewidth = 0.18, color = "#888888") +

  # Gene labels: placed to periphery with clean leader lines
  ggrepel::geom_text_repel(
    data = subset(deg, label != ""),
    aes(label = label, color = regulation),
    size = 2.5, fontface = "italic",
    max.overlaps = 60,
    box.padding = 0.55, point.padding = 0.25,
    segment.size = 0.18, segment.color = "grey55",
    min.segment.length = 0.03,
    force = 1, force_pull = 0.3,
    nudge_x = 0.25, nudge_y = 0.25,
    direction = "both",
    seed = 42, show.legend = FALSE
  ) +

  scale_color_manual(
    values = c("Up" = CELL_COLORS$up, "Down" = CELL_COLORS$down)
  ) +

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

  # True Cell Press theme: open axes, no box, clean
  theme_classic(base_size = 8) +
  theme(
    text             = element_text(family = "sans", color = "black", size = 8),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid       = element_blank(),
    panel.border     = element_blank(),
    axis.line        = element_line(color = "black", linewidth = 0.3),
    axis.ticks       = element_line(color = "black", linewidth = 0.3),
    axis.ticks.length = unit(1.0, "mm"),
    axis.text        = element_text(color = "black", size = 7),
    axis.title       = element_text(color = "black", size = 8),
    legend.position  = "none",
    plot.margin      = margin(4, 6, 4, 4)
  )

# ── Inset legend (top-left area, clean text) ──────────────────────────────────
lg_x <- -x_lim * 0.70
lg_y <- y_lim * 0.97
dy   <- y_lim * 0.055

p <- p +
  annotate("point", x = lg_x, y = lg_y, size = 2.0,
           color = CELL_COLORS$up, fill = CELL_COLORS$up, shape = 21, stroke = 0.4) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y,
           label = paste0("Upregulated (", n_up, ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans") +
  annotate("point", x = lg_x, y = lg_y - dy, size = 2.0,
           color = CELL_COLORS$down, fill = CELL_COLORS$down, shape = 21, stroke = 0.4) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y - dy,
           label = paste0("Downregulated (", n_down, ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans") +
  annotate("point", x = lg_x, y = lg_y - dy * 2, size = 2.0,
           color = CELL_COLORS$ns, fill = CELL_COLORS$ns, shape = 21, stroke = 0.4) +
  annotate("text",  x = lg_x + x_lim * 0.09, y = lg_y - dy * 2,
           label = paste0("Not significant (", sum(deg$regulation == "NS"), ")"),
           size = 2.2, hjust = 0, color = "black", family = "sans")

ggsave(here::here(DIRS$figures, "Fig1_Volcano_THCA_vs_Normal.png"),
       p, width = 180, height = 150, units = "mm", dpi = 600, bg = "white")
cat(sprintf("  ✓ Volcano: %d genes | %d DEGs\n", nrow(deg), n_deg))
