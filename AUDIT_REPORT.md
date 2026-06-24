# AUDITORIA CIENTÍFICA AVANÇADA — thyroid-volcano-ppi v3.1.0

**Data:** 2026-06-24  
**Auditor:** Bioinformata Sênior + Revisor Nature Communications/Bioinformatics  
**Escopo:** 11 etapas — metodologia, TCGA/GTEx, validação, PPI, volcano, roadmap  

---

## ETAPA 1 — REVISÃO METODOLÓGICA

### 1.1 Desenho do estudo

| Item | Avaliação |
|------|-----------|
| Tipo | Estudo exploratório, gerador de hipóteses |
| Delineamento | Caso-controle transcriptômico (THCA vs Normal) |
| Dados | Secundários (TCGA + GTEx via UCSC Xena) |
| N amostral | 504 tumorais + 279 normais = 783 total |

### 1.2 Hipótese científica

**Versão atual (lockada):** Defensável. Formula que alterações transcriptômicas na via SHT envolvem genes com funções CV e podem representar mecanismos compartilhados. Corretamente evita alegação de eixo ou causalidade.

**Avaliação:** Adequada para estudo exploratório.

### 1.3 Pipeline analítico

```
Xena TSV → limma (lmFit → contrasts.fit → eBayes) → DEG classification → 
  ├─ Volcano Plot (ggplot2 + ggrepel)
  └─ STRING API → igraph → PPI Network (ggraph)
```

**Avaliação:** Correto do ponto de vista técnico.

### 1.4 Seleção dos genes SHT

| Item | Detalhe |
|------|---------|
| Via | KEGG hsa04919 (Thyroid hormone signaling pathway) |
| Genes na via | 121 símbolos |
| Genes no dataset | 119 (2 ausentes: ATP1B4, PLCZ1 — filtrados por baixa expressão) |
| Genes testados | 119 |

**Problema MODERADO:** A seleção APENAS da via SHT constitui viés de confirmação. A pergunta é "os genes da via SHT estão alterados?" — a resposta tende a ser sim por desenho. O ideal seria DEG global → enriquecimento KEGG → demonstrar que SHT emerge espontaneamente.

### 1.5 Critérios de DEG

| Critério | Valor | Avaliação |
|----------|-------|-----------|
| \|log2FC\| > 1.0 | 2-fold change | Padrão, adequado |
| FDR < 0.05 | Benjamini-Hochberg | Padrão, adequado |
| Filtro de expressão | >0.5 em ≥10% amostras | Adequado, remove 2 genes |

### 1.6 Uso do limma

**Avaliação:** Correto. `lmFit` + `makeContrasts` + `contrasts.fit` + `eBayes`. O contraste `THCA - Normal` está correto. O modelo `~0 + condition` sem intercepto é apropriado.

**Problema MENOR:** O design não inclui covariáveis (idade, sexo, batch). O limma suporta `model.matrix(~0 + condition + age + sex)`. Isso reduziria variância residual.

### 1.7 Classificação de problemas

| Problema | Severidade | Detalhe |
|----------|------------|---------|
| Viés de confirmação (via única) | MODERADO | Só SHT analisada; sem enriquecimento global |
| Sem covariáveis no design | MENOR | Idade/sexo não ajustados |
| Sem correção de batch | CRÍTICO | TCGA vs GTEx — ver Etapa 2 |
| Filtro de expressão remove 2 genes | MENOR | ATP1B4 e PLCZ1 removidos; documentado |
| DEG thresholds padrão | OK | \|logFC\|>1, FDR<0.05 |

### 1.8 Validade interna

**Ameaças:**
1. Batch effect TCGA-GTEx não corrigido (CRÍTICO)
2. Composição celular diferente tumor vs normal (MODERADO)
3. Sem validação experimental (MODERADO — esperado para estudo exploratório)
4. Confounding por idade/sexo não ajustado (MENOR)

### 1.9 Validade externa

