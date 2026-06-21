# ═══════════════════════════════════════════════════════════════════════════════
# R/05_ppi.R — PPI Network (Cell Press publication standard)
# thyroid-volcano-ppi — MAIN OUTPUT 2/2
#
# Design philosophy: Cell Press editorial network visualization
# - Largest connected component only
# - Multi-layout auto-selection (FR, KK, Stress, Graphopt)
# - Nodes sized by betweenness, colored by regulation
# - Thin transparent grey edges
# - Only key proteins labeled (hubs + pathway)
# - Same palette and typography as Volcano Plot
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

# ── 4.3. STRING mapping ──────────────────────────────────────────────────────
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

cat(sprintf("  Edges: %d (score >= %d)\n", nrow(edges), THRESHOLD$string))

if (nrow(edges) == 0) {
  stop("No PPI edges after score filtering. Try lowering THRESHOLD$string to 400.")
}

# ── 4.5. Build igraph network ────────────────────────────────────────────────
g <- build_igraph(edges, mapped)

# Extract largest connected component
comp  <- igraph::components(g)
giant <- which.max(comp$csize)
g_cc  <- induced_subgraph(g, V(g)[comp$membership == giant])
g_cc  <- delete_vertices(g_cc, V(g_cc)[igraph::degree(g_cc) == 0])

cat(sprintf("  Network: %d nodes, %d edges (largest CC)\n", vcount(g_cc), ecount(g_cc)))

# ── 4.6. Centrality analysis ──────────────────────────────────────────────────
cent <- compute_centrality(g_cc)

# Hub: top 30% betweenness OR degree >= median in CC
hub_th_bet <- quantile(cent$betweenness[cent$betweenness > 0], 0.70, na.rm = TRUE)
hub_th_deg <- median(cent$degree[cent$degree >= 2], na.rm = TRUE)
cent$is_hub <- with(cent, (betweenness >= hub_th_bet & degree >= 2) |
                          (degree >= hub_th_deg))
cent$is_hub[is.na(cent$is_hub)] <- FALSE

cat(sprintf("  Hubs: %d (betweenness >= %.3f or degree >= %.0f)\n",
            sum(cent$is_hub), round(hub_th_bet, 3), hub_th_deg))

# ── 4.7. Auto-select best layout ──────────────────────────────────────────────
# Test multiple layouts, select the one with best spatial separation
# Metric: ratio of mean edge length to min node distance (higher = better separation)
cat("  Testing layouts...\n")

evaluate_layout <- function(g, layout_fun, dim = 2, ...) {
  set.seed(42)
  lay <- layout_fun(g, dim = dim, ...)
  if (any(is.na(lay)) || nrow(lay) != vcount(g)) return(0)

  # Metric: silhouette-like separation score
  # For each node, compute ratio of min distance to other nodes / mean edge distance
  d <- as.matrix(dist(lay))
  diag(d) <- Inf
  min_dist <- apply(d, 1, min)  # distance to nearest non-self node

  # Edge-based separation
  adj <- as_adjacency_matrix(g)
  edge_dists <- d[which(adj > 0, arr.ind = TRUE)]
  mean_edge <- if (length(edge_dists) > 0) mean(edge_dists, na.rm = TRUE) else 1

  # Score: median of min_dist / mean_edge (higher = better node separation relative to edges)
  score <- median(min_dist / mean_edge, na.rm = TRUE)
  if (!is.finite(score)) score <- 0
  score
}

layouts <- list(
  list(name = "fr",  fun = layout_with_fr,  args = list(niter = 500)),
  list(name = "kk",  fun = layout_with_kk),
  list(name = "graphopt", fun = layout_with_graphopt, args = list(charge = 0.01)),
  list(name = "mds", fun = layout_with_mds),
  list(name = "nicely", fun = function(g, dim, ...) { set.seed(42); layout_nicely(g) })
)

