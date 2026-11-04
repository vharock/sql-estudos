-- 06_cte_with/03_reescrevendo_subqueries_com_cte.sql
-- Tema: reescrever consultas com subqueries usando WITH
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Refatorações das consultas da pasta 03_subqueries, mantendo o resultado e
-- melhorando a leitura. Rode as duas versões e compare.

-- ---------------------------------------------------------------
-- 1. [avançado] Tabela diária (nota média, preço médio, soma e mínimo, pedidos e
--    clientes únicos), ancorada na data de compra.
-- Antes: três subqueries aninhadas no FROM (veja 03_subqueries/03_subquery_no_from.sql).
-- Agora: cada etapa tem um nome e a consulta principal fica curta.
-- Exemplo meu para treinar o conceito; rode e confira os resultados.
WITH pedidos_dia AS (
    SELECT DATE(order_purchase_timestamp) AS dia,
           COUNT(DISTINCT order_id)       AS pedidos,
           COUNT(DISTINCT customer_id)    AS clientes_unicos
    FROM orders
    GROUP BY DATE(order_purchase_timestamp)
),
itens_dia AS (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           AVG(oi.price)                    AS preco_medio,
           SUM(oi.price)                    AS preco_total,
           MIN(oi.price)                    AS preco_minimo
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
),
notas_dia AS (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           AVG(or2.review_score)            AS nota_media
    FROM orders o
    INNER JOIN order_reviews or2 ON or2.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
)
SELECT p.dia,
       n.nota_media,
       i.preco_medio,
       i.preco_total,
       i.preco_minimo,
       p.pedidos,
       p.clientes_unicos
FROM pedidos_dia p
LEFT JOIN itens_dia i ON i.dia = p.dia
LEFT JOIN notas_dia n ON n.dia = p.dia
ORDER BY p.dia;

-- ---------------------------------------------------------------
-- 2. [intermediário] Categoria do produto com o maior preço de venda.
-- Antes: subqueries aninhadas (veja 03_subqueries/02_subquery_no_where.sql).
-- Agora: o preço máximo ganha um nome e a consulta se lê em ordem.
WITH preco_maximo AS (
    SELECT MAX(price) AS valor
    FROM order_items
)
SELECT DISTINCT p.product_category_name
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE oi.price = (SELECT valor FROM preco_maximo);
