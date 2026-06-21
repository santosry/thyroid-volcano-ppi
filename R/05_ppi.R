# ═══════════════════════════════════════════════════════════════════════════════
# R/05_ppi.R — PPI Network (Cell Press reference style)
# thyroid-volcano-ppi — MAIN OUTPUT 2/2
#
# Style: Matches reference example — clean, sparse, editorial.
#        Thin edges, small labeled nodes, hub highlighted.
#        Same palette as Volcano. No title.
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── M4: PPI Network ──\n")

if (length(deg_genes) < 2) stop("Need ≥2 DEGs for PPI network.")
cat(sprintf("  DEGs: %d (↑%d ↓%d)\n", length(deg_genes), length(up_genes), length(down_genes)))

nodes <- tibble(
  gene_symbol = deg_genes,
  regulation  = ifelse(gene_symbol %in% up_genes, "Up",
                       ifelse(gene_symbol %in% down_genes, "Down", "NS"))
)

cat("  STRING mapping...\n")
mapped <- map_string_ids(nodes, STRING_TAXON)
cat(sprintf("  Mapped: %d/%d\n", nrow(mapped), nrow(nodes)))
if (nrow(mapped) < 2) stop("Need ≥2 mapped proteins.")
mapped_ids <- mapped$STRING_id

cat("  Fetching edges...\n")
edges <- fetch_string_edges(mapped_ids, STRING_TAXON) |>
  dplyr::filter(from %in% mapped_ids, to %in% mapped_ids,
                combined_score >= THRESHOLD$string)
cat(sprintf("  Edges: %d (≥%d)\n", nrow(edges), THRESHOLD$string))
if (nrow(edges) == 0) stop("No edges. Lower THRESHOLD$string to 400.")

g <- build_igraph(edges, mapped)
comp  <- igraph::components(g)
giant <- which.max(comp$csize)
g_cc  <- igraph::induced_subgraph(g, igraph::V(g)[comp$membership == giant])
g_cc  <- igraph::delete_vertices(g_cc, igraph::V(g_cc)[igraph::degree(g_cc) == 0])
cat(sprintf("  Network: %d nodes, %d edges\n", igraph::vcount(g_cc), igraph::ecount(g_cc)))

cent <- compute_centrality(g_cc)
hub_th_bet <- quantile(cent$betweenness[cent$betweenness > 0], 0.75, na.rm = TRUE)
cent$is_hub <- (cent$betweenness >= hub_th_bet & cent$degree >= 2) | cent$degree >= 3
cent$is_hub[is.na(cent$is_hub)] <- FALSE
cat(sprintf("  Hubs: %d\n", sum(cent$is_hub)))

# ── Auto-select best layout ──────────────────────────────────────────────────
cat("  Layout...\n")
layouts <- list(
  list(name = "fr",       fun = igraph::layout_with_fr,       args = list(niter = 1000)),
  list(name = "kk",       fun = igraph::layout_with_kk),
  list(name = "graphopt", fun = igraph::layout_with_graphopt, args = list(charge = 0.01)),
  list(name = "mds",      fun = igraph::layout_with_mds)
)
scores <- sapply(layouts, function(l) {
  tryCatch(evaluate_layout(g_cc, l$fun, dim = 2), error = function(e) 0)
})
best <- layouts[[which.max(scores)]]
cat(sprintf("  Best: %s (%.4f)\n", best$name, max(scores)))

set.seed(42)
lay <- do.call(best$fun, c(list(g_cc, dim = 2), best$args))
if (any(is.na(lay)) || nrow(lay) != igraph::vcount(g_cc)) {
  lay <- igraph::layout_nicely(g_cc)
  best$name <- "nicely"
}

# ── Visual attributes ────────────────────────────────────────────────────────
V(g_cc)$x          <- lay[, 1]
V(g_cc)$y          <- lay[, 2]
V(g_cc)$nodedeg    <- igraph::degree(g_cc)
V(g_cc)$node_fill  <- ifelse(V(g_cc)$regulation == "Up", CELL_COLORS$up,
                      ifelse(V(g_cc)$regulation == "Down", CELL_COLORS$down, "grey70"))

hub_ppi   <- cent |> dplyr::filter(is_hub) |> dplyr::pull(gene_symbol)
kegg_net  <- intersect(V(g_cc)$gene_symbol, kegg_list)
V(g_cc)$show_label <- V(g_cc)$gene_symbol %in% union(hub_ppi, kegg_net)
V(g_cc)$is_hub     <- V(g_cc)$gene_symbol %in% hub_ppi
V(g_cc)$border     <- ifelse(V(g_cc)$is_hub, "#1A1A1A", "grey60")
V(g_cc)$bstroke    <- ifelse(V(g_cc)$is_hub, 0.8, 0.25)