layout_scores <- sapply(layouts, function(l) {
  score <- tryCatch({
    evaluate_layout(g_cc, l$fun, dim = 2)
  }, error = function(e) 0)
  score
})

best_idx  <- which.max(layout_scores)
best_name <- layouts[[best_idx]]$name
best_fun  <- layouts[[best_idx]]$fun

cat(sprintf("  Best layout: %s (score = %.4f)\n", best_name, layout_scores[best_idx]))

# Compute the best layout
set.seed(42)
if (best_name == "fr") {
  lay_coords <- layout_with_fr(g_cc, niter = 1000)
} else if (best_name == "kk") {
  lay_coords <- layout_with_kk(g_cc)
} else if (best_name == "graphopt") {
  lay_coords <- layout_with_graphopt(g_cc, charge = 0.01)
} else if (best_name == "mds") {
  lay_coords <- layout_with_mds(g_cc)
} else {
  lay_coords <- layout_nicely(g_cc)
}

# ── 4.8. Visual attributes stored in graph ────────────────────────────────────
V(g_cc)$x          <- lay_coords[, 1]
V(g_cc)$y          <- lay_coords[, 2]
V(g_cc)$nodedeg    <- igraph::degree(g_cc)
V(g_cc)$betw       <- cent$betweenness
V(g_cc)$node_fill  <- ifelse(V(g_cc)$regulation == "Up", CELL_COLORS$up,
                      ifelse(V(g_cc)$regulation == "Down", CELL_COLORS$down, "grey75"))

# Label strategy: hubs + KEGG pathway genes present in network
hub_genes_ppi <- cent |> filter(is_hub) |> pull(gene_symbol)
kegg_in_net   <- intersect(V(g_cc)$gene_symbol, kegg_list)
label_nodes   <- union(hub_genes_ppi, kegg_in_net)

V(g_cc)$show_label <- V(g_cc)$gene_symbol %in% label_nodes
V(g_cc)$is_hub     <- V(g_cc)$gene_symbol %in% hub_genes_ppi

# Node border: hubs get darker border
V(g_cc)$node_border <- ifelse(V(g_cc)$is_hub, "#222222", "grey55")
V(g_cc)$node_stroke <- ifelse(V(g_cc)$is_hub, 1.0, 0.35)

cat(sprintf("  Labeled proteins: %d (hubs: %d | KEGG: %d)\n",
            length(label_nodes), length(hub_genes_ppi),
            length(kegg_in_net)))

