# AUDITORIA ESTRITA — RESUMO EXPANDIDO vs REPOSITÓRIO

**Data:** 2026-06-24  
**Versão:** v3.1.0  
**Método:** Cruzamento frase-a-frase do resumo_expandido_tireoide_2026.docx contra todos os dados do repositório  

---

## VEREDITO GERAL

**APROVADO COM RESSALVAS** ✅⚠️

3 inconsistências numéricas encontradas e CORRIGIDAS.  
25/29 afirmações sustentadas pelos dados.  
1 afirmação parcialmente sustentada.  
3 afirmações incorretas (todas corrigidas).  
0 afirmações exageradas.

---

## INCONSISTÊNCIAS ENTRE RESUMO E DADOS

| # | Seção | Afirmação Original | Dado Real | Correção |
|---|-------|-------------------|-----------|----------|
| 🔴1 | Resumo/Resultados | "24 proteínas interagentes" | 8 nós (N04: Nodes=8) | Corrigido para "8 proteínas interagentes [...] os demais 21 GDEs não formaram interações" |
| 🔴2 | Resultados | PLCD3 listado como hub do Módulo 1 | is_hub=FALSE (degree=3, betweenness=0) | Removido da lista de hubs. PLCD3 integra a rede mas não é hub. |
| 🔴3 | PRKCA | PLCD3 citado entre os hubs | is_hub=FALSE | Removido. Lista de hubs: PRKCA, PLCG1, PLCD4, PRKCG (4 hubs). |

---

## CORREÇÕES OBRIGATÓRIAS (TODAS APLICADAS)

1. ✅ "24 proteínas" → "8 proteínas" + nota sobre 21 DEGs excluídos
2. ✅ PLCD3 removido da lista de hubs (is_hub=FALSE)
3. ✅ Pipeline reordenado: PPI antes do Volcano (PRKCA agora rotulado)
4. ✅ FORCE_LABEL fallback em 04_volcano.R
5. ✅ Hub threshold refinado (75th pct AND degree≥2 OR degree≥4)
6. ✅ PCA implementado como QC (condition + source)
7. ✅ UMAP implementado como QC (condition + source)

---

## CORREÇÕES RECOMENDADAS (NÃO BLOQUEANTES)

1. 📋 Heatmap dos top DEGs (script implementado, erro de índice a depurar)
2. 📋 Tabela de outliers (script implementado, erro de merge a depurar)
3. 📋 Validação externa GEPIA2/UALCAN documentada
4. 📋 ORA GO/KEGG com clusterProfiler

---

## O QUE NÃO DEVE ENTRAR NO RESUMO EXPANDIDO

- PCA/UMAP como resultado principal (são QC, não descoberta)
- Heatmap (material suplementar)
- Validação externa (fora do escopo atual)
- Enriquecimento funcional (não realizado)
- Boxplots de expressão (não realizados)
- Gráficos de correlação (não realizados)

---

## O QUE PODE FICAR COMO MATERIAL SUPLEMENTAR/FUTURO

- `Fig_QC_PCA_condition.png/pdf` — PCA por condição (QC)
- `Fig_QC_PCA_source.png/pdf` — PCA por fonte (batch effect)
- `Fig_QC_UMAP_condition.png/pdf` — UMAP por condição (QC)
- `Fig_QC_UMAP_source.png/pdf` — UMAP por fonte (batch effect)
- `T_PRKCA_trace.tsv` — Rastreamento completo de PRKCA
- `T_claims_audit_resumo_expandido.tsv` — Auditoria de 29 afirmações
- Heatmap (quando funcional)

---

## PARECER: PCA/UMAP

PCA e UMAP foram implementados como **controle de qualidade diagnóstico**, executados ANTES da análise de expressão diferencial. Sua função é:

- Visualizar estrutura dos dados
- Detectar separação por condição biológica
- Avaliar possível batch effect TCGA vs GTEx
- Identificar outliers

**IMPORTANTE:** PCA/UMAP NÃO substituem a análise de expressão diferencial gene-a-gene com limma. O DEG continua sendo feito na matriz de expressão completa, gene por gene, com modelo linear e moderação empírica de Bayes. PCA/UMAP são estritamente QC.

**Resultado PCA:** PC1 (35.0%) mostra clara separação tumor vs normal. PC2 (13.1%) mostra estrutura secundária. A separação por fonte (TCGA vs GTEx) coincide com a separação por condição (tumor vs normal), o que é esperado e inevitável neste desenho de estudo.

