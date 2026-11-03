-- 04_colunas_e_funcoes/02_tipos_e_cast.sql
-- Tema: verificar e converter o tipo das colunas (typeof, CAST)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Por que importa: uma coluna numérica guardada como texto pode dar contagens,
-- somas e ordenações erradas (por exemplo, '10' < '9' como texto).

-- ---------------------------------------------------------------
-- 1. [básico] Ver o tipo de cada coluna da tabela (comando do SQLite).
-- Em outros bancos: consultar information_schema.columns.
PRAGMA table_info(order_items);

-- ---------------------------------------------------------------
-- 2. [básico] Ver o tipo REAL guardado em cada linha da coluna price
--    e quantas linhas há de cada tipo.
SELECT typeof(price) AS tipo,
       COUNT(*)      AS linhas
FROM order_items
GROUP BY typeof(price);

-- ---------------------------------------------------------------
-- 3. [básico] Efeito do CAST na soma dos preços.
SELECT SUM(price)                  AS soma_original,
       SUM(CAST(price AS INTEGER)) AS soma_como_inteiro,
       SUM(CAST(price AS REAL))    AS soma_como_decimal
FROM order_items;
-- CAST para INTEGER trunca os centavos (não arredonda), então a soma muda.
-- Usar o tipo errado em uma coluna de valores subestima os resultados.

-- ---------------------------------------------------------------
-- 4. [básico] Operações diretas sobre colunas.
SELECT COUNT(order_id)           AS itens,
       COUNT(DISTINCT order_id)  AS pedidos,
       MIN(shipping_limit_date)  AS primeiro_limite_envio,
       MAX(shipping_limit_date)  AS ultimo_limite_envio,
       AVG(freight_value)        AS frete_medio
FROM order_items;
