-- 03_subqueries/01_subquery_no_select.sql
-- Tema: subquery no SELECT (cria uma nova coluna)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Regra: uma subquery no SELECT deve devolver UM único valor por linha
-- da consulta principal.

-- ---------------------------------------------------------------
-- 1. [básico] Mostrar, para 10 itens vendidos, o produto e a sua categoria,
--    buscando a categoria com uma subquery.
SELECT oi.product_id,
       (SELECT p.product_category_name
        FROM products p
        WHERE p.product_id = oi.product_id) AS categoria
FROM order_items oi
LIMIT 10;

-- 1b. Mesmo resultado com LEFT JOIN, para comparar as duas abordagens.
SELECT oi.product_id,
       p.product_category_name AS categoria
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
LIMIT 10;
-- Conclusão: o resultado é o mesmo. A subquery no SELECT roda uma vez por linha,
-- então em tabelas grandes o JOIN costuma ser mais rápido e mais fácil de ler.

-- ---------------------------------------------------------------
-- 2. [básico] Coluna calculada: preço do item, preço médio geral de todos os itens
--    e a diferença entre os dois.
SELECT oi.product_id,
       oi.price,
       (SELECT AVG(price) FROM order_items) AS preco_medio_geral,
       oi.price - (SELECT AVG(price) FROM order_items) AS diferenca
FROM order_items oi
LIMIT 10;

-- ---------------------------------------------------------------
-- 3. [intermediário] Por categoria: quantidade de produtos, comprimento médio,
--    comprimento médio da categoria "alimentos" e comprimento médio geral.
SELECT p.product_category_name,
       COUNT(p.product_id)        AS produtos,
       AVG(p.product_length_cm)   AS comprimento_medio,
       (SELECT AVG(p2.product_length_cm)
        FROM products p2
        WHERE p2.product_category_name = 'alimentos') AS comprimento_medio_alimentos,
       (SELECT AVG(p2.product_length_cm)
        FROM products p2) AS comprimento_medio_geral
FROM products p
GROUP BY p.product_category_name;
-- Obs.: produtos sem categoria (NULL) formam um grupo próprio no resultado.
-- As duas subqueries não dependem da linha principal: devolvem sempre o mesmo valor.
