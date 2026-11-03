-- 03_subqueries/03_subquery_no_from.sql
-- Tema: subquery no FROM (cria uma tabela intermediária para a consulta principal)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Dica: toda subquery no FROM deve ter um alias (AS resumo, AS t1...).
-- O SQLite aceita sem, mas a maioria dos bancos exige.

-- ---------------------------------------------------------------
-- 1. [básico] Resumo por status de pedido: pedidos, itens, soma e média de preços.
-- A subquery agrega; a consulta principal só escolhe as colunas.
SELECT status,
       pedidos,
       itens,
       preco_total,
       preco_medio
FROM (
    SELECT o.order_status             AS status,
           COUNT(DISTINCT o.order_id) AS pedidos,
           COUNT(oi.order_id)         AS itens,
           SUM(oi.price)              AS preco_total,
           AVG(oi.price)              AS preco_medio
    FROM orders o
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_status
) AS resumo;
-- Obs.: COUNT(oi.order_id) conta ITENS, e COUNT(DISTINCT o.order_id) conta PEDIDOS.
-- São números diferentes, porque um pedido pode ter vários itens.

-- ---------------------------------------------------------------
-- 2. [intermediário] Por cidade (e estado): quantos clientes e quantos vendedores existem?
-- A subquery resume os vendedores em UMA linha por cidade/estado antes do JOIN.
-- Assim o JOIN não multiplica as linhas dos clientes.
SELECT c.customer_city,
       c.customer_state,
       COUNT(c.customer_id) AS clientes,
       se.vendedores
FROM customer c
INNER JOIN (
    SELECT seller_city,
           seller_state,
           COUNT(seller_id) AS vendedores
    FROM sellers
    GROUP BY seller_city, seller_state
) AS se ON se.seller_city  = c.customer_city
       AND se.seller_state = c.customer_state
GROUP BY c.customer_city, c.customer_state, se.vendedores;
-- Cidades de mesmo nome em estados diferentes se misturariam se eu unisse só pela cidade.

-- ---------------------------------------------------------------
-- 3. [avançado] Tabela diária com nota média das avaliações, preço médio, soma e
--    mínimo, número de pedidos e clientes únicos.
-- Versão do curso. Cada subquery agrega uma tabela por dia.
SELECT t1.date_,
       t1.avg_review,
       t2.avg_price,
       t2.sum_price,
       t2.min_price,
       t3.pedido_por_dia,
       t3.clientes_unicos
FROM (
    SELECT DATE(review_creation_date) AS date_,
           AVG(review_score)          AS avg_review
    FROM order_reviews
    GROUP BY DATE(review_creation_date)
) AS t1
LEFT JOIN (
    SELECT DATE(shipping_limit_date) AS date_,
           AVG(price)                AS avg_price,
           SUM(price)                AS sum_price,
           MIN(price)                AS min_price
    FROM order_items
    GROUP BY DATE(shipping_limit_date)
) AS t2 ON t2.date_ = t1.date_
LEFT JOIN (
    SELECT DATE(order_purchase_timestamp) AS date_,
           COUNT(order_id)                AS pedido_por_dia,
           COUNT(DISTINCT customer_id)    AS clientes_unicos
    FROM orders
    GROUP BY DATE(order_purchase_timestamp)
) AS t3 ON t3.date_ = t1.date_;
-- Limitações desta versão:
--  (a) cada subquery usa uma data diferente (criação da avaliação, limite de envio,
--      compra), então a linha de um dia mistura eventos distintos;
--  (b) o ponto de partida é a data das avaliações, então dias com compras e sem
--      avaliações ficam de fora.

-- 3b. Versão alternativa: tudo ancorado na data de compra do pedido.
SELECT t3.dia,
       t1.nota_media,
       t2.preco_medio,
       t2.preco_total,
       t2.preco_minimo,
       t3.pedidos,
       t3.clientes_unicos
FROM (
    SELECT DATE(order_purchase_timestamp) AS dia,
           COUNT(DISTINCT order_id)       AS pedidos,
           COUNT(DISTINCT customer_id)    AS clientes_unicos
    FROM orders
    GROUP BY DATE(order_purchase_timestamp)
) AS t3
LEFT JOIN (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           AVG(oi.price)                    AS preco_medio,
           SUM(oi.price)                    AS preco_total,
           MIN(oi.price)                    AS preco_minimo
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS t2 ON t2.dia = t3.dia
LEFT JOIN (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           AVG(or2.review_score)            AS nota_media
    FROM orders o
    INNER JOIN order_reviews or2 ON or2.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS t1 ON t1.dia = t3.dia
ORDER BY t3.dia;
