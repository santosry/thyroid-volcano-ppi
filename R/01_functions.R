# ═══════════════════════════════════════════════════════════════════════════════
# R/01_functions.R — Core utility functions
# thyroid-volcano-ppi
# ═══════════════════════════════════════════════════════════════════════════════

# ── F1. Extract gene symbols from KEGG pathway ────────────────────────────────
fetch_kegg_genes <- function(pathway_id) {
  pw <- keggGet(pathway_id)
  stopifnot(length(pw) == 1L)
  g <- pw[[1]]$GENE
  if (is.null(g) || length(g) == 0L) stop("Empty GENE field from KEGG for ", pathway_id)

  genes <- g[seq(2, length(g), by = 2)] |>
    str_remove("\\s*\\[.*$") |>
    str_trim() |>
    str_extract("^[^;]+") |>
    str_trim() |>
    unique() |>
    sort()

  # Remove KEGG readthrough-fusion artifacts (e.g., P3R3URF-PIK3R3)
  genes <- genes[!grepl("-", genes) | nchar(genes) <= 10]
  tibble(pathway_id = pathway_id, gene_symbol = genes)
}

# ── F2. Validate expression data scale ────────────────────────────────────────
validate_expression_scale <- function(expr) {
  frac <- mean(abs(expr - round(expr)) > 0.01, na.rm = TRUE)
  if (frac < 0.01) warning("Expression values appear integer; confirm log2 scale.")
  if (max(expr, na.rm = TRUE) > 30) stop("Max expression >30; data not in log2 scale.")
  cat(sprintf("  Expression QC: max=%.2f | non-integer=%.1f%%\n",
              round(max(expr, na.rm = TRUE), 2), round(frac * 100, 1)))
}

# ── F3. Map gene symbols → STRING protein IDs (REST API) ──────────────────────
map_string_ids <- function(genes, annot_df, taxon = 9606) {
  clean <- annot_df |>
    mutate(gene_symbol = as.character(gene_symbol)) |>
    filter(!is.na(gene_symbol), gene_symbol != "") |>
    distinct(gene_symbol, .keep_all = TRUE)

  stopifnot(nrow(clean) >= 2)

  resp <- httr::POST(
    "https://string-db.org/api/json/get_string_ids",
    body = list(
      identifiers     = paste(clean$gene_symbol, collapse = "\r\n"),
      species         = as.character(taxon),
      limit           = "1",
      caller_identity = "thyroid_volcano_ppi"
    ),
    encode = "form"
  )
  httr::stop_for_status(resp)

  ids <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"), flatten = TRUE)

  result <- ids |>
    dplyr::select(gene_symbol = preferredName, STRING_id = stringId) |>
    left_join(dplyr::select(clean, gene_symbol, regulation), by = "gene_symbol") |>
    filter(!is.na(STRING_id))

  na_n <- sum(is.na(result$regulation))
  if (na_n > 0) {
    cat(sprintf("  Note: %d gene(s) mapped without regulation annotation\n", na_n))
    result$regulation[is.na(result$regulation)] <- "NS"
  }
  result
}

# ── F4. Fetch STRING PPI interactions (REST API) ──────────────────────────────
fetch_string_edges <- function(string_ids, taxon = 9606) {
  resp <- httr::POST(
    "https://string-db.org/api/tsv/network",
    body = list(
      identifiers     = paste(string_ids, collapse = "\r\n"),
      species         = as.character(taxon),
      required_score  = "0",
      caller_identity = "thyroid_volcano_ppi"
    ),
    encode = "form"
  )
  httr::stop_for_status(resp)

  raw <- utils::read.delim(
    text = httr::content(resp, as = "text", encoding = "UTF-8"),
    stringsAsFactors = FALSE, check.names = FALSE
  )

  if (nrow(raw) == 0L) return(tibble(from = character(), to = character(), combined_score = numeric()))
  if (!all(c("stringId_A", "stringId_B") %in% colnames(raw))) {
    stop("STRING REST response missing required columns.")
  }

  raw |>
    as_tibble() |>
    transmute(from = stringId_A, to = stringId_B,
              combined_score = as.numeric(score) * 1000)
}

# ── F5. Build igraph network ──────────────────────────────────────────────────
build_igraph <- function(edges, nodes) {
  graph_from_data_frame(
    d = edges |> transmute(from, to, weight = combined_score),
    directed = FALSE,
    vertices = nodes |> transmute(name = STRING_id, gene_symbol, regulation)
  )
}

# ── F6. Compute centrality metrics ────────────────────────────────────────────
compute_centrality <- function(g) {
  tibble(
    gene_symbol = V(g)$gene_symbol,
    STRING_id   = V(g)$name,
    regulation  = V(g)$regulation,
    degree      = degree(g),
    betweenness = betweenness(g, normalized = TRUE),
    closeness   = closeness(g, normalized = TRUE),
    hub_score   = igraph::hub_score(g)$vector
  ) |> arrange(desc(betweenness))
}

# ── F7. Export table (TSV) ────────────────────────────────────────────────────
export_tsv <- function(x, filepath) {
  if (!grepl("\\.tsv$", filepath)) filepath <- paste0(filepath, ".tsv")
  readr::write_tsv(x, filepath)
  cat(sprintf("  Exported: %s (%d rows × %d cols)\n", filepath, nrow(x), ncol(x)))
}
