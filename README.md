# Laboratório Snowflake — Movimentação de Líquidos

Este laboratório usa os CSVs de `../liquidos` para ensinar um fluxo Snowflake completo: criar recursos, enviar arquivos, carregar dados, modelar uma camada analítica e consultar resultados.

## O que você vai construir

```text
CSVs locais → stage interno → RAW (fontes preservadas) → ANALYTICS (modelo comum) → consultas
```

* **RAW** mantém uma tabela por layout de origem. É a zona de auditoria e reprocessamento.
* **ANALYTICS** transforma vendas e entregas em um fato único (`FATO_MOVIMENTACAO`), em volume `mil_m3`.
* Os nomes das colunas foram normalizados para `snake_case`, sem acentos. Valores numéricos usam `NUMBER(18,6)`.

## Pré-requisitos

1. Uma conta Snowflake e uma role com permissão para criar warehouse, database, schema, stage, file format e tabela.
2. [SnowSQL](https://docs.snowflake.com/en/user-guide/snowsql-install-config) instalado e configurado, ou a interface Snowsight para executar os `.sql`.
3. Os seis arquivos CSV permanecem na pasta `C:\Users\dioge\Documents\Codex\liquidos`.

> Este material usa um **stage interno** para aprendizado. Em produção, prefira um stage externo (S3, Azure Blob ou GCS), integração de armazenamento, controle de acesso mínimo e cargas automatizadas.

## Ordem de execução

1. Execute `sql/00_setup.sql`.
2. No terminal PowerShell, execute os comandos de `scripts/01_upload_para_stage.ps1` para copiar os arquivos ao Snowflake.
3. Execute `sql/02_carga_raw.sql` e confira as validações exibidas por ele.
4. Execute `sql/03_modelo_analytics.sql`.
5. Explore `sql/04_consultas_aprendizado.sql`.

O script de carga usa `ON_ERROR = 'ABORT_STATEMENT'`: se houver incompatibilidade, a carga falha sem inserir uma parte silenciosa dos dados. Para diagnosticar antes da carga, use `VALIDATION_MODE = 'RETURN_ERRORS'` no `COPY INTO` correspondente.

## Mapa das fontes

|Arquivo|Tabela RAW|Observação de layout|
|---|---|---|
|`Liquidos_Vendas_Historico_2007_a_2017.csv`|`raw.vendas_historico`|não possui cabeçalho|
|`Liquidos_Vendas_Atual.csv`|`raw.vendas_atual`|possui cabeçalho|
|`Liquidos_Entregas_Historico.csv`|`raw.entregas_historico`|possui cabeçalho|
|`Liquidos_Entregas_Fornecedor_Atual.csv`|`raw.entregas_fornecedor_atual`|agregado por fornecedor/região|
|`Liquidos_Entregas_Distribuidor_Atual.csv`|`raw.entregas_distribuidor_atual`|agregado por distribuidor/região|
|`Liquidos_Importacao_de_Distribuidores.csv`|`raw.importacao_distribuidores`|origem e destino da importação|

## Como executar no Snowsight

Abra cada arquivo SQL na ordem indicada. Para o upload, use a página **Data » Databases » LIQUIDOS_LAB » RAW » Stages » STG_LIQUIDOS**, botão **+ Files**, preservando os nomes originais. Depois continue na etapa 3.

## Limpeza opcional

Quando acabar o laboratório, remova tudo com `DROP DATABASE IF EXISTS LIQUIDOS_LAB;`. Isso é irreversível para os objetos e dados dentro desse banco.
