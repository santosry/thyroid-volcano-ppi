# ═══════════════════════════════════════════════════════════════════════════════
# R/03_deg.R — Differential expression analysis (limma)
# thyroid-volcano-ppi
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── Module 2: Differential Expression (limma) ──\n")

# ── 2.1. Transpose to gene × sample (limma convention) ────────────────────────
E <- t(expr)
storage.mode(E) <- "numeric"

# ── 2.2. Filter low-expression genes ─────────────────────────────────────────
keep <- rowMeans(E > THRESHOLD$expr_min) >= THRESHOLD$expr_frac
E <- E[keep, , drop = FALSE]
cat(sprintf("  Gene filter: %d retained / %d removed (%.1f%%)\n",
            sum(keep), sum(!keep), sum(keep)/length(keep)*100))

# ── 2.3. Design matrix ────────────────────────────────────────────────────────
design <- model.matrix(~ 0 + condition, data = meta)
colnames(design) <- levels(meta$condition)
stopifnot(ncol(E) == nrow(design))

# ── 2.4. Fit linear model + empirical Bayes ───────────────────────────────────
fit    <- lmFit(E, design)
contr  <- makeContrasts(THCA_vs_Normal = THCA - Normal, levels = design)
fit2   <- contrasts.fit(fit, contr)
fit2   <- eBayes(fit2)

# ── 2.5. Extract results ─────────────────────────────────────────────────────
deg <- topTable(fit2, coef = "THCA_vs_Normal", number = Inf,
                adjust.method = "BH", sort.by = "P") |>
  rownames_to_column(var = "gene_symbol")

# ── 2.6. Classify DEGs ────────────────────────────────────────────────────────
deg$regulation <- with(deg, ifelse(
  adj.P.Val < THRESHOLD$fdr & logFC >  THRESHOLD$lfc, "Up",
  ifelse(adj.P.Val < THRESHOLD$fdr & logFC < -THRESHOLD$lfc, "Down", "NS")
))

cat("\n  DEG classification:\n")
print(table(deg$regulation))

n_up   <- sum(deg$regulation == "Up")
n_down <- sum(deg$regulation == "Down")
n_deg  <- n_up + n_down

# ── 2.7. KEGG pathway annotation ──────────────────────────────────────────────
kegg_genes <- fetch_kegg_genes(KEGG_ID)
kegg_list  <- kegg_genes$gene_symbol
deg$in_kegg <- deg$gene_symbol %in% kegg_list

kegg_degs <- deg |> filter(in_kegg, regulation != "NS") |>
  dplyr::select(gene_symbol, logFC, AveExpr, adj.P.Val, regulation, B) |>
  arrange(desc(abs(logFC)))

cat(sprintf("\n  KEGG pathway genes: %d total | %d in data | %d DEGs (%d Up, %d Down)\n",
            length(kegg_list),
            sum(deg$in_kegg),
            nrow(kegg_degs),
            sum(kegg_degs$regulation == "Up"),
            sum(kegg_degs$regulation == "Down")))

# Missing KEGG genes (not in expression matrix)
kegg_missing <- setdiff(kegg_list, deg$gene_symbol)
if (length(kegg_missing) > 0) {
  cat("  KEGG genes not detected in expression data:", length(kegg_missing), "\n")
  export_tsv(tibble(gene_symbol = sort(kegg_missing),
                    reason = "Not detected in expression matrix"),
             here::here(DIRS$tables, "T05_kegg_missing_genes.tsv"))
}

# ── 2.8. DEG gene lists ───────────────────────────────────────────────────────
up_genes   <- deg |> filter(regulation == "Up")   |> pull(gene_symbol)
down_genes <- deg |> filter(regulation == "Down") |> pull(gene_symbol)
deg_genes  <- sort(unique(c(up_genes, down_genes)))

# ── 2.9. QC: DEG summary table ───────────────────────────────────────────────
deg_summary <- tibble(
  parameter = c(
    "Total genes tested", "Genes after expression filter",
    "Upregulated (THCA)", "Downregulated (THCA)", "Total DEGs",
    "|log2FC| threshold", "FDR threshold", "Expression filter min",
    "Expression filter fraction", "KEGG pathway", "KEGG genes in data",
    "KEGG DEGs", "KEGG Up", "KEGG Down"
  ),
  value = c(
    nrow(deg), sum(keep), n_up, n_down, n_deg,
    THRESHOLD$lfc, THRESHOLD$fdr, THRESHOLD$expr_min,
    paste0(THRESHOLD$expr_frac * 100, "%"),
    KEGG_ID, sum(deg$in_kegg), nrow(kegg_degs),
    sum(kegg_degs$regulation == "Up"), sum(kegg_degs$regulation == "Down")
  )
)
export_tsv(deg_summary, here::here(DIRS$tables, "T02_deg_summary.tsv"))

# ── 2.10. Export full DEG table ──────────────────────────────────────────────
deg_out <- deg |>
  mutate(
    logFC    = round(logFC, 4),
    AveExpr  = round(AveExpr, 2),
    t        = round(t, 2),
    P.Value  = format(P.Value, digits = 3, scientific = TRUE),
    adj.P.Val = format(adj.P.Val, digits = 3, scientific = TRUE),
    B        = round(B, 2)
  ) |>
  dplyr::select(gene_symbol, logFC, AveExpr, t, P.Value, adj.P.Val, B, regulation, in_kegg) |>
  arrange(adj.P.Val)

export_tsv(deg_out, here::here(DIRS$tables, "T03_deg_full_results.tsv"))

# Top 20 DEGs
top20 <- deg |>
  filter(regulation != "NS") |>
  arrange(desc(abs(logFC))) |>
  slice_head(n = 20) |>
  dplyr::select(gene_symbol, logFC, AveExpr, adj.P.Val, regulation, B, in_kegg) |>
  mutate(logFC = round(logFC, 3), AveExpr = round(AveExpr, 2),
         adj.P.Val = format(adj.P.Val, digits = 2, scientific = TRUE), B = round(B, 1))

export_tsv(top20, here::here(DIRS$tables, "T04_top20_degs.tsv"))

cat("\n  DEG analysis complete. Up:", n_up, "| Down:", n_down, "| Total:", n_deg, "\n")
