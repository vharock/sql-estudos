-- 02_joins/01_inner_join.sql
-- Tema: INNER JOIN (só ficam as linhas que existem nas duas tabelas)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Obs. 1: "or2" é o alias de order_reviews, porque "or" é palavra reservada.
-- Obs. 2: LIMIT sem ORDER BY devolve linhas em ordem não garantida;
--         aqui serve só para inspecionar a estrutura da tabela.

-- ---------------------------------------------------------------
-- 0. [básico] Validação de tamanho: o que acontece com a quantidade de pedidos
--    ao fazer INNER JOIN entre orders e order_items?
SELECT COUNT(DISTINCT order_id) AS pedidos_em_orders FROM orders;
SELECT COUNT(DISTINCT order_id) AS pedidos_em_order_items FROM order_items;

SELECT COUNT(DISTINCT o.order_id) AS pedidos_apos_inner_join
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id;
-- Resultado: 99.441 | 98.666 | 98.666
-- Conclusão: o INNER JOIN fica com o tamanho da menor tabela;
-- os 775 pedidos sem item somem do resultado.

-- ---------------------------------------------------------------
-- 1. [básico] 10 linhas com pedido, cliente, status, produto e preço.
SELECT o.order_id,
       o.customer_id,
       o.order_status,
       oi.product_id,
       oi.price
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
LIMIT 10;

-- ---------------------------------------------------------------
-- 2. [básico] 20 linhas com pedido, estado e cidade do cliente, status, produto
--    e preço, só para clientes de São Paulo.
SELECT o.order_id,
       c.customer_state,
       c.customer_city,
       o.order_status,
       oi.product_id,
       oi.price
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN customer c     ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP'
LIMIT 20;

-- ---------------------------------------------------------------
-- 3. [intermediário] 50 linhas de pedidos cancelados, com localização do cliente,
--    categoria do produto e preço.
-- Antes: conferir quais valores existem em order_status (o texto é 'canceled').
SELECT DISTINCT order_status FROM orders;

SELECT o.order_id,
       c.customer_state,
       c.customer_city,
       o.order_status,
       p.product_category_name,
       oi.price
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN customer c     ON c.customer_id = o.customer_id
INNER JOIN products p     ON p.product_id = oi.product_id
WHERE o.order_status = 'canceled'
LIMIT 50;

-- ---------------------------------------------------------------
-- 4. [intermediário] 80 linhas de pedidos aprovados a partir de 16/09/2016, incluindo
--    cidade e estado do vendedor.
-- CORREÇÃO: "a partir de" inclui o dia 16. Usar "> '2016-09-16 00:00:00'" exclui
-- só o instante exato da meia-noite; comparar a data com DATE() e ">=" é mais claro.
SELECT o.order_id,
       c.customer_state,
       c.customer_city,
       o.order_status,
       p.product_category_name,
       oi.price,
       s.seller_city,
       s.seller_state,
       o.order_approved_at
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN customer c     ON c.customer_id = o.customer_id
INNER JOIN products p     ON p.product_id = oi.product_id
INNER JOIN sellers s      ON s.seller_id = oi.seller_id
WHERE DATE(o.order_approved_at) >= '2016-09-16'
LIMIT 80;

-- ---------------------------------------------------------------
-- 5. [intermediário] 10 linhas da consulta anterior, com o tipo de pagamento,
--    só para pagamentos em boleto.
-- Antes: conferir os tipos de pagamento existentes.
SELECT DISTINCT payment_type FROM order_payments;

SELECT o.order_id,
       c.customer_state,
       c.customer_city,
       o.order_status,
       p.product_category_name,
       oi.price,
       s.seller_city,
       s.seller_state,
       o.order_approved_at,
       op.payment_type
FROM orders o
INNER JOIN order_items oi    ON oi.order_id = o.order_id
INNER JOIN customer c        ON c.customer_id = o.customer_id
INNER JOIN products p        ON p.product_id = oi.product_id
INNER JOIN sellers s         ON s.seller_id = oi.seller_id
INNER JOIN order_payments op ON op.order_id = o.order_id
WHERE op.payment_type = 'boleto'
LIMIT 10;
-- Atenção: um pedido pode ter mais de uma forma de pagamento (1:N),
-- então a linha do pedido pode se repetir. Veja 03_grande_tabela.sql.

-- ---------------------------------------------------------------
-- 6. [intermediário] 70 linhas incluindo a nota de avaliação, só para pedidos
--    com nota 1.
SELECT o.order_id,
       c.customer_state,
       c.customer_city,
       o.order_status,
       p.product_category_name,
       oi.price,
       s.seller_city,
       s.seller_state,
       o.order_approved_at,
       op.payment_type,
       or2.review_score
FROM orders o
INNER JOIN order_items oi    ON oi.order_id = o.order_id
INNER JOIN customer c        ON c.customer_id = o.customer_id
INNER JOIN products p        ON p.product_id = oi.product_id
INNER JOIN sellers s         ON s.seller_id = oi.seller_id
INNER JOIN order_payments op ON op.order_id = o.order_id
INNER JOIN order_reviews or2 ON or2.order_id = o.order_id
WHERE or2.review_score = 1
LIMIT 70;