# ── Build PPI plot ───────────────────────────────────────────────────────────
p_ppi <- ggraph(g_cc, layout = "manual", x = V(g_cc)$x, y = V(g_cc)$y) +

  # Edges: very subtle, thin, transparent
  geom_edge_link(
    aes(width = weight), alpha = 0.15, color = "#C8C8C8"
  ) +
  scale_edge_width(range = c(0.08, 0.55), guide = "none") +

  # Nodes: colored circles, sized by degree
  geom_node_point(
    aes(size = nodedeg, fill = node_fill, color = border, stroke = bstroke),
    shape = 21
  ) +
  scale_size(range = c(1.8, 8), guide = "none") +
  scale_fill_identity() +
  scale_color_identity() +

  # Labels: clean, italic, outside nodes
  geom_node_text(
    data = . %>% dplyr::filter(show_label),
    aes(label = gene_symbol),
    size = 2.2, fontface = "italic", color = "black",
    repel = TRUE, bg.color = "white", bg.r = 0.08,
    segment.color = "grey55", segment.size = 0.15,
    box.padding = 0.30, point.padding = 0.18,
    max.overlaps = 50, force = 5, force_pull = 0.35, seed = 42
  ) +

  theme_void(base_size = 8) +
  theme(
    text = element_text(family = "sans", color = "black"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(4, 4, 4, 4)
  )

# ── Inset legend ──────────────────────────────────────────────────────────────
xr <- range(lay[, 1]); yr <- range(lay[, 2])
lx <- xr[1] + diff(xr) * 0.015
ly <- yr[2] - diff(yr) * 0.025
gap <- diff(yr) * 0.04

p_ppi <- p_ppi +
  annotate("point", x = lx, y = ly, size = 2.5,
           color = "#1A1A1A", fill = CELL_COLORS$up, stroke = 0.6, shape = 21) +
  annotate("text",  x = lx + diff(xr) * 0.06, y = ly,
           label = paste0("Up in THCA (", sum(V(g_cc)$regulation == "Up"), ")"),
           size = 2.0, hjust = 0, color = "black", family = "sans") +
  annotate("point", x = lx, y = ly - gap, size = 2.5,
           color = "grey60", fill = CELL_COLORS$down, stroke = 0.25, shape = 21) +
  annotate("text",  x = lx + diff(xr) * 0.06, y = ly - gap,
           label = paste0("Down (", sum(V(g_cc)$regulation == "Down"), ")"),
           size = 2.0, hjust = 0, color = "black", family = "sans") +
  annotate("point", x = lx, y = ly - gap * 2, size = 2.5,
           color = "#1A1A1A", fill = "white", stroke = 0.6, shape = 21) +
  annotate("text",  x = lx + diff(xr) * 0.06, y = ly - gap * 2,
           label = paste0("Hub (", sum(V(g_cc)$is_hub), ")"),
           size = 2.0, hjust = 0, color = "black", family = "sans")

# ── Export ────────────────────────────────────────────────────────────────────
ggsave(here::here(DIRS$figures, "Fig2_PPI_Network_THCA_DEGs.png"),
       p_ppi, width = 180, height = 165, units = "mm", dpi = 600, bg = "white")
cat(sprintf("  ✓ PPI: %d nodes | %d edges | %s\n",
            igraph::vcount(g_cc), igraph::ecount(g_cc), best$name))

# ── Tables ────────────────────────────────────────────────────────────────────
export_tsv(mapped, here::here(DIRS$network, "N01_string_mapping.tsv"))
export_tsv(edges,  here::here(DIRS$network, "N02_string_interactions.tsv"))
export_tsv(cent,   here::here(DIRS$network, "N03_centrality_metrics.tsv"))

ppi_summary <- tibble(
  metric = c("Input DEGs","Mapped STRING","Mapping rate",
             "Edges (≥threshold)","Nodes","Edges",
             "Hub proteins","Top hub","Top hub degree",
             "Top hub betweenness","Clustering coeff","Density",
             "STRING score","STRING version","Layout"),
  value = c(
    length(deg_genes), nrow(mapped),
    sprintf("%.1f%%", nrow(mapped)/length(deg_genes)*100),
    nrow(edges), igraph::vcount(g_cc), igraph::ecount(g_cc),
    sum(cent$is_hub), cent$gene_symbol[1], cent$degree[1],
    round(cent$betweenness[1],4),
    round(igraph::transitivity(g_cc, type="global"),4),
    round(igraph::edge_density(g_cc),6),
    THRESHOLD$string, STRING_V, best$name
  )
)
export_tsv(ppi_summary, here::here(DIRS$network, "N04_network_summary.tsv"))

hub_table <- cent |> dplyr::filter(is_hub) |>
  dplyr::select(gene_symbol, regulation, degree, betweenness, closeness, hub_score) |>
  dplyr::arrange(dplyr::desc(betweenness)) |>
  dplyr::mutate(betweenness=round(betweenness,4), closeness=round(closeness,6),
                hub_score=round(hub_score,4))
export_tsv(hub_table, here::here(DIRS$tables, "T06_hub_proteins.tsv"))

kegg_cent <- kegg_degs |>
  dplyr::left_join(cent |> dplyr::select(gene_symbol, degree, betweenness, is_hub),
                   by="gene_symbol") |>
  dplyr::arrange(dplyr::desc(abs(logFC))) |>
  dplyr::mutate(logFC=round(logFC,3),
                adj.P.Val=format(adj.P.Val, digits=2, scientific=TRUE),
                betweenness=round(betweenness,4))
export_tsv(kegg_cent, here::here(DIRS$tables, "T07_kegg_degs_ppi.tsv"))
cat("  PPI done.\n")