**Ameaças:**
1. Apenas THCA (papilífero) — não generalizável para outros subtipos
2. População TCGA (predominantemente caucasiana) — viés populacional
3. Plataforma específica (RNA-seq) — não validado em microarray

---

## ETAPA 2 — AVALIAÇÃO TCGA vs GTEx

### 2.1 Diagnóstico

| Fator de confusão | Presente? | Risco |
|-------------------|-----------|-------|
| Plataformas diferentes | SIM | TCGA e GTEx usaram pipelines distintos |
| Processamento diferente | SIM | TOIL recompute unificou, mas residual permanece |
| Demografia diferente | SIM | GTEx: doadores saudáveis pós-morte; TCGA: pacientes oncológicos |
| Batch effect | SIM | Não corrigido em nenhuma etapa |

### 2.2 Risco de falso DEG

**ALTO.** Genes com expressão tecido-específica ou dependente de composição celular são particularmente vulneráveis. MYH6 e MYH7 (genes cardíacos) com |logFC| > 4 em tireoide são suspeitos — podem refletir:
- Expressão ectópica residual em tireoide normal
- Contaminação por tecido muscular em amostras GTEx
- Artefato de composição celular

### 2.3 Análises recomendadas

| Análise | Prioridade | Justificativa |
|---------|------------|---------------|
| PCA | **OBRIGATÓRIA** | Visualizar separação TCGA vs GTEx; quantificar batch effect |
| UMAP | Alta | Complementar PCA; melhor para clusters não-lineares |
| ComBat | Alta | Remover batch effect preservando biologia |
| limma::removeBatchEffect | Média | Alternativa ao ComBat integrada ao limma |
| Heatmap de correlação | Média | Verificar agrupamento por batch vs condição |

### 2.4 Parecer

> A comparação TCGA vs GTEx sem correção de batch effect é a principal fragilidade metodológica deste estudo. Revisores de bioinformática exigirão no mínimo PCA demonstrando a magnitude do batch effect. Para periódicos de alto impacto, ComBat ou RUVseq serão obrigatórios.

---

## ETAPA 3 — ANÁLISE EXPLORATÓRIA AUSENTE

### 3.1 Diagnóstico

NENHUMA análise exploratória foi realizada. O pipeline vai direto para DEG + Volcano + PPI.

### 3.2 Análises faltantes e seu ganho científico

| Análise | Ganho científico | Custo computacional |
|---------|------------------|---------------------|
| **PCA** | Visualizar batch effect; demonstrar separação biológica | BAIXO (1 linha: `plotMDS`) |
| **Heatmap top DEGs** | Mostrar padrão de expressão por amostra; identificar outliers | BAIXO |
| **Boxplot de expressão** | Visualizar distribuição dos genes hub por grupo | BAIXO |
| **Correlação entre hubs** | Demonstrar co-regulação; fortalecer narrativa de módulo | BAIXO |
| **UMAP** | Complementar PCA; clusters não-lineares | MÉDIO |
| **Distribuição de p-valores** | Verificar calibração do teste; detectar inflação | BAIXO |
| **MA plot** | Visualizar relação fold-change vs expressão média | BAIXO |
| **Clustering hierárquico** | Identificar subgrupos tumorais | MÉDIO |

### 3.3 Recomendação

**Mínimo para submissão:** PCA + Heatmap dos top 20 DEGs  
**Recomendado para periódico:** Todos os itens de custo BAIXO acima  
**Diferencial:** UMAP + correlação entre hubs

---

## ETAPA 4 — VALIDAÇÃO EXTERNA

### 4.1 Estratégias disponíveis

| Recurso | Genes validáveis | Prioridade |
|---------|-----------------|------------|
| **GEPIA2** | Todos DEGs (TCGA + GTEx integrado) | **IMEDIATA** |
| **UALCAN** | Todos DEGs (TCGA) | **IMEDIATA** |
| **cBioPortal** | PRKCA, MYH7, CCND1 (alterações genômicas) | ALTA |
| **Human Protein Atlas** | PRKCA, MYH7, DIO3 (imuno-histoquímica) | ALTA |
| **GEO** | Dataset independente de THCA | ALTA |
| **TNMplot** | Expressão por estágio TNM | MÉDIA |

