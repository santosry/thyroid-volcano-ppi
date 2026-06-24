# thyroid-volcano-ppi

**Análise de Expressão Diferencial e Rede de Interação Proteína-Proteína no Carcinoma de Tireoide (THCA)**

[![R >= 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![renv](https://img.shields.io/badge/renv-locked-blueviolet)](renv.lock)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](Dockerfile)
[![Audit](https://img.shields.io/badge/Audit-Passed-success)](AUDIT_REPORT.md)

---

> **Hipótese científica "lockada":** O carcinoma de tireoide apresenta alterações transcriptômicas na via de sinalização dos hormônios tireoidianos que envolvem genes com funções reconhecidas na biologia cardiovascular. Essas alterações podem representar mecanismos moleculares compartilhados entre a progressão tumoral e processos cardiovasculares, gerando hipóteses para futuras investigações translacionais em saúde de precisão.

---

## Sobre este projeto

Este estudo realiza análise de expressão diferencial (DEG) e rede de interação proteína-proteína (PPI) no carcinoma papilífero de tireoide (THCA), utilizando dados públicos do TCGA e GTEx (783 amostras: 504 tumorais, 279 normais).

O foco é a via de sinalização dos hormônios tireoidianos (KEGG hsa04919, 119 genes analisados), com ênfase em:

1. **Volcano Plot** — identificação de genes diferencialmente expressos
2. **Rede PPI** — interações proteína-proteína, módulos funcionais e genes hub

### O que este estudo NÃO faz

| Limitação | Detalhamento |
|-----------|-------------|
| Não estabelece causalidade | Associação transcriptômica ≠ relação causal |
| Não valida experimentalmente | Sem PCR, Western blot ou ensaios funcionais |
| Não analisa tecido cardíaco | Inferências cardiovasculares são hipotéticas |
| Não corrige batch effects TCGA-GTEx | Comparação entre coortes distintas requer cautela |
| Não demonstra função sistêmica | Expressão tumoral ≠ função endócrina sistêmica |
| Hubs são exploratórios | Centralidade de rede ≠ alvo terapêutico validado |

---

## Resultados principais

| Figura | Descrição |
|--------|-----------|
| **Figura 1: Volcano Plot** | 29 genes diferencialmente expressos na via SHT (9↑, 20↓). MYH7, DIO3, MYH6 entre os mais suprimidos; CCND1 e RXRG entre os mais superexpressos |
| **Figura 2: Rede PPI** | 24 proteínas interagentes em 2 módulos funcionais. PRKCA como gene hub central (grau = 5, betweenness = 0,476) conectando os módulos |

### Principais achados

- **PRKCA** é o hub central, conectando módulos de sinalização intracelular (PLCG1, PLCD3, PLCD4, PRKCG) e organização estrutural (ACTG1, ITGAV)
- Genes com funções cardiovasculares conhecidas (MYH6, MYH7, PLN, ATP2A1) aparecem suprimidos no tumor — um achado que gera hipóteses, mas requer validação
- A rede PPI revela dois módulos funcionalmente coerentes, com PRKCA como elo topológico

### PRKCA: o achado mais robusto

PRKCA (Proteína Quinase C Alfa) destaca-se por:
1. Ser o gene hub com maior centralidade (betweenness = 0,476)
2. Conectar os dois módulos funcionais da rede
3. Possuir relevância oncológica e cardiovascular documentada
4. Apresentar plausibilidade biológica como mediador de sinalização

---

## Guia rápido para profissionais de saúde

### O que você precisa instalar

#### 1. Instalar R
- Acesse: **https://cran.r-project.org/**
- Clique em "Download R for Windows" (ou seu sistema)
- Clique em "base" e siga a instalação

#### 2. Instalar VS Code (recomendado) ou RStudio
- VS Code: **https://code.visualstudio.com/** + extensão "R"
- RStudio: **https://posit.co/download/rstudio-desktop/**

### Passo a passo para executar

#### ANTES de começar: baixe o repositório

**Opção A — Sem Git (mais fácil):**
1. No topo desta página, clique no botão verde **"<> Code"**
2. Clique em **"Download ZIP"**
3. Extraia o .zip para uma pasta (ex.: `C:\Users\SeuNome\Downloads\thyroid-volcano-ppi`)

**Opção B — Com Git:**
```bash
git clone https://github.com/santosry/thyroid-volcano-ppi.git
```

#### PASSO 1: Baixar o arquivo de dados (OBRIGATÓRIO)

**Opção 1 — Download automático (recomendado):**
```r
source("scripts/download_data.R")
```

**Opção 2 — Download manual:**
1. Acesse: **https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426**
2. Clique em "Download" (canto superior direito)
3. Selecione "Download current visualization data"
4. Salve como `XENA_THCA.tsv` na pasta `data/raw/`

> O arquivo DEVE estar em: `thyroid-volcano-ppi/data/raw/XENA_THCA.tsv`

#### PASSO 2: Instalar pacotes necessários
```r
install.packages("renv")
renv::restore()
```
Aguarde 5–15 minutos.

#### PASSO 3: Executar o pipeline
```r
source("run_pipeline.R")
```
Aguarde 3–5 minutos. Ao final, verá: **"PIPELINE COMPLETED SUCCESSFULLY"**

#### PASSO 4: Visualizar os resultados
Todos os resultados estão na pasta `results/`:
- **Figuras:** `results/figures/` (PNG 600 dpi + PDF vetorial)
- **Tabelas:** `results/tables/`
- **Metadados da rede:** `results/network/`

---

## Desenho do estudo

### Métodos

| Etapa | Método | Ferramenta |
|--------|--------|-----------|
| Expressão diferencial | Modelo linear + Bayes empírico | limma (Bioconductor) |
| Contraste | THCA vs Normal (GTEx) | makeContrasts |
| Correção de múltiplos testes | Benjamini-Hochberg (FDR) | topTable |
| Rede PPI | STRING REST API v12.0 | httr + jsonlite |
| Centralidade | Betweenness, degree, closeness, hub score | igraph |
| Comunidades | Walktrap | igraph |
| Visualização | Volcano Plot + Rede PPI | ggplot2 + ggrepel + ggraph |

### Fontes de dados

| Fonte | Descrição | Acesso |
|--------|-------------|--------|
| **TCGA THCA** | 504 amostras de carcinoma papilífero | UCSC Xena Browser |
| **GTEx Thyroid** | 279 amostras de tireoide normal | UCSC Xena Browser |
| **KEGG hsa04919** | Via de sinalização do hormônio tireoidiano | KEGG REST API |
| **STRING v12.0** | Interações proteína-proteína (≥ 700) | STRING REST API |

### Parâmetros de análise

| Parâmetro | Valor | Significado |
|-----------|-------|-------------|
| |log2FC| mínimo | 1.0 | Mínimo 2× de alteração |
| FDR máximo | 0.05 | Máximo 5% de falsos positivos (BH) |
| Filtro de expressão | >0.5 em ≥10% | Sinal detectável mínimo |
| Escore STRING mínimo | 700 | Alta confiança na interação |
| Via KEGG | hsa04919 | Sinalização do hormônio tireoidiano |
| Versão STRING | 12.0 | Última release |
| Seed | 42 | Reprodutibilidade garantida |

### Como interpretar os resultados

#### Figura 1: Volcano Plot

| Elemento | Significado |
|----------|-------------|
| **Eixo X** | log₂(fold change): direção e magnitude. **Positivo** = mais expresso no tumor. **Negativo** = menos expresso |
| **Eixo Y** | −log₁₀(valor-p ajustado): significância. **Mais alto** = resultado **mais confiável** |
| **Pontos azuis** | Genes **superexpressos** no tumor (9 genes) |
| **Pontos magenta** | Genes **subexpressos** no tumor (20 genes) |
| **Pontos cinza** | Genes sem diferença significativa (90 genes) |
| **Linhas tracejadas** | Limiares: |log₂FC| = 1 (vertical); FDR = 0,05 (horizontal) |
| **Anéis abertos** | Genes pertencentes à via KEGG hsa04919 |

**Resumo:** 29 genes da via SHT apresentaram diferença significativa (9↑, 20↓). Genes cardíacos (MYH6, MYH7) estão entre os mais suprimidos — observação que gera hipóteses para investigação futura.

#### Figura 2: Rede PPI

| Elemento | Significado |
|----------|-------------|
| **Cada círculo (nó)** | Proteína codificada por gene diferencialmente expresso |
| **Cores dos nós** | Módulos funcionais (walktrap): proteínas que atuam na mesma função |
| **Tamanho do nó** | Proporcional ao grau (número de interações). Maior = mais conectado |
| **Borda escura** | **Proteína hub** (alta centralidade). 5 hubs identificados |
| **Linhas entre nós** | Interação física entre proteínas conforme STRING (escore ≥ 700) |
| **Linhas cinza** | Interações dentro do mesmo módulo |
| **Linhas rosa claro** | Interações entre módulos diferentes |

**IMPORTANTE:** Hubs são identificados por métricas de centralidade de rede (betweenness, grau). **Não** representam alvos terapêuticos validados, **não** implicam causalidade e **não** substituem validação experimental.

---

## Limitações

1. **Batch effect TCGA/GTEx:** Amostras tumorais (TCGA) e normais (GTEx) provêm de fontes distintas com protocolos de sequenciamento diferentes. Nenhuma correção de batch effect foi aplicada. Diferenças observadas podem refletir parcialmente viés técnico.

2. **Associação ≠ causalidade:** Expressão diferencial indica associação estatística, não relação causal. DEGs podem ser consequência (não causa) do processo neoplásico.

3. **Rede PPI in silico:** Interações proteína-proteína são preditas/inferidas pelo STRING (evidência combinada: mineração de texto, experimentos, coexpressão etc.). Não há validação experimental direta.

4. **Hubs exploratórios:** Proteínas hub são definidas por métricas de centralidade de rede. Não devem ser interpretadas como alvos terapêuticos ou biomarcadores sem validação adicional.

5. **Inferência cardiovascular:** Genes com funções cardíacas conhecidas (MYH6, MYH7, PLN, ATP2A1) aparecem alterados no tecido tumoral tireoidiano. Isso **não** demonstra disfunção cardíaca nem eixo tireoide-coração.

6. **Generalização:** Resultados aplicam-se ao contexto específico de THCA com dados TCGA/GTEx. Extrapolação para outros subtipos histológicos requer cautela.

7. **Dependência de APIs externas:** O pipeline requer internet para STRING e KEGG. Alterações nessas APIs podem afetar a reprodutibilidade futura.

8. **Composição celular:** Alterações na expressão gênica podem refletir diferenças na composição celular entre tecido tumoral e normal, e não necessariamente regulação transcricional.

---

## Estrutura do pipeline

```
thyroid-volcano-ppi/
├── run_pipeline.R              Script principal
├── R/
│   ├── 00_setup.R              Parâmetros, pacotes, cores, verificação de internet
│   ├── 01_functions.R          Funções core (KEGG, STRING, exportação)
│   ├── 02_import.R             Importação e validação de dados
│   ├── 03_deg.R                Expressão diferencial (limma + Bayes empírico)
│   ├── 04_volcano.R            Figura 1: Volcano Plot (PNG + PDF)
│   ├── 05_ppi.R                Figura 2: Rede PPI (PNG + PDF)
│   └── 06_supplementary.R      Tabelas suplementares S1–S4
├── data/
│   ├── raw/                    Coloque XENA_THCA.tsv aqui
│   ├── processed/              Dados intermediários
│   └── string_cache/           Cache STRING
├── scripts/
│   ├── download_data.R         Download automático de dados
│   ├── setup_renv.R            Inicialização do renv
│   └── audit_docx_fixes.py     Script de auditoria do documento
├── results/
│   ├── figures/                PNGs 600 dpi + PDFs vetoriais
│   ├── tables/                 Tabelas TSV (7 principais + 4 suplementares)
│   └── network/                Metadados da rede PPI
├── tests/
│   ├── testthat.R              Executor de testes
│   └── testthat/               Testes unitários
├── docs/                       Documentação suplementar
├── logs/                       Logs de execução + sessionInfo()
├── Dockerfile                  Container Docker reprodutível
├── renv.lock                   Versões exatas dos pacotes R
├── AUDIT_REPORT.md             Relatório de auditoria científica
├── LICENSE                     MIT
└── CITATION.cff                Metadados de citação
```

---

## Reproduzindo a análise

```bash
# 1. Clonar repositório
git clone https://github.com/santosry/thyroid-volcano-ppi.git
cd thyroid-volcano-ppi

# 2. Baixar dados (automático ou manual)
Rscript scripts/download_data.R

# 3. Restaurar ambiente R (recomendado)
R -e 'install.packages("renv"); renv::restore()'

# 4. Executar pipeline
Rscript run_pipeline.R

# 5. Executar testes (opcional)
R -e 'testthat::test_dir("tests/testthat")'
```

**Tempo estimado:** 3–5 minutos com internet.

---

## Outputs

### Tabelas principais (`results/tables/`)

| Arquivo | Conteúdo |
|---------|---------|
| `T01_sample_composition.tsv` | Composição das amostras (Normal vs THCA) |
| `T02_deg_summary.tsv` | Resumo da análise: genes testados, DEGs, limiares |
| `T03_deg_full_results.tsv` | Resultados completos: log2FC, p-valor, p-ajustado, classificação |
| `T04_top20_degs.tsv` | Top 20 genes com maiores diferenças |
| `T05_kegg_missing_genes.tsv` | Genes da via KEGG não detectados |
| `T06_hub_proteins.tsv` | Proteínas hub com métricas de centralidade |
| `T07_kegg_degs_ppi.tsv` | Tabela integrada: DEGs KEGG + métricas PPI |

### Metadados da rede (`results/network/`)

| Arquivo | Conteúdo |
|---------|---------|
| `N01_string_mapping.tsv` | Mapeamento gene → STRING ID |
| `N02_string_interactions.tsv` | Interações PPI utilizadas |
| `N03_centrality_metrics.tsv` | Métricas completas de centralidade |
| `N04_network_summary.tsv` | Estatísticas globais da rede |

### Especificações das figuras

Ambas as figuras seguem o padrão editorial **Nature Communications / Cell Press**:

| Propriedade | Especificação |
|-------------|---------------|
| Formato | PNG 600 dpi + PDF vetorial |
| Volcano Plot | 180 × 150 mm |
| Rede PPI | 180 × 180 mm |
| Tipografia | Sans-serif (Arial/Helvetica), 14pt |
| Fundo | Branco, eixos abertos |
| Cores | Azul `#4477AA` (Superexpresso), Magenta `#AA4488` (Subexpresso) |
| Labels | ggrepel com linhas guia |
| Rede PPI | Layout Fruchterman-Reingold, comunidades walktrap |

---

## FAQ

### "Erro: arquivo XENA_THCA.tsv não encontrado"
**Solução:** Volte ao PASSO 1 e baixe o arquivo de dados.

### "Falha no download automático"
**Solução:** Use o download manual (Opção 2 no PASSO 1).

### "Erro de conexão durante a análise"
**Solução:** O script verifica conectividade ao iniciar. STRING e KEGG requerem internet.

### "Quanto tempo leva?"
Cerca de **3 a 5 minutos** com boa conexão. Primeira execução adiciona 10–15 min para instalação.

### "O que é 'log2 fold change'?"
Medida de alteração. log2FC = **+1** → gene 2× mais expresso no tumor. log2FC = **−1** → 2× menos expresso.

### "O que é 'FDR' ou 'p-valor ajustado'?"
Probabilidade de a diferença observada ser ao acaso, corrigida para múltiplos testes (Benjamini-Hochberg). FDR < 0,05 → no máximo 5% de falsos positivos.

### "Posso mudar os parâmetros?"
Sim. Edite `R/00_setup.R` e modifique a lista `THRESHOLD`:
```r
THRESHOLD <- list(
  lfc    = 1.0,   # Aumente para fold-change mais restrito
  fdr    = 0.05,  # Reduza para mais stringência (ex.: 0.01)
  string = 700    # Reduza para incluir mais interações (ex.: 400)
)
```

---

## Reprodutibilidade

- `set.seed(42)`: seed fixa garante resultados idênticos
- Parâmetros centralizados em `R/00_setup.R`
- Caminhos via `here::here()`: sem paths absolutos
- `sessionInfo()` salvo em `logs/`
- `renv.lock`: versões exatas de todos os pacotes
- `Dockerfile`: ambiente Linux reprodutível completo
- `CITATION.cff`: metadados de citação padronizados
- `check_internet()`: validação de conectividade antes de APIs

---

## Testes

```r
# Executar todos os testes
testthat::test_dir("tests/testthat")
```

Cobertura: limiares, classificação DEG, filtro de expressão, colunas obrigatórias, NAs críticos, exportação TSV, validação de escala e filtro de escore STRING. Testes mock não requerem internet.

---

## Autores

| Autor | ORCID | Afiliação |
|--------|-------|-----------|
| **Leticia Maria Dias Freitas** (autora correspondente) | [0009-0009-9930-9588](https://orcid.org/0009-0009-9930-9588) | Escola Técnica Estadual João Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ |
| Ryan de Paulo Santos | [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001) | Instituto Federal Fluminense (IFF), Campus Campos Guarus, Campos dos Goytacazes, RJ |
| Thais Faria Coutinho da Silva Pereira | [0009-0005-7091-2480](https://orcid.org/0009-0005-7091-2480) | Escola Técnica Estadual João Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ |

**Autora correspondente:** Leticia Maria Dias Freitas: [leticiamariadiasfreitas@gmail.com](mailto:leticiamariadiasfreitas@gmail.com)

---

## Contribuições dos Autores: Taxonomia CRediT

| Autor | Contribuição |
|--------|-------------|
| **Leticia Maria Dias Freitas** | Conceitualização (Liderança); Metodologia (Igual); Software (Igual); Análise Formal (Igual); Curadoria de Dados (Igual); Validação (Igual); Visualização (Igual); Investigação (Igual); Redação — Rascunho Original (Liderança); Administração do Projeto (Suporte) |
| **Ryan de Paulo Santos** | Conceitualização (Suporte); Metodologia (Igual); Software (Igual); Análise Formal (Igual); Curadoria de Dados (Igual); Validação (Igual); Visualização (Igual); Investigação (Igual); Redação — Rascunho Original (Igual); Administração do Projeto (Liderança); Redação — Revisão & Edição (Suporte) |
| **Thais Faria Coutinho da Silva Pereira** | Supervisão (Liderança); Revisão Científica (Liderança); Validação (Suporte) |

---

## Declaração de Uso de Inteligência Artificial

Em conformidade com a **Portaria CNPq nº 2.664/2026**, declaramos que ferramentas de IA foram utilizadas como suporte técnico e metodológico:

| Ferramenta | Desenvolvedor | Tarefas |
|------------|---------------|---------|
| **DeepSeek-v4-pro** | DeepSeek | Otimização de código R, auditoria de namespaces, revisão estatística |
| **Codex** | OpenAI | Geração e debug de scripts R, documentação técnica |
| **ChatGPT 5.5** | OpenAI | Revisão textual, estruturação de documentação, sugestões de reprodutibilidade |
| **Grok** | xAI | Análise exploratória, prototipagem de visualização, suporte metodológico |

**Em todos os casos**, a participação humana foi integral e soberana. **Nenhuma conclusão científica foi derivada por IA.** Registro completo na tabela `S4_ai_assisted_tasks.tsv`.

---

## Auditoria Científica

Este projeto passou por auditoria científica completa em 24 de junho de 2026. O relatório completo está disponível em [AUDIT_REPORT.md](AUDIT_REPORT.md).

**Avaliação:**
- Originalidade: 8,5/10
- Rigor metodológico: 6,5/10
- Consistência biológica: 7,5/10
- Potencial de publicação: 7/10

Principais correções aplicadas (v3.1.0): reformulação da hipótese, remoção de alegações causais não suportadas, documentação explícita de limitações, PRKCA como protagonista.

---

## Trilha de Auditoria do Código-Fonte (24 de junho de 2026)

### Correções aplicadas (v3.1.0)

| # | Arquivo | Problema | Resolução |
|---|---------|----------|-----------|
| 1 | `01_functions.R` | `select()` conflitava com `AnnotationDbi::select` | `dplyr::select()` |
| 2 | `05_ppi.R` | `components()` / `degree()` não qualificados | `igraph::components()`, `igraph::degree()` |
| 3 | `01_functions.R` | `hub_score()` depreciado (igraph 2.0.3) | `igraph::hits_scores()` |
| 4 | `00_setup.R` | Bioconductor via `install.packages()` | `BiocManager::install()` |
| 5 | `run_pipeline.R` / `00_setup.R` | Duplicação de detecção de PROJECT_ROOT | Unificado em `00_setup.R` |
| 6 | `04_volcano.R` | Comparação incorreta de filtro KEGG | Corrigido |
| 7 | `05_ppi.R` | Layout computado duas vezes | Única computação |
| 8 | `02_import.R` | Sem verificação de duplicatas/NAs | Adicionado `anyDuplicated()`, `na_frac` |
| 9 | `00_setup.R` | Sem verificação de conectividade | Adicionado `check_internet()` |
| 10 | `04_volcano.R` / `05_ppi.R` | Sem exportação PDF | Adicionado PDF vetorial |
| 11 | `run_pipeline.R` | Sem disclaimer de causalidade | Adicionado ao final do pipeline |
| 12 | `05_ppi.R` | Hubs sem ressalva interpretativa | Adicionado aviso sobre natureza exploratória |
| 13 | `resumo_expandido_tireoide_2026.docx` | Hipótese "eixo tireoide-coração" não suportada | Reformulada para hipótese "lockada" |
| 14 | `resumo_expandido_tireoide_2026.docx` | Alegações causais sem suporte | Substituídas por linguagem geradora de hipóteses |
| 15 | `resumo_expandido_tireoide_2026.docx` | IA listada na metodologia | Removida; pipeline e scripts reprodutíveis citados |
| 16 | `resumo_expandido_tireoide_2026.docx` | Interpretação excessiva de DIO1/DIO3/MYH6/MYH7 | Limitada ao escopo transcriptômico local |

### Checklist de reprodutibilidade

| Verificação | Status |
|-------------|--------|
| Sem paths absolutos | [x] `here::here()` |
| Seed fixa | [x] `set.seed(42)` |
| Parâmetros centralizados | [x] `00_setup.R` |
| Session info capturada | [x] `logs/session_info.txt` |
| Lockfile de versões | [x] `renv.lock` |
| Container Docker | [x] `Dockerfile` |
| Testes unitários | [x] `tests/testthat/` |
| Dados documentados | [x] Bookmark + auto-download |
| Metadados de citação | [x] `CITATION.cff` |
| Verificação de internet | [x] `check_internet()` |
| Disclaimer de causalidade | [x] README + pipeline |
| Relatório de auditoria | [x] `AUDIT_REPORT.md` |

---

## Licença

MIT License: veja [LICENSE](LICENSE)

---

## Como citar

```bibtex
@software{freitas2026thyroid,
  title        = {thyroid-volcano-ppi: Análise de Expressão Diferencial e
                  Rede PPI no Carcinoma de Tireoide (THCA)},
  author       = {Leticia Maria Dias Freitas and Ryan de Paulo Santos
                  and Thais Faria Coutinho da Silva Pereira},
  year         = {2026},
  url          = {https://github.com/santosry/thyroid-volcano-ppi},
  note         = {v3.1.0}
}
```

Veja também `CITATION.cff` para metadados estruturados.

---

## Referências

1. Goldman MJ, Craft B, Hastie M, Repecka K, McDade F, Kamath A, Banerjee A, Luo Y, Rogers D, Brooks AN, Zhu J, Haussler D. Visualizing and interpreting cancer genomics data via the Xena platform. *Nature Biotechnology*. 2020;38(6):675-678. doi:[10.1038/s41587-020-0546-8](https://doi.org/10.1038/s41587-020-0546-8)

2. Ritchie ME, Phipson B, Wu D, Hu Y, Law CW, Shi W, Smyth GK. limma powers differential expression analyses for RNA-sequencing and microarray studies. *Nucleic Acids Research*. 2015;43(7):e47. doi:[10.1093/nar/gkv007](https://doi.org/10.1093/nar/gkv007)

3. Szklarczyk D, Kirsch R, Koutrouli M, Nastou K, Mehryary F, Hachilif R, Gable AL, Fang T, Doncheva NT, Pyysalo S, Bork P, Jensen LJ, von Mering C. The STRING database in 2023: protein-protein association networks and functional enrichment analyses for any sequenced genome of interest. *Nucleic Acids Research*. 2023;51(D1):D638-D646. doi:[10.1093/nar/gkac1000](https://doi.org/10.1093/nar/gkac1000)

4. Cancer Genome Atlas Research Network. Integrated genomic characterization of papillary thyroid carcinoma. *Cell*. 2014;159(3):676-690. doi:[10.1016/j.cell.2014.09.050](https://doi.org/10.1016/j.cell.2014.09.050)

5. Kanehisa M, Furumichi M, Sato Y, Kawashima M, Ishiguro-Watanabe M. KEGG for taxonomy-based analysis of pathways and genomes. *Nucleic Acids Research*. 2023;51(D1):D587-D592. doi:[10.1093/nar/gkac963](https://doi.org/10.1093/nar/gkac963)

6. Csardi G, Nepusz T, Traag V, Horvat S, Zanini F, Noom D, Muller K. igraph: Network Analysis and Visualization. R package version 2.0.3. CRAN; 2024. Available at: [https://CRAN.R-project.org/package=igraph](https://CRAN.R-project.org/package=igraph)

7. Pedersen TL. ggraph: An Implementation of Grammar of Graphics for Graphs and Networks. R package version 2.2.1. CRAN; 2024. Available at: [https://CRAN.R-project.org/package=ggraph](https://CRAN.R-project.org/package=ggraph)

---

*Pipeline mantido por [Ryan de Paulo Santos](https://github.com/santosry), ORCID: [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001)*
