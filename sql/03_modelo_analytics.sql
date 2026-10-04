-- 03_modelo_analytics.sql
-- Camada semântica: uma linha representa uma movimentação em uma data mensal.
-- VIEW é usada aqui para ensinar transformação sem duplicar armazenamento.

USE WAREHOUSE WH_LIQUIDOS_LAB;
USE DATABASE LIQUIDOS_LAB;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE VIEW fato_movimentacao AS
SELECT
  DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1) AS competencia,
  'VENDA' AS tipo_movimentacao,
  'HISTORICO' AS periodo_origem,
  agente_regulado AS entidade_origem,
  NULL::VARCHAR AS entidade_destino,
  codigo_produto, nome_produto, NULL::VARCHAR AS descricao_produto,
  regiao_origem, uf_origem, regiao_destinatario, uf_destino,
  mercado_destinatario AS destino_detalhe, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6) quantidade_mil_m3
FROM raw.vendas_historico
UNION ALL
SELECT DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1), 'VENDA', 'ATUAL', agente_regulado, NULL,
  codigo_produto, nome_produto, descricao_produto, regiao_origem, uf_origem,
  regiao_destinatario, uf_destino, mercado_destinatario, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6)
FROM raw.vendas_atual
UNION ALL
SELECT DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1), 'ENTREGA', 'HISTORICO', distribuidor_origem,
  fornecedor_destino, codigo_produto, nome_produto, NULL, regiao_origem, uf_origem,
  regiao_destinatario, uf_destino, localidade_destino, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6)
FROM raw.entregas_historico
UNION ALL
SELECT DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1), 'IMPORTACAO', 'HISTORICO', distribuidor,
  NULL, codigo_produto, nome_produto, descricao_produto, regiao_origem, uf_origem,
  regiao, uf, NULL, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6)
FROM raw.importacao_distribuidores;

-- As fontes atuais de entrega são agregados por fornecedor ou distribuidor e não têm
-- origem/destino completo. Elas ficam em uma view própria para não inventar dimensões.
CREATE OR REPLACE VIEW fato_entrega_resumida_atual AS
SELECT DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1) competencia, 'FORNECEDOR' perspectiva,
  fornecedor entidade, codigo_produto, nome_produto, regiao, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6)
FROM raw.entregas_fornecedor_atual
UNION ALL
SELECT DATE_FROM_PARTS(TO_NUMBER(ano), TO_NUMBER(mes), 1), 'DISTRIBUIDOR', distribuidor,
  codigo_produto, nome_produto, regiao, TO_DECIMAL(REPLACE(quantidade_mil_m3, ',', '.'), 18, 6)
FROM raw.entregas_distribuidor_atual;

COMMENT ON VIEW fato_movimentacao IS 'Movimentações detalhadas de vendas, entregas históricas e importações.';
COMMENT ON VIEW fato_entrega_resumida_atual IS 'Entregas atuais por perspectiva, sem granularidade origem-destino.';
