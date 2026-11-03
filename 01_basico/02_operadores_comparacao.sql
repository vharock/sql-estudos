-- 01_basico/02_operadores_comparacao.sql
-- Tema: WHERE com =, <>, >, <, >=, <=
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Quantos clientes únicos moram em São Paulo?
SELECT COUNT(DISTINCT c.customer_id) AS numero_clientes
FROM customer c
WHERE c.customer_state = 'SP';
-- Resultado: 41.746

-- ---------------------------------------------------------------
-- 2. [básico] Quantos pedidos únicos foram feitos em 08/10/2016?
-- DATE() converte timestamp (data + hora) em data.
SELECT COUNT(DISTINCT order_id) AS pedidos
FROM orders
WHERE DATE(order_purchase_timestamp) = '2016-10-08';
-- Resultado: 42

-- ---------------------------------------------------------------
-- 3. [básico] Quantos pedidos únicos foram feitos depois de 08/10/2016?
-- ">" não inclui o dia 08/10.
SELECT COUNT(DISTINCT order_id) AS pedidos
FROM orders
WHERE DATE(order_purchase_timestamp) > '2016-10-08';
-- Resultado: 99.179

-- ---------------------------------------------------------------
-- 4. [básico] Quantos pedidos únicos têm data limite de envio a partir de
--    08/10/2016, incluindo esse dia?
-- ">=" inclui o dia 08/10.
SELECT COUNT(DISTINCT order_id) AS pedidos
FROM order_items
WHERE DATE(shipping_limit_date) >= '2016-10-08';
-- Resultado: 98.664

-- ---------------------------------------------------------------
-- 5. [básico] Pedidos únicos e frete médio dos itens com preço abaixo de R$ 1.100.
SELECT COUNT(DISTINCT order_id) AS pedidos_unicos,
       AVG(freight_value)       AS frete_medio
FROM order_items
WHERE price < 1100;
-- Resultado: 97.974 pedidos | frete médio ~19,73

-- ---------------------------------------------------------------
-- 6. [intermediário] Por vendedor, para itens com preço abaixo de R$ 1.100:
--    pedidos únicos, primeira e última data de envio, frete mínimo, médio e máximo.
-- Obs.: usei "<" para ficar coerente com o enunciado ("abaixo de").
SELECT oi.seller_id,
       COUNT(DISTINCT oi.order_id) AS pedidos_unicos,
       MIN(oi.shipping_limit_date) AS primeira_data_envio,
       MAX(oi.shipping_limit_date) AS ultima_data_envio,
       MIN(oi.freight_value)       AS frete_minimo,
       AVG(oi.freight_value)       AS frete_medio,
       MAX(oi.freight_value)       AS frete_maximo
FROM order_items oi
WHERE oi.price < 1100
GROUP BY oi.seller_id;
