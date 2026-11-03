-- 01_basico/05_operadores_condicionais.sql
-- Tema: IS NULL, LIMIT e ORDER BY
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Este arquivo é um MOLDE. Rode cada consulta, confira o resultado e,
-- se possível, escreva uma variação sua antes de publicar.

-- ---------------------------------------------------------------
-- 1. [básico] Quais produtos não têm categoria cadastrada? E quantos são?
SELECT product_id, product_category_name
FROM products
WHERE product_category_name IS NULL
LIMIT 10;

SELECT COUNT(*) AS produtos_sem_categoria
FROM products
WHERE product_category_name IS NULL;
-- Dica: "= NULL" nunca funciona; para valores vazios use IS NULL / IS NOT NULL.

-- ---------------------------------------------------------------
-- 2. [básico] Quais são as 10 categorias com mais produtos?
SELECT product_category_name,
       COUNT(product_id) AS produtos
FROM products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY produtos DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- 3. [intermediário] Quais são os 5 vendedores com mais pedidos únicos
--    e qual o preço médio de cada um?
SELECT seller_id,
       COUNT(DISTINCT order_id) AS pedidos_unicos,
       AVG(price)               AS preco_medio
FROM order_items
GROUP BY seller_id
ORDER BY pedidos_unicos DESC
LIMIT 5;
