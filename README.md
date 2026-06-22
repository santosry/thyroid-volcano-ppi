# thyroid-volcano-ppi

**Analise de Expressao Diferencial e Rede de Interacao Proteina-Proteina no Carcinoma de Tireoide (THCA)**

[![R >= 4.1](https://img.shields.io/badge/R-%E2%89%A5%204.1-blue)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![renv](https://img.shields.io/badge/renv-locked-blueviolet)](renv.lock)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker)](Dockerfile)

---

> **Este README foi escrito para profissionais da saude.**
> Se voce nunca usou R ou GitHub na vida, nao se preocupe: cada passo esta explicado abaixo.

---

## Sumario

- [Para Profissionais da Saude](#para-profissionais-da-saude) : Guia completo passo a passo
- [Desenho do Estudo](#desenho-do-estudo) : Metodos, fontes de dados e parametros
- [Limitacoes](#limitacoes) : O que esta analise NAO prova
- [Estrutura do Pipeline](#estrutura-do-pipeline) : Organizacao dos scripts
- [Como Executar](#como-executar) : Comandos para rodar
- [Outputs e Interpretacao](#outputs-e-interpretacao) : Figuras e tabelas geradas
- [Referencias](#referencias) : Citacoes completas

---

## Para Profissionais da Saude

### O que este projeto faz?

Este projeto compara **quais genes estao com a atividade alterada** em tumores de tireoide (carcinoma papilifero, THCA) em relacao ao tecido normal da tireoide.

Usamos dados publicos do **TCGA** (The Cancer Genome Atlas) e do **GTEx** (Genotype-Tissue Expression), totalizando **783 amostras**: 504 de tumor e 279 de tecido normal.

O foco e na **via de sinalizacao do hormonio tireoidiano** (KEGG hsa04919), com 121 genes analisados.

### Os dois resultados principais

| Figura | O que mostra |
|--------|-------------|
| **Figura 1: Volcano Plot** | Quais genes estao **superexpressos** (mais ativos) ou **subexpressos** (menos ativos) no tumor, e com que nivel de significancia estatistica |
| **Figura 2: Rede PPI** | Como as **proteinas** desses genes interagem entre si, formando uma rede de contatos, e quais proteinas sao os "hubs" (pontos centrais da rede) |

### ATENCAO: O que esta analise NAO faz

- **NAO** estabelece causalidade (associacao nao e causa)
- **NAO** identifica alvos terapeuticos validados
- **NAO** substitui validacao experimental (PCR, Western blot, etc.)
- **NAO** corrige efeitos de batch entre TCGA e GTEx
- Os **hubs** da rede PPI sao metricas de centralidade exploratorias; **nao implicam importancia biologica comprovada ou druggability**

### O que voce precisa ter instalado?

#### 1. Instale o R

O R e um programa gratuito de analise estatistica.

- Acesse: **https://cran.r-project.org/**
- Clique em **"Download R for Windows"** (ou macOS, conforme seu sistema)
- Clique em **"base"** e depois em **"Download R-X.X.X for Windows"**
- Execute o instalador e siga os passos: **Avancar, Avancar, Concluir**

#### 2. Instale o VS Code (recomendado) ou RStudio

O R pode ser usado com duas interfaces principais. O **VS Code** e a melhor opcao por ser mais moderno e versatil. O **RStudio** tambem funciona.

**VS Code:**
- Acesse: **https://code.visualstudio.com/**
- Baixe e instale normalmente
- Depois, instale a extensao **R** (busque por "R" na aba de extensoes, atalho `Ctrl+Shift+X`)
- Instale tambem a extensao **R Debugger**

**RStudio:**
- Acesse: **https://posit.co/download/rstudio-desktop/**
- Baixe a versao gratuita (RStudio Desktop, Open Source Edition)
- Instale normalmente

### Passo a passo para rodar o script

#### Antes de começar: baixe o repositorio

Voce pode baixar o projeto inteiro de duas formas:

**Opcao A: Se voce NAO tem Git instalado (a mais facil):**
1. No topo desta pagina do GitHub, clique no botao verde **"<> Code"**
2. Clique em **"Download ZIP"**
3. Extraia o arquivo `.zip` para uma pasta no seu computador (ex: `C:\Users\SeuNome\Downloads\thyroid-volcano-ppi`)
4. Essa pasta extraida sera seu **diretorio de trabalho**

**Opcao B: Se voce tem Git instalado:**
```bash
git clone https://github.com/santosry/thyroid-volcano-ppi.git
```

#### PASSO 1: Baixe o arquivo de dados (OBRIGATORIO)

O script **nao funciona** sem o arquivo de expressao genica. Voce tem duas opcoes:

**Opcao 1: Download automatico (recomendado):**
1. Abra o VS Code (ou RStudio)
2. No menu superior, clique em **File, Open File**
3. Navegue ate a pasta do projeto e abra o arquivo `run_pipeline.R`
4. No terminal (ou console do R), digite:
```r
source("scripts/download_data.R")
```
5. O download sera feito automaticamente (~5 MB). Aguarde a mensagem de confirmacao.

**Opcao 2: Download manual:**
1. Acesse este link: **https://xenabrowser.net/?bookmark=c486b845ee2e750c3a9d2fc5145c8426**
2. No canto superior direito, clique no botao **"Download"**
3. Selecione **"Download current visualization data"**
4. Salve o arquivo exatamente como: **`XENA_THCA.tsv`**
5. Mova o arquivo para a pasta: `data/raw/` (dentro da pasta do projeto)

> **Importante:** O arquivo DEVE estar em: `thyroid-volcano-ppi/data/raw/XENA_THCA.tsv`

#### PASSO 2: Instale os pacotes necessarios

Na primeira vez que rodar, o script instala tudo automaticamente. Mas se quiser instalar antes:

1. Abra o VS Code (ou RStudio)
2. No terminal (ou console do R), copie e cole o seguinte comando:
```r
install.packages("renv")
renv::restore()
```
3. Aguarde a instalacao terminar (pode levar de 5 a 15 minutos, dependendo da sua internet)
4. Varios pacotes serao instalados: e normal aparecerem muitas mensagens

> **O que esta acontecendo?** O comando `renv::restore()` esta instalando exatamente as mesmas versoes de pacotes que os autores usaram. Isso garante que o resultado seja reproduzivel.

#### PASSO 3: Execute o script

1. No VS Code (ou RStudio), abra o arquivo `run_pipeline.R`
2. Execute o script: no VS Code pressione `Ctrl+Shift+S`, ou no RStudio clique em **"Source"** (canto superior direito)
   - Ou digite no console:
```r
source("run_pipeline.R")
```
3. Aguarde de **3 a 5 minutos** (o script precisa de internet para acessar os bancos de dados STRING e KEGG)
4. Se tudo der certo, voce vera a mensagem: **"PIPELINE COMPLETED SUCCESSFULLY"**

#### PASSO 4: Veja os resultados

Todos os resultados estarao na pasta `results/`:

- **Figuras:** `results/figures/`
  - `Fig1_Volcano_THCA_vs_Normal.png` (e `.pdf`) : Volcano Plot
  - `Fig2_PPI_Network_THCA_DEGs.png` (e `.pdf`) : Rede de interacao proteina-proteina
- **Tabelas:** `results/tables/`
- **Metadados da rede:** `results/network/`

---

## Desenho do Estudo

### Metodo

| Etapa | Metodo | Ferramenta |
|-------|--------|------------|
| Expressao diferencial | Modelo linear + Bayes empirico | limma (Bioconductor) |
| Contraste | THCA vs Normal (GTEx) | makeContrasts |
| Correcao multipla | Benjamini-Hochberg (FDR) | topTable |
| Rede PPI | STRING REST API v12.0 | httr + jsonlite |
| Centralidade | Betweenness, degree, closeness, hub score | igraph |
| Visualizacao | Volcano Plot + Rede PPI (Cell Press standard) | ggplot2 + ggrepel + ggraph |

### Fontes de Dados

| Fonte | Descricao | Acesso |
|-------|-----------|--------|
| **TCGA THCA** | 504 amostras de carcinoma papilifero de tireoide | UCSC Xena Browser |
| **GTEx Thyroid** | 279 amostras de tecido normal de tireoide | UCSC Xena Browser |
| **KEGG hsa04919** | Via de sinalizacao do hormonio tireoidiano | KEGG REST API |
| **STRING v12.0** | Interacoes proteina-proteina (high confidence >= 700) | STRING REST API |

### Parametros da Analise

| Parametro | Valor | Significado |
|-----------|-------|-------------|
| log2FC minimo | 1.0 | Mudanca de pelo menos 2x na expressao |
| FDR maximo | 0.05 | Maximo de 5% de falsos positivos (Benjamini-Hochberg) |
| Filtro de expressao | >0.5 em >=10% | Genes precisam ter sinal detectavel |
| Escore STRING minimo | 700 | Alta confianca na interacao proteica |
| Via KEGG | hsa04919 | Sinalizacao do hormonio tireoidiano |
| Versao STRING | 12.0 | Versao mais recente do banco |
| Seed | 42 | Garante reproducibilidade dos resultados |

### Como interpretar os resultados

#### Figura 1: Volcano Plot

O Volcano Plot e o grafico mais comum em estudos de expressao genica.

| Elemento | O que significa |
|----------|----------------|
| **Eixo X** | `log2(fold change)`: direcao e intensidade da mudanca. Valores **positivos** = gene mais expresso no tumor. Valores **negativos** = gene menos expresso no tumor |
| **Eixo Y** | `-log10(valor-p ajustado)`: significancia estatistica. Quanto **mais alto** o ponto, **mais confiavel** e a diferenca |
| **Pontos azuis** | Genes **superexpressos** no tumor (9 genes). A atividade desses genes esta aumentada no cancer |
| **Pontos magenta** | Genes **subexpressos** no tumor (20 genes). A atividade desses genes esta diminuida no cancer |
| **Pontos cinza** | Genes sem diferenca significativa (90 genes) |
| **Linhas tracejadas** | Limiares estatisticos: linha vertical = 2x de mudanca; linha horizontal = 5% de taxa de falsa descoberta (FDR) |
| **Circulos abertos** | Genes que pertencem a via KEGG do hormonio tireoidiano (hsa04919) |
| **Nomes nos pontos** | Genes mais relevantes identificados com ggrepel |

**Resumo:** Genes no canto superior direito = mais ativos no tumor, com alta confianca estatistica. Genes no canto superior esquerdo = menos ativos no tumor. No total, **29 genes** mostraram diferenca significativa (9 up, 20 down).

#### Figura 2: Rede de Interacao Proteina-Proteina (PPI)

A rede PPI mostra como as proteinas dos genes alterados interagem fisicamente umas com as outras.

| Elemento | O que significa |
|----------|----------------|
| **Cada circulo (no)** | Uma proteina codificada por um gene diferencialmente expresso |
| **Cores dos nos** | Cada cor representa um **modulo funcional**: proteinas que trabalham juntas na mesma funcao biologica (detectado pelo algoritmo walktrap) |
| **Tamanho do no** | Proporcional ao **grau de conectividade** (degree): quantas outras proteinas ela interage. Quanto maior, mais conectada |
| **Borda grossa escura** | **Proteina Hub**: proteina central da rede, com muitas conexoes. Sao 5 hubs identificados |
| **Linhas entre nos** | Interacao fisica entre duas proteinas, conforme STRING v12.0 (escore >= 700) |
| **Linhas cinza** | Interacoes dentro do mesmo modulo funcional |
| **Linhas rosa claro** | Interacoes entre modulos diferentes |

**IMPORTANTE:** Os **hubs** sao identificados por metricas de centralidade (betweenness, degree). Eles **nao** representam alvos terapeuticos validados, **nao** implicam causalidade e **nao** substituem validacao experimental. Sao hipoteses geradas por metodos computacionais exploratorios.

---

## Limitacoes

Esta analise possui limitacoes importantes que devem ser consideradas na interpretacao:

1. **Efeito de batch TCGA/GTEx:** As amostras de tumor (TCGA) e normal (GTEx) vem de fontes diferentes, com protocolos de sequenciamento distintos. Nao foi aplicada correcao de batch effect. Diferencas observadas podem refletir, em parte, vies tecnico.

2. **Associacao vs causalidade:** Expressao diferencial indica associacao estatistica, nao relacao causal. Genes identificados como DEGs podem ser consequencia (e nao causa) do processo neoplasico.

3. **Rede PPI in silico:** As interacoes proteina-proteina sao preditas/inferidas pelo banco STRING (evidencia combinada: texto, experimentos, co-expressao, etc.). Nao ha validacao experimental direta.

4. **Hubs exploratorios:** Proteinas hub sao definidas por metricas de centralidade de rede. Elas **nao** devem ser interpretadas como alvos terapeuticos ou biomarcadores sem validacao adicional.

5. **Generalizacao:** Os resultados se aplicam ao contexto especifico THCA (carcinoma papilifero) com dados TCGA/GTEx. Extrapolacao para outros subtipos histologicos requer cautela.

6. **Dependencia de APIs externas:** O pipeline requer conexao com internet para STRING e KEGG. Mudancas nessas APIs podem afetar a reprodutibilidade futura.

---

## Estrutura do Pipeline

```
thyroid-volcano-ppi/
├── run_pipeline.R              Script principal (e so rodar este!)
├── R/
│   ├── 00_setup.R              Parametros, pacotes, cores, check internet
│   ├── 01_functions.R          Funcoes auxiliares (KEGG, STRING, export)
│   ├── 02_import.R             Importacao e validacao dos dados
│   ├── 03_deg.R                Expressao diferencial (limma + Bayes empirico)
│   ├── 04_volcano.R            Figura 1: Volcano Plot (PNG + PDF)
│   ├── 05_ppi.R                Figura 2: Rede PPI (PNG + PDF)
│   └── 06_supplementary.R      Tabelas suplementares S1-S4
├── data/
│   ├── raw/                    Coloque XENA_THCA.tsv aqui
│   ├── processed/              Dados intermediarios
│   └── string_cache/           Cache do STRING
├── scripts/
│   ├── download_data.R         Download automatico dos dados
│   └── setup_renv.R            Inicializacao do renv
├── results/
│   ├── figures/                PNGs 600 dpi + PDFs vetoriais
│   ├── tables/                 Tabelas TSV (7 principais + 4 suplementares)
│   └── network/                Metadados da rede PPI
├── tests/
│   ├── testthat.R              Runner de testes
│   └── testthat/               Testes unitarios (com e sem internet)
├── docs/                       Documentacao suplementar
├── logs/                       Logs de execucao + sessionInfo()
├── Dockerfile                  Container Docker reproduzivel
├── renv.lock                   Versoes exatas dos pacotes R
├── LICENSE                     MIT
└── CITATION.cff                Metadados de citacao
```

---

## Como Executar

```bash
# 1. Clone o repositorio
git clone https://github.com/santosry/thyroid-volcano-ppi.git
cd thyroid-volcano-ppi

# 2. Baixe os dados (automatico ou manual)
Rscript scripts/download_data.R

# 3. Restaure o ambiente R (opcional, mas recomendado)
R -e 'install.packages("renv"); renv::restore()'

# 4. Execute o pipeline
Rscript run_pipeline.R

# 5. Execute os testes (opcional)
R -e 'testthat::test_dir("tests/testthat")'
```

**Tempo estimado:** 3-5 minutos com internet.

---

## Outputs e Interpretacao

### Tabelas principais (`results/tables/`)

| Arquivo | Conteudo |
|---------|---------|
| `T01_sample_composition.tsv` | Quantas amostras de cada tipo (Normal vs THCA) foram analisadas |
| `T02_deg_summary.tsv` | Resumo dos parametros da analise: quantos genes testados, quantos DEGs, thresholds usados |
| `T03_deg_full_results.tsv` | Resultado completo: todos os genes com log2FC, valor-p, valor-p ajustado, classificacao (Up/Down/NS) |
| `T04_top20_degs.tsv` | Os 20 genes com maior diferenca de expressao |
| `T05_kegg_missing_genes.tsv` | Genes da via KEGG que nao foram detectados nos dados |
| `T06_hub_proteins.tsv` | Proteinas hub da rede PPI com metricas de centralidade |
| `T07_kegg_degs_ppi.tsv` | Tabela integrada: genes KEGG que sao DEGs + suas metricas na rede PPI |

### Metadados da rede (`results/network/`)

| Arquivo | Conteudo |
|---------|---------|
| `N01_string_mapping.tsv` | Mapeamento: gene -> ID da proteina no STRING |
| `N02_string_interactions.tsv` | Lista de interacoes proteina-proteina usadas na rede |
| `N03_centrality_metrics.tsv` | Metricas completas de centralidade para cada proteina |
| `N04_network_summary.tsv` | Estatisticas globais da rede (nos, arestas, hubs, comunidades) |

### Parametros das figuras

Ambas as figuras seguem o padrao editorial da **Nature Communications / Cell Press**:

| Propriedade | Especificacao |
|-------------|---------------|
| Formato | PNG 600 dpi + PDF vetorial |
| Volcano Plot | 180 x 150 mm |
| Rede PPI | 180 x 180 mm |
| Tipografia | Sans-serif (Arial/Helvetica), 14pt |
| Fundo | Branco, eixos abertos |
| Cores | Azul `#4477AA` (Superexpresso), Magenta `#AA4488` (Subexpresso) |
| Rotulos | ggrepel com linhas guia |
| Rede PPI | Layout Fruchterman-Reingold, comunidades walktrap |

---

## Perguntas frequentes (FAQ)

### "Apareceu um erro dizendo que o arquivo XENA_THCA.tsv nao foi encontrado"

**Solucao:** Volte ao PASSO 1 acima e baixe o arquivo de dados.

### "O download automatico falhou"

**Solucao:** Use o download manual (Opcao 2 do PASSO 1).

### "Deu erro de conexao com a internet durante a analise"

**Solucao:** O script verifica a conectividade no inicio. STRING e KEGG requerem internet. Verifique sua conexao e tente novamente.

### "Quanto tempo demora para rodar?"

Cerca de **3 a 5 minutos** com boa conexao. Primeira execucao: +10-15 min para instalar pacotes.

### "O que e 'log2 fold change'?"

Medida de mudanca na expressao. log2FC de **+1** = gene 2x mais expresso no tumor. log2FC de **+2** = 4x mais expresso. log2FC de **-1** = 2x menos expresso.

### "O que e 'FDR' ou 'valor-p ajustado'?"

O valor-p mede a probabilidade de a diferenca ser obra do acaso. Como testamos muitos genes ao mesmo tempo, o valor-p e ajustado (correcao Benjamini-Hochberg). **FDR < 0,05** significa que aceitamos no maximo 5% de falsos positivos.

### "Nao sei usar o R. Tem outro jeito?"

Nao se preocupe: voce so precisa copiar e colar os comandos. Com o VS Code ou RStudio, e ainda mais facil: abra o script e execute. O R fara todo o trabalho.

### "Quero mudar os parametros da analise"

Abra o arquivo `R/00_setup.R` e altere os valores dentro da lista `THRESHOLD`:
```r
THRESHOLD <- list(
  lfc        = 1.0,     # Aumente para ser mais restritivo
  fdr        = 0.05,    # Diminua para ser mais rigoroso (ex: 0.01)
  string     = 700      # Diminua para incluir mais interacoes (ex: 400)
)
```
Depois execute o script novamente.

---

## Reprodutibilidade

- `set.seed(42)`: a semente fixa garante resultados identicos
- Todos os parametros em `R/00_setup.R`
- Caminhos via `here::here()`: sem caminhos absolutos
- `sessionInfo()` salvo em `logs/`
- `renv.lock`: versoes exatas de todos os pacotes
- `Dockerfile`: ambiente Linux completo e reproduzivel
- `CITATION.cff`: metadados de citacao padronizados
- `results/CHECKSUMS.md`: hashes MD5 para verificacao de integridade
- `check_internet()`: verificacao de conectividade antes de chamadas API

Para verificar a integridade dos outputs apos executar o pipeline:
```bash
cd results && md5sum -c CHECKSUMS.md
```

---

## Testes

```r
# Executar todos os testes
testthat::test_dir("tests/testthat")
```

Testes cobrem: thresholds, classificacao DEG, filtro de expressao, colunas obrigatorias, NAs criticos, exportacao TSV, validacao de escala e filtro de escore STRING. Testes com mock data nao requerem internet.

---

## Autores

| Autor | ORCID | Afiliacao |
|--------|-------|-----------|
| **Leticia Maria Dias Freitas** (autora correspondente) | [0009-0009-9930-9588](https://orcid.org/0009-0009-9930-9588) | Escola Tecnica Estadual Joao Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ |
| Ryan de Paulo Santos | [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001) | Instituto Federal de Educacao, Ciencia e Tecnologia Fluminense (IFFluminense), Campus Campos Guarus, Campos dos Goytacazes, RJ |
| Thais Faria Coutinho da Silva Pereira | [0009-0005-7091-2480](https://orcid.org/0009-0005-7091-2480) | Escola Tecnica Estadual Joao Barcelos Martins (FAETEC), Campos dos Goytacazes, RJ |

**Autora correspondente:** Leticia Maria Dias Freitas: [leticiamariadiasfreitas@gmail.com](mailto:leticiamariadiasfreitas@gmail.com)

---

## Contribuicoes dos Autores: CRediT Taxonomy

| Autor | Contribuicao |
|--------|-------------|
| **Leticia Maria Dias Freitas** | Conceituacao (Lideranca); Metodologia (Igual); Software (Igual); Analise Formal (Igual); Curadoria de Dados (Igual); Validacao (Igual); Visualizacao (Igual); Investigacao (Igual); Escrita: Rascunho Original (Lideranca); Administracao do Projeto (Suporte) |
| **Ryan de Paulo Santos** | Conceituacao (Suporte); Metodologia (Igual); Software (Igual); Analise Formal (Igual); Curadoria de Dados (Igual); Validacao (Igual); Visualizacao (Igual); Investigacao (Igual); Escrita: Rascunho Original (Igual); Administracao do Projeto (Lideranca); Escrita: Revisao e Edicao (Suporte) |
| **Thais Faria Coutinho da Silva Pereira** | Supervisao (Lideranca); Revisao Cientifica (Lideranca); Validacao (Suporte) |

---

## Declaracao de Uso de Inteligencia Artificial

Em conformidade com a **Portaria CNPq no 2.664/2026**, declaramos que as seguintes ferramentas de IA foram utilizadas como suporte tecnico e metodologico:

| Ferramenta | Desenvolvedor | Tarefas |
|------------|---------------|---------|
| **DeepSeek-v4-pro** | DeepSeek | Otimizacao de codigo R, auditoria de namespaces, revisao de funcoes estatisticas |
| **Codex** | OpenAI | Geracao e depuracao de scripts R, suporte a documentacao tecnica |
| **ChatGPT 5.5** | OpenAI | Revisao textual, estruturacao de documentacao, sugestoes de reprodutibilidade |
| **Grok** | xAI | Analise exploratoria, prototipagem de visualizacoes, suporte metodologico |

**Em todos os casos**, a participacao humana foi integral e soberana. **Nenhuma conclusao cientifica foi derivada por IA.** Para o registro completo, consulte a tabela `S4_ai_assisted_tasks.tsv`.

---

## Licenca

MIT License: veja o arquivo [LICENSE](LICENSE)

---

## Como citar

```bibtex
@software{freitas2026thyroid,
  title        = {thyroid-volcano-ppi: Differential Expression and
                  PPI Network Analysis in Thyroid Carcinoma (THCA)},
  author       = {Leticia Maria Dias Freitas and Ryan de Paulo Santos
                  and Thais Faria Coutinho da Silva Pereira},
  year         = {2026},
  url          = {https://github.com/santosry/thyroid-volcano-ppi},
  note         = {v3.0.0}
}
```

Veja tambem `CITATION.cff` para metadados de citacao estruturados.

---

## Referencias

1. Goldman MJ, Craft B, Hastie M, Repecka K, McDade F, Kamath A, Banerjee A, Luo Y, Rogers D, Brooks AN, Zhu J, Haussler D. Visualizing and interpreting cancer genomics data via the Xena platform. *Nature Biotechnology*. 2020;38(6):675-678. doi:[10.1038/s41587-020-0546-8](https://doi.org/10.1038/s41587-020-0546-8)

2. Ritchie ME, Phipson B, Wu D, Hu Y, Law CW, Shi W, Smyth GK. limma powers differential expression analyses for RNA-sequencing and microarray studies. *Nucleic Acids Research*. 2015;43(7):e47. doi:[10.1093/nar/gkv007](https://doi.org/10.1093/nar/gkv007)

3. Szklarczyk D, Kirsch R, Koutrouli M, Nastou K, Mehryary F, Hachilif R, Gable AL, Fang T, Doncheva NT, Pyysalo S, Bork P, Jensen LJ, von Mering C. The STRING database in 2023: protein-protein association networks and functional enrichment analyses for any sequenced genome of interest. *Nucleic Acids Research*. 2023;51(D1):D638-D646. doi:[10.1093/nar/gkac1000](https://doi.org/10.1093/nar/gkac1000)

4. Cancer Genome Atlas Research Network. Integrated genomic characterization of papillary thyroid carcinoma. *Cell*. 2014;159(3):676-690. doi:[10.1016/j.cell.2014.09.050](https://doi.org/10.1016/j.cell.2014.09.050)

5. Kanehisa M, Furumichi M, Sato Y, Kawashima M, Ishiguro-Watanabe M. KEGG for taxonomy-based analysis of pathways and genomes. *Nucleic Acids Research*. 2023;51(D1):D587-D592. doi:[10.1093/nar/gkac963](https://doi.org/10.1093/nar/gkac963)

6. Csardi G, Nepusz T, Traag V, Horvat S, Zanini F, Noom D, Muller K. igraph: Network Analysis and Visualization. R package version 2.0.3. CRAN; 2024. Disponivel em: [https://CRAN.R-project.org/package=igraph](https://CRAN.R-project.org/package=igraph)

7. Pedersen TL. ggraph: An Implementation of Grammar of Graphics for Graphs and Networks. R package version 2.2.1. CRAN; 2024. Disponivel em: [https://CRAN.R-project.org/package=ggraph](https://CRAN.R-project.org/package=ggraph)

---

## Trilha de Auditoria do Codigo-Fonte (22/jun/2026)

### Correcoes aplicadas (v3.0.0)

| # | Arquivo | Problema | Solucao |
|---|---------|----------|---------|
| 1 | `01_functions.R` | `select()` conflitava com `AnnotationDbi::select` | `dplyr::select()` |
| 2 | `05_ppi.R` | `components()` / `degree()` sem namespace | `igraph::components()`, `igraph::degree()` |
| 3 | `01_functions.R` | `hub_score()` depreciado (igraph 2.0.3) | `igraph::hits_scores()` |
| 4 | `00_setup.R` | Bioconductor via `install.packages()` | `BiocManager::install()` |
| 5 | `run_pipeline.R` / `00_setup.R` | Duplicacao de deteccao de here/PROJECT_ROOT | Unificado em `00_setup.R` |
| 6 | `04_volcano.R` | Filtro KEGG com comparacao incorreta | Corrigido |
| 7 | `05_ppi.R` | Layout calculado duas vezes | Calculo unico |
| 8 | `02_import.R` | Sem verificacao de duplicatas ou NAs | Adicionado `anyDuplicated()`, `na_frac` |
| 9 | `00_setup.R` | Sem verificacao de internet | Adicionado `check_internet()` |
| 10 | `04_volcano.R` / `05_ppi.R` | Sem export PDF | Adicionado PDF vetorial |
| 11 | `run_pipeline.R` | Sem disclaimer de causalidade | Adicionado ao final |
| 12 | `05_ppi.R` | Hubs sem caveat | Adicionado aviso de interpretacao |

### Checklist de reprodutibilidade

| Verificacao | Status |
|-------------|--------|
| Sem caminhos absolutos | [x] `here::here()` |
| Semente fixa | [x] `set.seed(42)` |
| Parametros centralizados | [x] `00_setup.R` |
| Session info capturado | [x] `logs/session_info.txt` |
| Lockfile de versoes | [x] `renv.lock` |
| Container Docker | [x] `Dockerfile` |
| Testes unitarios | [x] `tests/testthat/` |
| Dados documentados | [x] Bookmark + auto-download |
| Metadados de citacao | [x] `CITATION.cff` |
| Internet check | [x] `check_internet()` |
| Disclaimer causalidade | [x] README + final do pipeline |

---

*Pipeline mantido por [Ryan de Paulo Santos](https://github.com/santosry), ORCID: [0009-0005-6770-2001](https://orcid.org/0009-0005-6770-2001)*
