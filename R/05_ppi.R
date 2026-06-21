# ═══════════════════════════════════════════════════════════════════════════════
# R/05_ppi.R — PPI Network (Cell Press publication standard)
# thyroid-volcano-ppi — MAIN OUTPUT 2/2
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── Module 4: PPI Network (Cell Press standard) ──\n")

# ── 4.1. Input validation ────────────────────────────────────────────────────
if (length(deg_genes) < 2) stop("Fewer than 2 DEGs; cannot build PPI network.")
cat(sprintf("  Input DEGs: %d (Up: %d | Down: %d)\n", length(deg_genes), length(up_genes), length(down_genes)))

# ── 4.2. Node annotation ──────────────────────────────────────────────────────
nodes <- tibble(
  gene_symbol = deg_genes,
  regulation  = ifelse(gene_symbol %in% up_genes, "Up",
                       ifelse(gene_symbol %in% down_genes, "Down", "NS"))
)

# ── 4.3. Map to STRING IDs ────────────────────────────────────────────────────
cat("  Mapping genes to STRING protein IDs...\n")
mapped <- map_string_ids(deg_genes, nodes, STRING_TAXON)
cat(sprintf("  Mapped: %d / %d genes\n", nrow(mapped), nrow(nodes)))

if (nrow(mapped) < 2) stop("STRING mapping returned < 2 proteins.")
mapped_ids <- mapped$STRING_id

# ── 4.4. Fetch PPI edges ──────────────────────────────────────────────────────
cat("  Fetching STRING interactions...\n")
edges_raw <- fetch_string_edges(mapped_ids, STRING_TAXON)

edges <- edges_raw |>
  filter(from %in% mapped_ids, to %in% mapped_ids,
         combined_score >= THRESHOLD$string)

cat(sprintf("  Edges: %d (score ≥ %d)\n", nrow(edges), THRESHOLD$string))

if (nrow(edges) == 0) {
  stop("No PPI edges after score filtering. Try lowering THRESHOLD$string to 400.")
}

# ── 4.5. Build network ────────────────────────────────────────────────────────
g <- build_igraph(edges, mapped)

# Extract largest connected component
comp  <- igraph::components(g)
giant <- which.max(comp$csize)
g_cc  <- induced_subgraph(g, V(g)[comp$membership == giant])
g_cc  <- delete_vertices(g_cc, V(g_cc)[degree(g_cc) == 0])

cat(sprintf("  Network: %d nodes, %d edges (largest connected component)\n",
            vcount(g_cc), ecount(g_cc)))

# ── 4.6. Centrality metrics ──────────────────────────────────────────────────
cent <- compute_centrality(g_cc)

# Identify hub proteins: top 25% by betweenness centrality
hub_threshold <- quantile(cent$betweenness[cent$betweenness > 0], 0.75, na.rm = TRUE)
cent$is_hub <- cent$betweenness >= hub_threshold & cent$degree >= 2

cat(sprintf("  Hubs identified: %d (betweenness ≥ %.3f, degree ≥ 2)\n",
            sum(cent$is_hub), round(hub_threshold, 3)))

cat("  Top 10 hub proteins:\n")
print(cent |> filter(is_hub) |> slice_head(n = 10) |>
        dplyr::select(gene_symbol, degree, betweenness, closeness),
      n = 10)

# ── 4.7. PPI Network Plot ────────────────────────────────────────────────────
# Determine which nodes to label: hubs + KEGG pathway genes
hub_genes   <- cent |> filter(is_hub) |> pull(gene_symbol)
label_nodes <- union(hub_genes, intersect(V(g_cc)$gene_symbol, kegg_list))

# Store visual attributes as vertex properties for clean ggraph mapping
V(g_cc)$node_fill   <- ifelse(V(g_cc)$regulation == "Up", CELL_COLORS$up,
                       ifelse(V(g_cc)$regulation == "Down", CELL_COLORS$down, "grey80"))
V(g_cc)$node_border <- ifelse(V(g_cc)$gene_symbol %in% hub_genes,
                               CELL_COLORS$highlight, "grey50")
V(g_cc)$node_stroke <- ifelse(V(g_cc)$gene_symbol %in% hub_genes, 1.0, 0.35)
V(g_cc)$show_label  <- V(g_cc)$gene_symbol %in% label_nodes
V(g_cc)$nodedeg     <- igraph::degree(g_cc)