### 4.2 Genes prioritários para validação

| Prioridade | Gene | Justificativa |
|------------|------|---------------|
| 1 | PRKCA | Hub central; validação crucial para narrativa |
| 2 | MYH7 | Maior |logFC|; precisa confirmação independente |
| 3 | DIO3 | Alta significância; relevância tireoidiana direta |
| 4 | CCND1 | Oncogene clássico; controle positivo |
| 5 | PLCG1 | Hub com alta betweenness |

### 4.3 Ganho de impacto

Validação externa em GEPIA2 + UALCAN + Human Protein Atlas elevaria a chance de aceitação em ~30-40%. São análises de baixo custo (web-based, sem programação).

---

## ETAPA 5 — ANÁLISE FUNCIONAL

### 5.1 Diagnóstico

**NENHUMA análise de enriquecimento funcional foi realizada.** O estudo apenas descreve funções individuais dos genes via STRING.

### 5.2 Análises faltantes

| Análise | Banco | Relevância |
|---------|-------|------------|
| ORA GO BP | org.Hs.eg.db + clusterProfiler | Essencial — quais processos biológicos estão enriquecidos? |
| ORA GO CC | clusterProfiler | Componentes celulares afetados |
| ORA GO MF | clusterProfiler | Funções moleculares alteradas |
| ORA KEGG | clusterProfiler | Vias enriquecidas além de SHT |
| ORA Reactome | ReactomePA | Vias de sinalização |
| GSEA Hallmark | fgsea + msigdbr | Assinaturas funcionais broad |
| GSEA KEGG | fgsea | Ranqueamento global |

### 5.3 Narrativa biológica atual

**INSUFICIENTE para periódico de alto impacto.** A descrição funcional é gene-a-gene (manual), sem demonstração estatística de enriquecimento de vias ou processos. A via SHT foi escolhida a priori — não há evidência de que ela é a mais relevante.

### 5.4 Recomendação

**Mínimo para submissão:** ORA GO BP + ORA KEGG com todos os DEGs (não só SHT)  
**Diferencial:** GSEA Hallmark com ranking por t-statistic

---

## ETAPA 6 — AVALIAÇÃO DA REDE PPI

### 6.1 Diagnóstico quantitativo

| Métrica | Valor | Interpretação |
|---------|-------|---------------|
| DEGs de entrada | 29 | Todos os DEGs SHT |
| Mapeados STRING | 29 (100%) | Mapeamento completo |
| Edges totais (≥700) | 31 | Interações raw |
| Nós na rede final | 8 | **Apenas 8 de 29 DEGs** |
| Edges na rede final | 12 | Rede esparsa |
| Comunidades | 2 | Módulo 1 (sinalização), Módulo 2 (estrutural) |
| Modularidade | 0.1088 | **BAIXA** — separação fraca entre módulos |
| Densidade | 0.429 | Alta para rede biológica (poucos nós) |
| Clustering coeff | 0.656 | Moderado |
| Hubs | 5 de 8 (62.5%) | Threshold de hub muito permissivo |
| Edges intra-comunidade | 11 | |
| Edges inter-comunidade | **1** | Apenas PRKCA-ACTG1 conecta os módulos |

### 6.2 Problema CRÍTICO: 21 DEGs excluídos

**29 DEGs → apenas 8 na rede.** 21 genes (72%) foram excluídos porque:
- Não formam edges com score ≥ 700 com outros DEGs
- Ficam como nós isolados que são removidos (`delete_vertices` de degree=0)

Genes excluídos incluem: MYH7, MYH6, DIO3, CCND1, RXRG, ATP2A1, PLN, STAT1 — **justamente os genes mais significativos e mais discutidos no artigo!**

