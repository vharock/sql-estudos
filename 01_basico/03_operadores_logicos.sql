-- 01_basico/03_operadores_logicos.sql
-- Tema: AND, OR e uso de parênteses no WHERE
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Quantos clientes únicos há em MG e quantos no RJ?
-- Sem GROUP BY sairia uma única contagem somada dos dois estados.
SELECT customer_state,
       COUNT(DISTINCT customer_id) AS clientes_unicos
FROM customer
WHERE customer_state = 'MG' OR customer_state = 'RJ'
GROUP BY customer_state;
-- Resultado: MG 11.635 | RJ 12.852

-- ---------------------------------------------------------------
-- 2. [intermediário] Quantas cidades únicas aparecem na tabela de geolocalização,
--    em SP ou RJ, com latitude maior que -24,54 e longitude menor que -45,63?
-- Obs.: a tabela geolocation guarda CEPs/coordenadas em geral,
-- não apenas dos vendedores.
SELECT geolocation_state,
       COUNT(DISTINCT geolocation_city) AS cidades_unicas
FROM geolocation
WHERE (geolocation_state = 'SP' OR geolocation_state = 'RJ')
  AND geolocation_lat > -24.54
  AND geolocation_lng < -45.63
GROUP BY geolocation_state;
-- Resultado: RJ 9 | SP 996

-- ---------------------------------------------------------------
-- 3. [intermediário] Pedidos únicos, itens e preço médio para fretes acima de R$ 20
--    com data limite de envio em outubro de 2016.
SELECT COUNT(DISTINCT order_id) AS pedidos,
       COUNT(product_id)        AS produtos,
       AVG(price)               AS preco_medio
FROM order_items
WHERE freight_value > 20
  AND DATE(shipping_limit_date) >= '2016-10-01'
  AND DATE(shipping_limit_date) <= '2016-10-31';
-- Resultado: 103 pedidos | 117 produtos | preço médio ~229,67

-- ---------------------------------------------------------------
-- 4. [intermediário] Pedidos e valor total pago, agrupados por número de parcelas,
--    para pagamentos de 1 a 5 parcelas OU com valor acima de R$ 5.000.
SELECT payment_installments,
       COUNT(order_id)    AS pedidos,
       SUM(payment_value) AS valor_total_pago
FROM order_payments
WHERE (payment_installments >= 1 AND payment_installments <= 5)
   OR payment_value > 5000
GROUP BY payment_installments;

-- ---------------------------------------------------------------
-- 5. [intermediário] Quantos pedidos "processing" ou "canceled" têm data estimada de
--    entrega depois de 01/01/2017 OU antes de 23/11/2016?
-- Os parênteses separam o OR do status do OR das datas.
-- Sem eles, o AND e o OR se misturariam e o resultado ficaria errado.
SELECT order_status,
       COUNT(order_id) AS pedidos
FROM orders
WHERE (order_status = 'processing' OR order_status = 'canceled')
  AND (order_estimated_delivery_date > '2017-01-01'
       OR order_estimated_delivery_date < '2016-11-23')
GROUP BY order_status;
-- Resultado: canceled 611 | processing 299

-- ---------------------------------------------------------------
-- 6. [intermediário] Quantos produtos existem em perfumaria, brinquedos, esporte e lazer,
--    cama/mesa/banho e móveis de escritório, com mais de 5 fotos, peso acima de 5 g,
--    altura acima de 10 cm e largura acima de 20 cm?
SELECT product_category_name,
       COUNT(DISTINCT product_id) AS produtos
FROM products
WHERE (product_category_name = 'perfumaria'
    OR product_category_name = 'brinquedos'
    OR product_category_name = 'esporte_lazer'
    OR product_category_name = 'cama_mesa_banho'
    OR product_category_name = 'moveis_escritorio')
  AND product_photos_qty > 5
  AND product_weight_g > 5
  AND product_height_cm > 10
  AND product_width_cm > 20
GROUP BY product_category_name;
-- Resultado: brinquedos 30 | cama_mesa_banho 22 | esporte_lazer 69 |
--            moveis_escritorio 7 | perfumaria 6
