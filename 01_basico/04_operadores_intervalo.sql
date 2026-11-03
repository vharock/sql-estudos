-- 01_basico/04_operadores_intervalo.sql
-- Tema: BETWEEN, IN, LIKE e HAVING
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [intermediário] Entre os pedidos de outubro de 2016 com status processing, shipped
--    ou delivered, quantos clientes únicos há por status? Mostrar só os status com
--    mais de 5 clientes.
-- CORREÇÃO: usar BETWEEN direto em um timestamp ('2016-10-31' vira
-- '2016-10-31 00:00:00') deixa de fora os pedidos feitos no dia 31 após a meia-noite.
-- Por isso comparo apenas a parte da data com DATE().
SELECT order_status,
       COUNT(DISTINCT customer_id) AS clientes_unicos
FROM orders
WHERE DATE(order_purchase_timestamp) BETWEEN '2016-10-01' AND '2016-10-31'
  AND order_status IN ('processing', 'shipped', 'delivered')
GROUP BY order_status
HAVING COUNT(DISTINCT customer_id) > 5;
-- Confira o resultado: o valor anterior (delivered 265 | shipped 8) foi obtido sem DATE().

-- ---------------------------------------------------------------
-- 2. [intermediário] Pedidos e valor total pago por número de parcelas, para 1 a 5
--    parcelas OU pagamentos acima de R$ 5.000 (versão com BETWEEN).
SELECT payment_installments,
       COUNT(order_id)    AS pedidos,
       SUM(payment_value) AS valor_total_pago
FROM order_payments
WHERE payment_installments BETWEEN 1 AND 5
   OR payment_value > 5000
GROUP BY payment_installments;

-- ---------------------------------------------------------------
-- 3. [intermediário] Em perfumaria, brinquedos, esporte e lazer e cama/mesa/banho, quantos
--    produtos têm de 5 a 10 fotos, peso fora do intervalo 1-5 g, altura acima de 10 cm
--    e largura acima de 20 cm? Mostrar só categorias com mais de 10 produtos.
SELECT product_category_name,
       COUNT(DISTINCT product_id) AS produtos_unicos
FROM products
WHERE product_category_name IN ('perfumaria', 'brinquedos', 'esporte_lazer', 'cama_mesa_banho')
  AND product_photos_qty BETWEEN 5 AND 10
  AND product_weight_g NOT BETWEEN 1 AND 5
  AND product_height_cm > 10
  AND product_width_cm > 20
GROUP BY product_category_name
HAVING COUNT(DISTINCT product_id) > 10;
-- Resultado: brinquedos 68 | cama_mesa_banho 34 | esporte_lazer 112

-- ---------------------------------------------------------------
-- 4. [intermediário] Refatoração: reescrever com IN e BETWEEN a consulta de pedidos
--    "processing"/"canceled" com entrega estimada em 2017.
-- ATENÇÃO: o original usava > e < (exclui os extremos); BETWEEN é inclusivo
-- (inclui 01/01 e 31/12). Os resultados podem diferir se houver pedidos nessas datas.
SELECT order_status,
       COUNT(order_id) AS pedidos
FROM orders
WHERE order_status IN ('processing', 'canceled')
  AND order_estimated_delivery_date BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY order_status;

-- ---------------------------------------------------------------
-- 5. [intermediário] Refatoração: cidades únicas na geolocalização de SP e RJ
--    (latitude > -24,54 e longitude < -45,63), agora com IN.
SELECT geolocation_state,
       COUNT(DISTINCT geolocation_city) AS cidades
FROM geolocation
WHERE geolocation_state IN ('SP', 'RJ')
  AND geolocation_lat > -24.54
  AND geolocation_lng < -45.63
GROUP BY geolocation_state;
-- Resultado: RJ 9 | SP 996

-- ---------------------------------------------------------------
-- 6. [intermediário] Em categorias que começam com "a" e terminam com "o", quantos
--    produtos com mais de 5 fotos? Mostrar só categorias com mais de 10 produtos.
SELECT product_category_name,
       COUNT(DISTINCT product_id) AS produtos
FROM products
WHERE product_category_name LIKE 'a%o'
  AND product_photos_qty > 5
GROUP BY product_category_name
HAVING COUNT(DISTINCT product_id) > 10;
-- Resultado: automotivo 172

-- ---------------------------------------------------------------
-- 7. [intermediário] Clientes únicos por estado e cidade, só para cidades que começam
--    com "m", têm um "o" no meio e terminam com "a". Mostrar só mais de 10 clientes.
SELECT customer_state,
       customer_city,
       COUNT(DISTINCT customer_id) AS clientes_unicos
FROM customer
WHERE customer_city LIKE 'm%o%a'
GROUP BY customer_state, customer_city
HAVING COUNT(DISTINCT customer_id) > 10;
-- Resultado: MG matias barbosa 13 | SP mairipora 75 | SP mococa 34 |
--            SP mongagua 42 | SP monte azul paulista 19
