-- 01_basico/01_agrupamentos.sql
-- Tema: GROUP BY e funções de agregação (COUNT, SUM, AVG, MIN, MAX)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Quantos clientes únicos existem em cada estado?
SELECT c.customer_state,
       COUNT(DISTINCT c.customer_id) AS numero_clientes
FROM customer c
GROUP BY c.customer_state;

-- ---------------------------------------------------------------
-- 2. [básico] Quantas cidades diferentes de clientes existem em cada estado?
SELECT customer_state,
       COUNT(DISTINCT customer_city) AS numero_cidades
FROM customer
GROUP BY customer_state;

-- ---------------------------------------------------------------
-- 3. [básico] Quantos clientes únicos existem por estado e cidade?
-- Obs.: a ordem das colunas no GROUP BY muda só a ordem de leitura,
-- não o resultado (estado, cidade) ou (cidade, estado).
SELECT c.customer_state,
       c.customer_city,
       COUNT(DISTINCT c.customer_id) AS clientes
FROM customer c
GROUP BY c.customer_state, c.customer_city;

-- ---------------------------------------------------------------
-- 4. [básico] Quantos pedidos únicos cada vendedor recebeu?
SELECT seller_id,
       COUNT(DISTINCT order_id) AS pedidos_unicos
FROM order_items
GROUP BY seller_id;

-- ---------------------------------------------------------------
-- 5. [intermediário] Perfil de cada vendedor: pedidos únicos, primeira e última
--    data limite de envio e frete mínimo, médio e máximo.
SELECT seller_id,
       COUNT(DISTINCT order_id)  AS pedidos_unicos,
       MIN(shipping_limit_date)  AS primeira_data_envio,
       MAX(shipping_limit_date)  AS ultima_data_envio,
       MIN(freight_value)        AS frete_minimo,
       AVG(freight_value)        AS frete_medio,
       MAX(freight_value)        AS frete_maximo
FROM order_items
GROUP BY seller_id;

-- ---------------------------------------------------------------
-- 6. [básico] Preço mínimo, médio e máximo de cada produto vendido.
SELECT oi.product_id,
       MIN(oi.price) AS preco_minimo,
       AVG(oi.price) AS preco_medio,
       MAX(oi.price) AS preco_maximo
FROM order_items oi
GROUP BY oi.product_id;

-- ---------------------------------------------------------------
-- 7. [básico] Quantos vendedores distintos receberam pedido e qual o preço médio geral?
-- Sem GROUP BY: o resultado é uma única linha com o total da tabela.
SELECT COUNT(DISTINCT seller_id) AS vendedores,
       AVG(price)                AS preco_medio
FROM order_items;
-- Resultado: 3.095 vendedores | preço médio ~120,65

-- ---------------------------------------------------------------
-- 8. [intermediário] Por tipo de pagamento: quantidade de pedidos, valor médio
--    e maior número de parcelas.
SELECT payment_type,
       COUNT(order_id)           AS pedidos,
       AVG(payment_value)        AS pagamento_medio,
       MAX(payment_installments) AS maior_numero_parcelas
FROM order_payments
GROUP BY payment_type;

-- ---------------------------------------------------------------
-- 9. [intermediário] Por tipo de pagamento e número de parcelas: valor mínimo,
--    máximo, médio e total pago. (Agrupamento com 2 dimensões.)
SELECT payment_type,
       payment_installments,
       MIN(payment_value) AS pagamento_minimo,
       MAX(payment_value) AS pagamento_maximo,
       AVG(payment_value) AS pagamento_medio,
       SUM(payment_value) AS pagamento_total
FROM order_payments
GROUP BY payment_type, payment_installments;

-- ---------------------------------------------------------------
-- 10. [básico] Quantos pedidos existem em cada status?
SELECT order_status,
       COUNT(order_id) AS pedidos
FROM orders
GROUP BY order_status;

-- ---------------------------------------------------------------
-- 11. [intermediário] Quantos pedidos foram aprovados por dia?
-- Atenção: pedidos sem data de aprovação (NULL) formam um grupo próprio,
-- sem data. Confira o resultado antes de usar.
SELECT DATE(order_approved_at) AS data_aprovacao,
       COUNT(order_id)         AS pedidos
FROM orders
GROUP BY DATE(order_approved_at);

-- ---------------------------------------------------------------
-- 12. [básico] Quantos produtos distintos existem em cada categoria?
SELECT product_category_name,
       COUNT(DISTINCT product_id) AS produtos
FROM products
GROUP BY product_category_name;
