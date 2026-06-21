# Output Checksums — thyroid-volcano-ppi v1.0.0
#
# All MD5 hashes below were generated on 2026-06-21 after a clean pipeline run.
# Use these to verify that your execution produces identical results.
#
# Verify with:
#   md5sum -c results/CHECKSUMS.md   (Linux/macOS)
#   md5sum --check results/CHECKSUMS.md
#
# ═══════════════════════════════════════════════════════════════════════════════

## Input Data
3e0ccba1c66ac9729b74e1537b791383  data/raw/XENA_THCA.tsv

## Source Code (R/)
ba1c514510e9ffbac5695bdc7b296b9f  R/00_setup.R
cb5b7414782f1974c35dbcf3e583aa0f  R/01_functions.R
e3ff7e1ba43ca26bd0f1650f21ecceea  R/02_import.R
4c77f7b5519a0d74cfce21395425ce21  R/03_deg.R
16bc345df143bbc553efeb15430ba9b3  R/04_volcano.R
b689876a9fb3499a6b3c4561cdf2e435  R/05_ppi.R
5ddc6ccb59283ec50e2ffdf921f66e24  R/06_supplementary.R

## Figures (results/figures/)
bb24f20bbd343404c9509c9f8ff3837a  results/figures/Fig1_Volcano_THCA_vs_Normal.png
21c91eb5a3f2d401bf99e45377cc81ac  results/figures/Fig2_PPI_Network_THCA_DEGs.png

## Main Tables (results/tables/)
9b8ac41a7e3d8bf8f0665e1cff01f06b  results/tables/T01_sample_composition.tsv
e002e49eef3c6627d44170385404f23d  results/tables/T02_deg_summary.tsv
1c8695e36be21ceb2339e05c07d5944b  results/tables/T03_deg_full_results.tsv
f515c001cf4b09414315ec5b50922a28  results/tables/T04_top20_degs.tsv
f9828427bf4be1106145ad51528a451a  results/tables/T05_kegg_missing_genes.tsv
87e76e16c312f1e3db8c54b191959922  results/tables/T06_hub_proteins.tsv
117d3f5fc794b00a583e3345a9ee16f3  results/tables/T07_kegg_degs_ppi.tsv

## Supplementary Tables (results/tables/)
9618ab1f893edf754c48a8c68524ff3a  results/tables/S1_computational_environment.tsv
5f1b35e6cce260d71c0c6ee4883e65ab  results/tables/S1b_system_info.tsv
198c189d11a5bac03b2e0b99b3080ad6  results/tables/S2_external_databases.tsv
cbe1e38769e1140d16e7d53caa3aad7b  results/tables/S3_pipeline_audit_trail.tsv
f362d51f2df5865cfb59d63e299a4a6f  results/tables/S4_ai_assisted_tasks.tsv

## Network Metadata (results/network/)
ceec9b7fd38535ea8e71d284732a73a6  results/network/N01_string_mapping.tsv
429dbbf3bcb48ce7b78d5361ff9b645e  results/network/N02_string_interactions.tsv
a241e03d39d3f6271c89f9932acffe6d  results/network/N03_centrality_metrics.tsv
69f65e92ad6afff2339e04e1f20bd7a9  results/network/N04_network_summary.tsv
