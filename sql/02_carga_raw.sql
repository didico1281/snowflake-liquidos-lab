-- 02_carga_raw.sql
-- Cria as tabelas de aterrissagem e copia cada arquivo do stage.
-- Todos os campos são VARCHAR na RAW: é uma aterrissagem fiel ao CSV. Isso também
-- evita que a vírgula decimal brasileira seja interpretada incorretamente no COPY.

USE WAREHOUSE WH_LIQUIDOS_LAB;
USE DATABASE LIQUIDOS_LAB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE vendas_historico (
  ano VARCHAR, mes VARCHAR, agente_regulado VARCHAR,
  codigo_produto VARCHAR, nome_produto VARCHAR, regiao_origem VARCHAR,
  uf_origem VARCHAR, regiao_destinatario VARCHAR, uf_destino VARCHAR,
  mercado_destinatario VARCHAR, quantidade_mil_m3 VARCHAR
);
CREATE OR REPLACE TABLE vendas_atual (
  ano VARCHAR, mes VARCHAR, agente_regulado VARCHAR,
  codigo_produto VARCHAR, nome_produto VARCHAR, descricao_produto VARCHAR,
  regiao_origem VARCHAR, uf_origem VARCHAR, regiao_destinatario VARCHAR,
  uf_destino VARCHAR, mercado_destinatario VARCHAR, quantidade_mil_m3 VARCHAR
);
CREATE OR REPLACE TABLE entregas_historico (
  ano VARCHAR, mes VARCHAR, fornecedor_destino VARCHAR,
  distribuidor_origem VARCHAR, codigo_produto VARCHAR, nome_produto VARCHAR,
  regiao_origem VARCHAR, uf_origem VARCHAR, localidade_destino VARCHAR,
  regiao_destinatario VARCHAR, uf_destino VARCHAR, quantidade_mil_m3 VARCHAR
);
CREATE OR REPLACE TABLE entregas_fornecedor_atual (
  ano VARCHAR, mes VARCHAR, fornecedor VARCHAR, codigo_produto VARCHAR,
  nome_produto VARCHAR, regiao VARCHAR, quantidade_mil_m3 VARCHAR
);
CREATE OR REPLACE TABLE entregas_distribuidor_atual (
  ano VARCHAR, mes VARCHAR, distribuidor VARCHAR, codigo_produto VARCHAR,
  nome_produto VARCHAR, regiao VARCHAR, quantidade_mil_m3 VARCHAR
);
CREATE OR REPLACE TABLE importacao_distribuidores (
  ano VARCHAR, mes VARCHAR, distribuidor VARCHAR, regiao VARCHAR,
  uf VARCHAR, codigo_produto VARCHAR, nome_produto VARCHAR, descricao_produto VARCHAR,
  regiao_origem VARCHAR, uf_origem VARCHAR, quantidade_mil_m3 VARCHAR
);

-- Cada COPY aponta explicitamente o arquivo. Assim, um arquivo novo no stage não é
-- carregado acidentalmente. SKIP_HEADER=1 é sobrescrito somente onde há cabeçalho.
COPY INTO vendas_historico
FROM @STG_LIQUIDOS/Liquidos_Vendas_Historico_2007_a_2017.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 0)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO vendas_atual
FROM @STG_LIQUIDOS/Liquidos_Vendas_Atual.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 1)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO entregas_historico
FROM @STG_LIQUIDOS/Liquidos_Entregas_Historico.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 1)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO entregas_fornecedor_atual
FROM @STG_LIQUIDOS/Liquidos_Entregas_Fornecedor_Atual.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 1)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO entregas_distribuidor_atual
FROM @STG_LIQUIDOS/Liquidos_Entregas_Distribuidor_Atual.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 1)
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO importacao_distribuidores
FROM @STG_LIQUIDOS/Liquidos_Importacao_de_Distribuidores.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_LIQUIDOS SKIP_HEADER = 1)
ON_ERROR = 'ABORT_STATEMENT';

-- Validações mínimas: espere seis linhas de resultado e procure anos/meses inválidos.
SELECT 'vendas_historico' fonte, COUNT(*) linhas, MIN(ano) ano_min, MAX(ano) ano_max FROM vendas_historico
UNION ALL SELECT 'vendas_atual', COUNT(*), MIN(ano), MAX(ano) FROM vendas_atual
UNION ALL SELECT 'entregas_historico', COUNT(*), MIN(ano), MAX(ano) FROM entregas_historico
UNION ALL SELECT 'entregas_fornecedor_atual', COUNT(*), MIN(ano), MAX(ano) FROM entregas_fornecedor_atual
UNION ALL SELECT 'entregas_distribuidor_atual', COUNT(*), MIN(ano), MAX(ano) FROM entregas_distribuidor_atual
UNION ALL SELECT 'importacao_distribuidores', COUNT(*), MIN(ano), MAX(ano) FROM importacao_distribuidores;

SELECT * FROM vendas_atual WHERE TRY_TO_NUMBER(mes) NOT BETWEEN 1 AND 12
  OR TRY_TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6) < 0;