p_ppi <- ggraph(g_cc, layout = "nicely") +

  # Edges — thin, light, discreet
  geom_edge_link(
    aes(width = weight),
    alpha = 0.25,
    color = CELL_COLORS$edge
  ) +
  scale_edge_width(range = c(0.15, 1.2), guide = "none") +

  # Nodes — filled circles, regulation-colored, hub-highlighted
  geom_node_point(
    aes(size = nodedeg, fill = node_fill, color = node_border, stroke = node_stroke),
    shape = 21
  ) +
  scale_size(range = c(2, 7), guide = "none") +
  scale_fill_identity() +
  scale_color_identity() +

  # Labels — only hubs and KEGG pathway genes
  geom_node_text(
    data = . %>% filter(show_label),
    aes(label = gene_symbol),
    size = 2.3,
    fontface = "italic",
    color = "black",
    repel = TRUE,
    bg.color = "white",
    bg.r = 0.12,
    segment.color = "grey60",
    segment.size = 0.2,
    box.padding = 0.3,
    point.padding = 0.2,
    max.overlaps = 50,
    force = 3,
    seed = 42
  ) +

  CELL_THEME +
  theme(
    legend.position = "none",
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  )

# ── 4.8. Manual color legend (Cell Press style: inset annotation) ─────────────
p_ppi <- p_ppi +
  annotate("point", x = 0.02, y = 0.97, size = 3, color = CELL_COLORS$highlight,
           fill = CELL_COLORS$up, stroke = 1, shape = 21) +
  annotate("text",  x = 0.055, y = 0.97, label = "Upregulated in THCA",
           size = 2.2, hjust = 0, color = "black", family = "sans") +
  annotate("point", x = 0.02, y = 0.93, size = 3, color = "grey50",
           fill = CELL_COLORS$down, stroke = 0.35, shape = 21) +
  annotate("text",  x = 0.055, y = 0.93, label = "Downregulated in THCA",
           size = 2.2, hjust = 0, color = "black", family = "sans")

# ── 4.9. Export ───────────────────────────────────────────────────────────────
ggsave(here::here(DIRS$figures, "Fig2_PPI_Network_THCA_DEGs.png"),
       p_ppi, width = 180, height = 165, units = "mm", dpi = 600, bg = "white")
ggsave(here::here(DIRS$figures, "Fig2_PPI_Network_THCA_DEGs.pdf"),
       p_ppi, width = 180, height = 165, units = "mm", device = "pdf", bg = "white")
ggsave(here::here(DIRS$figures, "Fig2_PPI_Network_THCA_DEGs.svg"),
       p_ppi, width = 180, height = 165, units = "mm", device = "svg", bg = "white")

cat("  PPI Network exported: Fig2_PPI_Network_THCA_DEGs.{png,pdf,svg}\n")

# ── 4.10. Export network tables ───────────────────────────────────────────────
export_tsv(mapped, here::here(DIRS$network, "N01_string_mapping.tsv"))
export_tsv(edges,  here::here(DIRS$network, "N02_string_interactions.tsv"))
export_tsv(cent,   here::here(DIRS$network, "N03_centrality_metrics.tsv"))

# PPI network summary
ppi_summary <- tibble(
  metric = c(
    "Input DEGs", "Mapped to STRING", "Mapping rate",
    "Edges (score ≥ threshold)", "Network nodes", "Network edges",
    "Hub proteins", "Top hub (betweenness)",
    "Top hub degree", "Top hub betweenness",
    "Clustering coefficient", "Network density",
    "STRING score threshold", "STRING version"
  ),
  value = c(
    length(deg_genes), nrow(mapped),
    sprintf("%.1f%%", nrow(mapped)/length(deg_genes)*100),
    nrow(edges), vcount(g_cc), ecount(g_cc),
    sum(cent$is_hub), cent$gene_symbol[1],
    cent$degree[1], round(cent$betweenness[1], 4),
    round(transitivity(g_cc, type = "global"), 4),
    round(edge_density(g_cc), 6),
    THRESHOLD$string, STRING_V
  )
)
export_tsv(ppi_summary, here::here(DIRS$network, "N04_network_summary.tsv"))

# ── 4.11. Hub protein table ──────────────────────────────────────────────────
hub_table <- cent |>
  filter(is_hub) |>
  dplyr::select(gene_symbol, regulation, degree, betweenness, closeness, hub_score) |>
  arrange(desc(betweenness)) |>
  mutate(
    betweenness = round(betweenness, 4),
    closeness   = round(closeness, 6),
    hub_score   = round(hub_score, 4)
  )

export_tsv(hub_table, here::here(DIRS$tables, "T06_hub_proteins.tsv"))

# ── 4.12. KEGG DEGs with PPI centrality (integrated table) ────────────────────
kegg_cent <- kegg_degs |>
  left_join(cent |> dplyr::select(gene_symbol, degree, betweenness, is_hub), by = "gene_symbol") |>
  arrange(desc(abs(logFC))) |>
  mutate(
    logFC       = round(logFC, 3),
    adj.P.Val   = format(adj.P.Val, digits = 2, scientific = TRUE),
    betweenness = round(betweenness, 4)
  )

export_tsv(kegg_cent, here::here(DIRS$tables, "T07_kegg_degs_ppi.tsv"))

cat("\n  PPI Network module complete.\n")
