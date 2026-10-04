# Execute no PowerShell APÓS rodar sql/00_setup.sql.
# Requer SnowSQL configurado. Informe abaixo o nome da sua connection.

$pastaDados = 'C:\Users\dioge\Documents\Codex\liquidos'
$conexao = 'minha_conexao' # Ex.: a connection criada no arquivo ~/.snowsql/config

# O PUT envia cada arquivo ao stage interno. AUTO_COMPRESS=FALSE simplifica a inspeção.
# A barra final em @STG_LIQUIDOS é importante: ela representa o diretório raiz do stage.
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Vendas_Historico_2007_a_2017.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Vendas_Atual.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Entregas_Historico.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Entregas_Fornecedor_Atual.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Entregas_Distribuidor_Atual.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; PUT 'file://$pastaDados/Liquidos_Importacao_de_Distribuidores.csv' @STG_LIQUIDOS AUTO_COMPRESS=FALSE OVERWRITE=TRUE;"

# Confirme que os seis arquivos chegaram antes de continuar.
snowsql -c $conexao -q "USE DATABASE LIQUIDOS_LAB; USE SCHEMA RAW; LIST @STG_LIQUIDOS;"
