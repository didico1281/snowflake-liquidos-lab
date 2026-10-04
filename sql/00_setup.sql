-- 00_setup.sql
-- Cria um ambiente isolado para o laboratório. Ajuste tamanho/auto_suspend ao seu uso.

USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS WH_LIQUIDOS_LAB
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse de baixo custo para o laboratório de líquidos';

CREATE DATABASE IF NOT EXISTS LIQUIDOS_LAB
  COMMENT = 'Laboratório de ingestão e análise de movimentação de líquidos';

CREATE SCHEMA IF NOT EXISTS LIQUIDOS_LAB.RAW
  COMMENT = 'Dados de origem, com granularidade e layout preservados';
CREATE SCHEMA IF NOT EXISTS LIQUIDOS_LAB.ANALYTICS
  COMMENT = 'Dados padronizados e prontos para análise';

USE WAREHOUSE WH_LIQUIDOS_LAB;
USE DATABASE LIQUIDOS_LAB;
USE SCHEMA RAW;

-- O arquivo format descreve o CSV: ; como separador, aspas e UTF-8.
CREATE OR REPLACE FILE FORMAT FF_CSV_LIQUIDOS
  TYPE = CSV
  FIELD_DELIMITER = ';'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ENCODING = 'UTF8'
  SKIP_HEADER = 0
  EMPTY_FIELD_AS_NULL = TRUE
  NULL_IF = ('', 'NULL')
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
  COMMENT = 'CSVs de líquidos; cabeçalho será tratado em cada COPY INTO';

CREATE OR REPLACE STAGE STG_LIQUIDOS
  FILE_FORMAT = FF_CSV_LIQUIDOS
  COMMENT = 'Stage interno para os CSVs locais do laboratório';

-- Conferência útil depois do upload: LIST @STG_LIQUIDOS;