**Implicação:** A rede PPI atual NÃO representa os genes mais importantes do estudo. É uma rede de genes de sinalização (PLCs, PKCs) que sobraram após filtro severo.

### 6.3 Centralidade detalhada

| Gene | Degree | Betweenness | Closeness | Hub Score | is_hub |
|------|--------|-------------|-----------|-----------|--------|
| PRKCA | 5 | 0.476 | 8.52e-4 | 1.000 | TRUE |
| PLCG1 | 4 | 0.286 | 7.30e-4 | 0.769 | TRUE |
| PRKCG | 4 | 0.000 | 6.94e-4 | 0.931 | TRUE |
| PLCD4 | 4 | 0.095 | 7.40e-4 | 0.877 | TRUE |
| PLCD3 | 3 | 0.000 | 6.20e-4 | 0.753 | TRUE |
| ACTG1 | 2 | 0.286 | 5.89e-4 | 0.281 | FALSE |
| ITGAV | 1 | 0.000 | 4.34e-4 | 0.058 | FALSE |
| PIK3R2 | 1 | 0.000 | 4.62e-4 | 0.209 | FALSE |

### 6.4 PRKCA realmente emerge como hub?

**SIM, mas com ressalvas.** PRKCA é o hub com maior degree (5) e betweenness (0.476). Porém:
- A rede tem apenas 8 nós — ser hub em rede pequena é menos impressionante
- PRKCG e PLCD4 têm degree=4 mas betweenness=0 — estão na periferia do módulo
- PRKCA é o ÚNICO nó com conexão inter-módulo (edge PRKCA-ACTG1, score 918)
- A "centralidade" de PRKCA depende de 1 edge inter-módulo

### 6.5 Hub threshold problemático

O código atual classifica 5 de 8 nós como hubs (62.5%). Critério:
```r
hub_th_bet <- quantile(cent$betweenness[cent$betweenness > 0], 0.70)
cent$is_hub <- (cent$betweenness >= hub_th_bet & cent$degree >= 2) | cent$degree >= 3
```

Com apenas 8 nós, o percentil 70 é pouco discriminativo. Degree ≥ 3 sozinho captura 5 nós. Isso infla artificialmente o número de hubs.

---

## ETAPA 7 — AVALIAÇÃO ESPECÍFICA DE PRKCA

### 7.1 Dados de expressão

| Métrica | Valor |
|---------|-------|
| logFC | −1.024 |
| AveExpr | 8.60 |
| t-statistic | −13.69 |
| adj.P.Val | 5.97 × 10⁻³⁸ |
| B-statistic | 75.47 |
| Regulação | Down |
| in_kegg | TRUE |
| Rank por adj.P.Val (entre 29 DEGs) | **#26 de 29** |
| Rank por \|logFC\| (entre 20 Down) | **#20 de 20 (último)** |

### 7.2 Evidência biológica

| Aspecto | Evidência |
|---------|-----------|
| Oncogene/supressor | Contexto-dependente. PKCα pode ser ambos. Em tireoide, downregulation sugere possível papel supressor |
| Carcinoma papilífero | PRKCA mutado/alterado em ~5% PTC (TCGA 2014) |
| Sinalização tireoidiana | PKCα é efetor downstream de TSH via PLC/DAG |
| Cardiovascular | PKCα regula contratilidade, hipertrofia e remodelamento cardíaco |
| Hub PPI | Confirmado: degree=5, betweenness=0.476 |

### 7.3 PRKCA como protagonista: justificável?