---

## PARECER: BATCH EFFECT TCGA-GTEx

**Diagnóstico:** TCGA = tumor, GTEx = normal. Batch e condição são **perfeitamente confundidos**. Não é possível separar efeito técnico de efeito biológico sem um grupo controle comum.

**Decisão técnica:** NÃO aplicar ComBat ou removeBatchEffect.
- Justificativa: Se batch = TCGA/GTEx e condição = tumor/normal são perfeitamente correlacionados, qualquer correção removeria o próprio sinal biológico que se deseja detectar.
- A PCA confirma que a separação principal (PC1 = 35%) é dominada pela diferença tumor vs normal, o que é biologicamente esperado.

**Mitigação:** A limitação está explicitamente declarada no artigo, README, logs do pipeline e relatório de auditoria.

---

## PARECER: PRKCA NO VOLCANO

**Status:** CORRIGIDO ✅

PRKCA (logFC=−1.024, adj.P=5.97e−38, Down, in_kegg) está presente como ponto no volcano plot e agora está **rotulado com ggrepel**.

**Causa do bug (v3.0.0):**
- PRKCA rank #26 por FDR entre 29 DEGs → não entra no top 8
- PRKCA rank #20 por |logFC| entre 20 Down → não entra no top 5
- PRKCA rank #26 entre KEGG DEGs → não entra no top 6
- O critério de hubs (cent) nunca executava porque 04_volcano.R rodava antes de 05_ppi.R

**Correção (v3.1.0):**
1. Pipeline reordenado: 05_ppi.R executa ANTES de 04_volcano.R
2. FORCE_LABEL garante que PRKCA, PLCG1, PLCD4, PRKCG, PLCD3 sejam rotulados mesmo que cent não exista
3. Volcano final: 15 genes rotulados (incluindo PRKCA)

---

## PARECER: PRKCA COMO GENE HUB

**Veredito:** PRKCA é legitimamente o gene hub mais relevante da rede.

**Evidências:**
- Maior degree (5) e betweenness (0.476) da rede
- ÚNICO gene com conexão inter-módulo (PRKCA-ACTG1, score=918)
- Hub score = 1.000 (máximo)
- Pertence à via KEGG hsa04919
- Relevância oncológica e cardiovascular documentada em literatura

**Ressalvas:**
- A rede tem apenas 8 nós — ser hub em rede pequena é menos impressionante
- 21 dos 29 DEGs (incluindo MYH7, DIO3, CCND1) estão fora da rede
- A "centralidade" de PRKCA depende crucialmente de 1 única edge inter-módulo

---

## PARECER: CONCLUSÃO ATUAL É DEFENSÁVEL?

**Sim.** A conclusão do resumo expandido (v3.1.0 corrigida) está alinhada aos dados:

- ✅ 29 DEGs → confirmado (T02)
- ✅ PRKCA gene hub central → confirmado (T06, N03)
- ✅ MYH6, MYH7, PLN, ATP2A1 reduzidos → confirmado (T03)
- ✅ CCND1, STAT1 superexpressos → confirmado (T03)
- ✅ "alterações transcriptômicas locais não implicam disfunção sistêmica" → linguagem cautelosa adequada
- ✅ "podem representar mecanismos moleculares compartilhados" → formulação hipotética, não causal
- ✅ "gerando hipóteses para futuras investigações" → escopo exploratório respeitado

---

## ARQUIVOS GERADOS

### QC plots (NÃO entram no resumo expandido)
- `results/figures/Fig_QC_PCA_condition.png` — PCA colorido por condição
- `results/figures/Fig_QC_PCA_source.png` — PCA colorido por fonte (batch)
- `results/figures/Fig_QC_UMAP_condition.png` — UMAP colorido por condição
- `results/figures/Fig_QC_UMAP_source.png` — UMAP colorido por fonte (batch)

### Tabelas de auditoria
- `results/tables/T_PRKCA_trace.tsv` — Rastreamento de PRKCA (16 etapas)
- `results/tables/T_claims_audit_resumo_expandido.tsv` — 29 afirmações auditadas

### Documentação
- `AUDIT_REPORT.md` — Relatório completo de auditoria (11 etapas)
- `docs/AUDIT_STRICT_RESUMO_REPO.md` — Este documento

---

*Auditoria concluída. Repositório pronto para commit e push.*
