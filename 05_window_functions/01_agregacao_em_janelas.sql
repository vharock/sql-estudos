-- 05_window_functions/01_agregacao_em_janelas.sql
-- Tema: funções de agregação como window functions (AVG, MAX, MIN, SUM ... OVER)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Diferença central:
--   GROUP BY      -> colapsa as linhas: uma linha por grupo.
--   WINDOW (OVER) -> mantém todas as linhas e repete o resultado do grupo em cada uma.
-- Window functions exigem SQLite 3.25 ou mais.

-- ---------------------------------------------------------------
-- 1. [básico] Preço médio por categoria: versão GROUP BY e versão com janela.
-- 1a. GROUP BY: uma linha por categoria.
SELECT p.product_category_name,
       AVG(oi.price) AS preco_medio
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name;

-- 1b. Janela: uma linha por item, com a média da categoria ao lado.
SELECT p.product_category_name,
       oi.price,
       AVG(oi.price) OVER (PARTITION BY p.product_category_name) AS preco_medio_categoria
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
LIMIT 20;

-- ---------------------------------------------------------------
-- 2. [básico] Preço máximo por categoria e tipo de pagamento (duas colunas na partição).
-- Obs.: no material do curso essa coluna se chama "avg_price", mas é um MAX.
-- Atenção: o JOIN com pagamentos repete cada item uma vez por forma de pagamento do
-- pedido. Para análise real, cuidado com essa duplicação.
SELECT p.product_category_name,
       op.payment_type,
       MAX(oi.price) OVER (PARTITION BY p.product_category_name, op.payment_type) AS preco_maximo
FROM order_items oi
INNER JOIN products p        ON p.product_id = oi.product_id
INNER JOIN order_payments op ON op.order_id = oi.order_id
WHERE p.product_category_name IS NOT NULL
LIMIT 20;

-- ---------------------------------------------------------------
-- 3. [intermediário] Data da primeira venda de cada categoria, repetida em cada linha.
-- Sem ORDER BY dentro do OVER, o MIN considera a partição inteira.
SELECT p.product_category_name,
       oi.shipping_limit_date,
       MIN(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name) AS primeira_venda_categoria
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
LIMIT 20;
-- CUIDADO: ao acrescentar ORDER BY dentro do OVER, a janela passa a ir só do começo
-- até a linha atual, e o MIN vira um "mínimo acumulado". O material do curso usa
-- ORDER BY neste exemplo; funciona porque a ordem é crescente, mas não é necessário.

-- ---------------------------------------------------------------
-- 4. [intermediário] Participação de cada item no total da sua categoria.
-- Exemplo meu para treinar o conceito; rode e confira os resultados.
SELECT p.product_category_name,
       oi.price,
       SUM(oi.price) OVER (PARTITION BY p.product_category_name) AS total_categoria,
       ROUND(100.0 * oi.price / SUM(oi.price) OVER (PARTITION BY p.product_category_name), 4)
                                                                  AS pct_da_categoria
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
LIMIT 20;