# ── 4.9. Build PPI network plot ──────────────────────────────────────────────
p_ppi <- ggraph(g_cc, layout = "manual", x = V(g_cc)$x, y = V(g_cc)$y) +

  # Edges — very thin, light, transparent
  geom_edge_link(
    aes(width = weight),
    alpha = 0.22,
    color = "#D0D0D0"
  ) +
  scale_edge_width(range = c(0.12, 0.8), guide = "none") +

  # Nodes — filled circles, regulation-colored, sized by betweenness
  geom_node_point(
    aes(size = nodedeg, fill = node_fill, color = node_border, stroke = node_stroke),
    shape = 21
  ) +
  scale_size(range = c(2.5, 8), guide = "none") +
  scale_fill_identity() +
  scale_color_identity() +

  # Labels — only key proteins
  geom_node_text(
    data = . %>% filter(show_label),
    aes(label = gene_symbol),
    size = 2.5,
    fontface = "italic",
    color = "black",
    repel = TRUE,
    bg.color = "white",
    bg.r = 0.12,
    segment.color = "grey55",
    segment.size = 0.2,
    segment.alpha = 0.7,
    box.padding = 0.4,
    point.padding = 0.25,
    max.overlaps = 50,
    force = 4,
    force_pull = 0.3,
    seed = 42
  ) +

  # Theme — minimal, no axes, white background
  theme_void(base_size = 9) +
  theme(
    text = element_text(family = "sans", color = "black"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(8, 8, 8, 8)
  )

# ── 4.10. Manual inset legend (Cell Press style) ──────────────────────────────
x_range <- range(lay_coords[, 1])
y_range <- range(lay_coords[, 2])
leg_x   <- x_range[1] + diff(x_range) * 0.02
leg_y   <- y_range[2] - diff(y_range) * 0.03
leg_gap <- diff(y_range) * 0.045

p_ppi <- p_ppi +
  annotate("point", x = leg_x, y = leg_y, size = 3.5,
           color = "#222222", fill = CELL_COLORS$up, stroke = 1, shape = 21) +
  annotate("text",  x = leg_x + diff(x_range) * 0.06, y = leg_y,
           label = paste0("Up in THCA (", sum(V(g_cc)$regulation == "Up"), ")"),
           size = 2.5, hjust = 0, color = "black", family = "sans") +

  annotate("point", x = leg_x, y = leg_y - leg_gap, size = 3.5,
           color = "grey55", fill = CELL_COLORS$down, stroke = 0.35, shape = 21) +
  annotate("text",  x = leg_x + diff(x_range) * 0.06, y = leg_y - leg_gap,
           label = paste0("Down in THCA (", sum(V(g_cc)$regulation == "Down"), ")"),
           size = 2.5, hjust = 0, color = "black", family = "sans") +

  # Hub indicator
  annotate("point", x = leg_x, y = leg_y - leg_gap * 2, size = 3.5,
           color = "#222222", fill = "white", stroke = 1, shape = 21) +
  annotate("text",  x = leg_x + diff(x_range) * 0.06, y = leg_y - leg_gap * 2,
           label = paste0("Hub protein (", sum(V(g_cc)$is_hub), ")"),
           size = 2.5, hjust = 0, color = "black", family = "sans")

# ── 4.11. Export ──────────────────────────────────────────────────────────────
ggsave(here::here(DIRS$figures, "Fig2_PPI_Network_THCA_DEGs.png"),
       p_ppi, width = 180, height = 165, units = "mm", dpi = 600, bg = "white")

cat(sprintf("  PPI Network exported: Fig2_PPI_Network_THCA_DEGs.png\n"))
cat(sprintf("    %d nodes | %d edges | layout: %s\n", vcount(g_cc), ecount(g_cc), best_name))

# ── 4.12. Export network tables ───────────────────────────────────────────────
export_tsv(mapped, here::here(DIRS$network, "N01_string_mapping.tsv"))
export_tsv(edges,  here::here(DIRS$network, "N02_string_interactions.tsv"))
export_tsv(cent,   here::here(DIRS$network, "N03_centrality_metrics.tsv"))

# PPI network summary
ppi_summary <- tibble(
  metric = c(
    "Input DEGs", "Mapped to STRING", "Mapping rate",
    "Edges (score >= threshold)", "Network nodes", "Network edges",
    "Hub proteins", "Top hub (betweenness)", "Top hub degree",
    "Top hub betweenness", "Clustering coefficient", "Network density",
    "STRING score threshold", "STRING version", "Selected layout"
  ),
  value = c(
    length(deg_genes), nrow(mapped),
    sprintf("%.1f%%", nrow(mapped)/length(deg_genes)*100),
    nrow(edges), vcount(g_cc), ecount(g_cc),
    sum(cent$is_hub), cent$gene_symbol[1], cent$degree[1],
    round(cent$betweenness[1], 4),
    round(transitivity(g_cc, type = "global"), 4),
    round(edge_density(g_cc), 6),
    THRESHOLD$string, STRING_V, best_name
  )
)
export_tsv(ppi_summary, here::here(DIRS$network, "N04_network_summary.tsv"))

# ── 4.13. Hub protein table ───────────────────────────────────────────────────
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

# ── 4.14. KEGG DEGs with PPI centrality ──────────────────────────────────────
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
