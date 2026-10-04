-- 04_consultas_aprendizado.sql
USE WAREHOUSE WH_LIQUIDOS_LAB;
USE DATABASE LIQUIDOS_LAB;
USE SCHEMA ANALYTICS;

-- 1. Volume mensal por tipo de movimentação.
SELECT competencia, tipo_movimentacao, SUM(quantidade_mil_m3) volume_mil_m3
FROM fato_movimentacao
GROUP BY 1, 2
ORDER BY 1, 2;

-- 2. Top 10 produtos em vendas no período mais recente disponível.
WITH ultimo_mes AS (SELECT MAX(competencia) competencia FROM fato_movimentacao WHERE tipo_movimentacao = 'VENDA')
SELECT nome_produto, SUM(quantidade_mil_m3) volume_mil_m3
FROM fato_movimentacao
WHERE tipo_movimentacao = 'VENDA' AND competencia = (SELECT competencia FROM ultimo_mes)
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- 3. Ranking de UFs destino com função de janela.
SELECT competencia, uf_destino, SUM(quantidade_mil_m3) volume_mil_m3,
  RANK() OVER (PARTITION BY competencia ORDER BY SUM(quantidade_mil_m3) DESC) ranking_na_data
FROM fato_movimentacao
WHERE tipo_movimentacao = 'VENDA' AND uf_destino IS NOT NULL
GROUP BY 1, 2
QUALIFY ranking_na_data <= 5
ORDER BY competencia DESC, ranking_na_data;

-- 4. Crescimento mensal de vendas com LAG.
WITH mensal AS (
  SELECT competencia, SUM(quantidade_mil_m3) volume_mil_m3
  FROM fato_movimentacao WHERE tipo_movimentacao = 'VENDA' GROUP BY 1
)
SELECT competencia, volume_mil_m3,
  volume_mil_m3 - LAG(volume_mil_m3) OVER (ORDER BY competencia) variacao_mensal_mil_m3
FROM mensal ORDER BY competencia;

-- 5. Compare as duas perspectivas dos dados atuais de entrega.
SELECT perspectiva, competencia, SUM(quantidade_mil_m3) volume_mil_m3
FROM fato_entrega_resumida_atual
GROUP BY 1, 2 ORDER BY 2, 1;