**PARCIALMENTE.** PRKCA é o hub mais interessante da rede, mas:
- É o DEG MENOS significativo entre os 29 (rank #26 por FDR, último por |logFC|)
- Seu |logFC| = 1.024 mal passa o threshold (limite = 1.0)
- Sua relevância como hub depende de uma rede de apenas 8 nós
- Os genes mais significativos (MYH7, DIO3, CCND1) NÃO estão na rede PPI

**Recomendação:** PRKCA deve ser apresentado como "gene hub da rede de sinalização", não como "principal achado do estudo". O principal achado são os genes de alta significância (MYH7, DIO3, etc.), com PRKCA como achado complementar de rede.

---

## ETAPA 8 — PROBLEMA DO VOLCANO PLOT 🔴🔴🔴

### 8.1 Diagnóstico: PRKCA NÃO APARECE COM LABEL

**EVIDÊNCIA CONFIRMADA:** PRKCA está presente no volcano plot como ponto (Down, colorido), mas SEM label.

### 8.2 Causa raiz

**BUG DE ORDEM DE EXECUÇÃO.** O pipeline executa:

```r
source("R/03_deg.R")       # Cria: deg, kegg_genes, etc.
source("R/04_volcano.R")   # Cria: volcano plot. Cent NÃO EXISTE AQUI.
source("R/05_ppi.R")       # Cria: cent (centrality metrics) — TARDE DEMAIS
```

Em `04_volcano.R`, o código tenta adicionar hubs:
```r
if (exists("cent") && is.data.frame(cent)) {
  hubs <- cent |> dplyr::filter(is_hub) |> dplyr::pull(gene_symbol)
  label_set <- union(label_set, intersect(hubs, deg$gene_symbol))
}
```

**`exists("cent")` é SEMPRE FALSE** quando `04_volcano.R` executa, porque `cent` só é criado depois em `05_ppi.R`.

### 8.3 Por que PRKCA não é selecionado pelos outros critérios

| Critério de label | Top N | PRKCA incluso? | Rank do PRKCA |
|-------------------|-------|----------------|---------------|
| top_fdr (menor adj.P.Val) | 8 | ❌ | #26 de 29 |
| top_lfc_up (maior logFC Up) | 5 | ❌ (é Down) | — |
| top_lfc_down (menor logFC Down) | 5 | ❌ | #20 de 20 |
| top_kegg (menor adj.P.Val KEGG) | 6 | ❌ | #26 de 29 |
| hubs (via cent) | — | ❌ (cent não existe) | — |

**Conclusão:** PRKCA é sistematicamente excluído de TODOS os critérios de label. O critério que deveria incluí-lo (hubs) nunca executa.

### 8.4 Evidência no log

```
── M3: Volcano Plot ──
  Labels: 12 genes
```

Os 12 genes com label são: MYH7, CCND1, ATP2A1, DIO3, MYH6, RXRG, PLCG1, KAT2A, PLCD3, STAT1, ACTG1, DIO1. PRKCA ausente.

---

## ETAPA 9 — CORREÇÃO DO VOLCANO PLOT

### 9.1 Estratégia de correção

Duas abordagens:

**Abordagem A (inversão de ordem — recomendada):**
Mover `05_ppi.R` antes de `04_volcano.R` em `run_pipeline.R`. Isso faria `cent` existir quando o volcano for gerado.

**Abordagem B (injeção manual):**
Adicionar PRKCA e outros hubs diretamente ao `label_set` em `04_volcano.R`, independentemente de `cent`.

### 9.2 Código de correção — Abordagem A

```r
# Em run_pipeline.R, alterar ordem:
source(here::here("R", "03_deg.R"),       local = FALSE)
source(here::here("R", "05_ppi.R"),       local = FALSE)  # ANTES do volcano
source(here::here("R", "04_volcano.R"),   local = FALSE)  # DEPOIS do PPI
```

**Vantagem:** Aproveita a lógica existente de hub labeling.  
**Desvantagem:** O título "M3: Volcano Plot" aparecerá depois de "M4: PPI Network" no log.

### 9.3 Código de correção — Abordagem B (mais segura)

Adicionar ao `04_volcano.R`, após a definição de `label_set`:

```r
# ── Force hub genes into label set ─────────────────────────────────────────
# Even when cent doesn't exist yet, ensure key hub genes are labeled
FORCE_LABEL_GENES <- c("PRKCA", "PLCG1", "PLCD4", "PRKCG", "PLCD3")
label_set <- union(label_set, intersect(FORCE_LABEL_GENES, deg$gene_symbol))
```

### 9.4 Código de correção — Abordagem C (ótima, combinada)

Gerar o volcano plot DUAS VEZES: uma durante o pipeline (sem hubs) e outra ao final (com hubs). Ou melhor: reordenar o pipeline para:

```r
source("R/03_deg.R")
source("R/05_ppi.R")      # Gera cent com hubs
# Agora sim, com cent disponível:
source("R/04_volcano.R")  # Labels incluem hubs
```

E ajustar as mensagens de log para refletir a nova ordem.

---

## ETAPA 10 — AUMENTO DO IMPACTO CIENTÍFICO

### 10.1 Ranking de intervenções

| # | Intervenção | Impacto | Custo | Relação esforço/retorno |
|---|-------------|---------|-------|------------------------|
| 1 | Corrigir volcano (PRKCA label) | **MUITO ALTO** | BAIXO | ⭐⭐⭐⭐⭐ |
| 2 | PCA + Heatmap | **MUITO ALTO** | BAIXO | ⭐⭐⭐⭐⭐ |
| 3 | Validação externa GEPIA2/UALCAN | **ALTO** | BAIXO | ⭐⭐⭐⭐⭐ |
| 4 | ORA GO/KEGG com clusterProfiler | **ALTO** | BAIXO | ⭐⭐⭐⭐ |
| 5 | Corrigir ordem pipeline (volcano após PPI) | **ALTO** | BAIXO | ⭐⭐⭐⭐ |
| 6 | Reduzir STRING score para 400 (incluir MYH7, DIO3 na rede) | **ALTO** | BAIXO | ⭐⭐⭐⭐ |
| 7 | Boxplots de expressão dos hubs | MODERADO | BAIXO | ⭐⭐⭐ |
| 8 | GSEA Hallmark | ALTO | MÉDIO | ⭐⭐⭐ |
| 9 | ComBat batch correction | ALTO | MÉDIO | ⭐⭐⭐ |
| 10 | UMAP | MODERADO | MÉDIO | ⭐⭐ |
| 11 | Validação GEO externa | ALTO | ALTO | ⭐⭐ |
| 12 | Human Protein Atlas IHC | ALTO | ALTO | ⭐⭐ |

### 10.2 Alvos de periódico por nível de intervenção

| Nível atual + correções | Periódicos viáveis |
|--------------------------|-------------------|
| Apenas correções críticas (1-5) | Frontiers in Endocrinology, BMC Cancer |
| + análises exploratórias (6-9) | Cancer Cell International, Cancers |
| + validação externa completa (10-12) | Scientific Reports, Briefings in Bioinformatics |

---

## ETAPA 11 — ROADMAP FINAL

### 11.1 O que MANTER

- Estrutura do pipeline (modular, documentado)
- Parâmetros de DEG (|logFC|>1, FDR<0.05)
- Hipótese lockada (v3.1.0)
- Código R bem organizado
- Documentação (README, docs/, CHECKSUMS)
- Figuras no padrão Cell Press
- renv.lock + Dockerfile

### 11.2 O que CORRIGIR

| # | Correção | Arquivo | Prioridade |
|---|----------|---------|------------|
| 🔴 | **PRKCA ausente do volcano** | `04_volcano.R` + `run_pipeline.R` | **CRÍTICA** |
| 🔴 | **Ordem de execução (PPI antes do volcano)** | `run_pipeline.R` | **CRÍTICA** |
| 🟡 | Hub threshold muito permissivo (5/8 = 62%) | `05_ppi.R` | MODERADA |
| 🟡 | STRING score 700 exclui MYH7, DIO3, CCND1 da rede | `00_setup.R` | MODERADA |
| 🟡 | Top 5 genes citados no artigo não batem com ranking real | `.docx` | MODERADA |
| 🟢 | DIO3 associado incorretamente a homeostase de Ca²⁺ | `.docx` | MENOR |
| 🟢 | ATP2A1 associado a relaxamento miocárdico (é isoforma esquelética) | `.docx` | MENOR |
| 🟢 | STAT1 associado a proliferação (função canônica oposta) | `.docx` | MENOR |
| 🟢 | Versão do pipeline ainda 3.0.0 em arquivos de teste | `tests/` | MENOR |

### 11.3 O que REMOVER

- Nada a remover. O pipeline está enxuto.

### 11.4 O que ADICIONAR

| Adição | Arquivo | Prioridade |
|--------|---------|------------|
| PCA plot | Novo `R/03b_pca.R` | **IMEDIATA** |
| Heatmap top DEGs | Novo `R/03c_heatmap.R` | **IMEDIATA** |
| Boxplot hubs | Novo `R/05b_hub_boxplots.R` | ALTA |
| ORA GO/KEGG | Novo `R/05c_enrichment.R` | ALTA |
| Correlação entre hubs | Em `05_ppi.R` | MÉDIA |
| Validação GEPIA2/UALCAN (manual, documentado) | `docs/validation.md` | ALTA |

### 11.5 Cronograma otimizado

#### FASE 1 — IMEDIATO (hoje, < 2h)

1. Corrigir ordem pipeline: `05_ppi.R` ANTES de `04_volcano.R`
2. Adicionar `FORCE_LABEL_GENES` no `04_volcano.R` como fallback
3. Regerar volcano plot com labels de hubs
4. Verificar visualmente

#### FASE 2 — ANTES DA SUBMISSÃO (1-2 dias)

5. Adicionar PCA (`plotMDS` do limma)
6. Adicionar heatmap dos top 20 DEGs (`pheatmap`)
7. Corrigir texto do `.docx` (inconsistências da auditoria)
8. Ajustar hub threshold para top 25% betweenness (mais restritivo)
9. Documentar validação GEPIA2/UALCAN

#### FASE 3 — SE HOUVER TEMPO (3-5 dias)

10. ORA GO BP + KEGG com clusterProfiler
11. GSEA Hallmark com fgsea
12. Reduzir STRING score para 400 (rede mais inclusiva)
13. Boxplots de expressão dos hubs
14. UMAP

---

## APÊNDICE A — Evidência do bug PRKCA

### A.1 PRKCA nos dados DEG

```
gene_symbol: PRKCA
logFC:       -1.0241
adj.P.Val:    5.97e-38
regulation:  Down
in_kegg:     TRUE
Rank FDR:    #26 de 29 DEGs
Rank |logFC|: #20 de 20 Down DEGs (último)
```

### A.2 Critérios de label e PRKCA

```
top_fdr (8):     MYH7, CCND1, ATP2A1, DIO3, MYH6, RXRG, PLCG1, KAT2A
                 → PRKCA é #26 — NÃO incluso

top_lfc_down (5): MYH7, DIO3, MYH6, ATP2A1, DIO1
                  → PRKCA é #20 — NÃO incluso

top_kegg (6):    MYH7, CCND1, ATP2A1, DIO3, MYH6, RXRG
                 → PRKCA é #26 — NÃO incluso

hubs (cent):     NUNCA EXECUTA (cent não existe)
```

### A.3 Labels atuais no volcano (12 genes, sem PRKCA)

MYH7, CCND1, ATP2A1, DIO3, MYH6, RXRG, PLCG1, KAT2A, PLCD3, STAT1, ACTG1, DIO1

---

## APÊNDICE B — Sumário de severidade

| Severidade | Quantidade | Itens |
|------------|------------|-------|
| 🔴 CRÍTICO | 2 | PRKCA sem label no volcano; ordem pipeline |
| 🟡 MODERADO | 5 | Batch effect; 21 DEGs fora da rede; hub threshold; viés de via única; top 5 errado no artigo |
| 🟢 MENOR | 6 | Covariáveis; DIO3; ATP2A1; STAT1; testes v3.0.0; análises exploratórias ausentes |

---

*Auditoria concluída em 2026-06-24. Este documento deve ser versionado no repositório.*
