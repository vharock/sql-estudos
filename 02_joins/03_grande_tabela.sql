-- 02_joins/03_grande_tabela.sql
-- Tema: montar uma "grande tabela" unindo várias tabelas e validar duplicidade
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Regra de ouro: unir tabelas pode multiplicar linhas. Depois de cada JOIN,
-- compare o número de linhas com o número de pedidos distintos.

-- ---------------------------------------------------------------
-- 1. Grande tabela (visão geral, 20 linhas)
SELECT o.order_id,
       o.order_status,
       oi.product_id,
       p.product_category_name,
       or2.review_score,
       op.payment_value,
       op.payment_type,
       s.seller_city,
       g.geolocation_lat,
       g.geolocation_lng
FROM orders o
LEFT JOIN order_items oi    ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
LEFT JOIN order_payments op ON op.order_id = o.order_id
LEFT JOIN products p        ON p.product_id = oi.product_id
LEFT JOIN sellers s         ON s.seller_id = oi.seller_id
LEFT JOIN geolocation g     ON g.geolocation_zip_code_prefix = s.seller_zip_code_prefix
LIMIT 20;

-- ---------------------------------------------------------------
-- 2. Validação de duplicidade, passo a passo
-- "linhas" maior que "pedidos" significa que o JOIN multiplicou linhas.
-- Preencha os resultados depois de rodar.

-- 2.1 Base
SELECT COUNT(*) AS linhas, COUNT(DISTINCT order_id) AS pedidos
FROM orders;

-- 2.2 + itens (esperado: aumenta, um pedido tem vários itens)
SELECT COUNT(*) AS linhas, COUNT(DISTINCT o.order_id) AS pedidos
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id;

-- 2.3 + avaliações (pedidos com mais de uma avaliação repetem linhas)
SELECT COUNT(*) AS linhas, COUNT(DISTINCT o.order_id) AS pedidos
FROM orders o
LEFT JOIN order_items oi    ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id;

-- 2.4 + pagamentos (pedidos com mais de uma forma de pagamento repetem linhas)
SELECT COUNT(*) AS linhas, COUNT(DISTINCT o.order_id) AS pedidos
FROM orders o
LEFT JOIN order_items oi    ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
LEFT JOIN order_payments op ON op.order_id = o.order_id;

-- 2.5 + vendedores e geolocalização (a tabela geolocation costuma ter várias
--     linhas por prefixo de CEP, o que multiplica as linhas)
SELECT COUNT(*) AS linhas, COUNT(DISTINCT o.order_id) AS pedidos
FROM orders o
LEFT JOIN order_items oi    ON oi.order_id = o.order_id
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
LEFT JOIN order_payments op ON op.order_id = o.order_id
LEFT JOIN sellers s         ON s.seller_id = oi.seller_id
LEFT JOIN geolocation g     ON g.geolocation_zip_code_prefix = s.seller_zip_code_prefix;

-- ---------------------------------------------------------------
-- 3. Como evitar a multiplicação pela geolocalização
-- (revisitar depois da aula de subqueries)
-- Em vez de unir a tabela geolocation direto, resumo antes: uma linha por CEP,
-- com a média das coordenadas.
SELECT s.seller_id,
       s.seller_city,
       g.lat,
       g.lng
FROM sellers s
LEFT JOIN (
    SELECT geolocation_zip_code_prefix,
           AVG(geolocation_lat) AS lat,
           AVG(geolocation_lng) AS lng
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix
) g ON g.geolocation_zip_code_prefix = s.seller_zip_code_prefix;
