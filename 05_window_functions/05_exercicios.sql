-- 05_window_functions/05_exercicios.sql
-- Tema: exercícios que combinam window functions, subqueries e JOINs
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [intermediário] Para cada categoria, classificar os produtos do mais caro ao mais
--    barato pelo preço médio, considerando pedidos a partir de 01/06/2018.
-- Correções em relação à versão do curso:
--  - removi o JOIN com order_reviews: ele não era usado e repetia os itens
--    (uma linha por avaliação), o que distorcia a média;
--  - troquei HAVING por WHERE para filtrar categoria vazia (HAVING serve para filtrar
--    agregações);
--  - "a partir de" inclui o dia 01/06, então uso DATE(...) >= '2018-06-01'.
SELECT categoria,
       product_id,
       preco_medio,
       DENSE_RANK() OVER (PARTITION BY categoria ORDER BY preco_medio DESC) AS classificacao
FROM (
    SELECT p.product_category_name AS categoria,
           p.product_id,
           AVG(oi.price)           AS preco_medio
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    INNER JOIN products p     ON p.product_id = oi.product_id
    WHERE DATE(o.order_purchase_timestamp) >= '2018-06-01'
      AND p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name, p.product_id
) AS produtos
ORDER BY categoria, classificacao
LIMIT 50;

-- ---------------------------------------------------------------
-- 2. [intermediário] Data da compra, valor de cada venda e total acumulado até aquela venda.
-- Janela explícita (ROWS): o total sobe a cada linha. Com a janela padrão, as vendas
-- com o mesmo timestamp (itens do mesmo pedido) receberiam o mesmo total.
-- INNER JOIN: pedidos sem item não têm valor de venda e não entram.
SELECT o.order_purchase_timestamp,
       oi.price,
       SUM(oi.price) OVER (ORDER BY o.order_purchase_timestamp
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_acumulado
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
ORDER BY o.order_purchase_timestamp
LIMIT 50;

-- ---------------------------------------------------------------
-- 3. [intermediário] Data da compra, valor de cada venda e média móvel dos 3 últimos
--    valores de venda (incluindo o atual).
-- ATENÇÃO: é uma média das últimas 3 VENDAS (linhas), e não dos últimos 3 dias.
-- A média diária está em 04_tamanho_da_janela.sql.
SELECT o.order_purchase_timestamp,
       oi.price,
       AVG(oi.price) OVER (ORDER BY o.order_purchase_timestamp
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media_movel_3_vendas
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
ORDER BY o.order_purchase_timestamp
LIMIT 50;

-- ---------------------------------------------------------------
-- 4. [avançado] Data, número de produtos vendidos e crescimento em relação ao dia anterior.
-- 4a. Versão do curso: agrupa por order_purchase_timestamp (data COM hora), então
--     o "dia anterior" é na verdade o timestamp anterior, geralmente de segundos antes.
SELECT data_venda,
       vendas,
       vendas - LAG(vendas) OVER (ORDER BY data_venda) AS crescimento
FROM (
    SELECT o.order_purchase_timestamp AS data_venda,
           COUNT(p.product_id)        AS vendas
    FROM orders o
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    LEFT JOIN products p     ON p.product_id = oi.product_id
    GROUP BY o.order_purchase_timestamp
) AS por_timestamp
ORDER BY data_venda
LIMIT 20;

-- 4b. Versão por dia: agrupa com DATE() e inclui a variação percentual.
-- NULLIF evita divisão por zero. O primeiro dia fica sem valor (não há dia anterior).
-- Se houver dias sem vendas, eles não aparecem e o "dia anterior" pode estar mais distante.
SELECT dia,
       vendas,
       vendas - LAG(vendas) OVER (ORDER BY dia) AS crescimento,
       ROUND(100.0 * (vendas - LAG(vendas) OVER (ORDER BY dia))
             / NULLIF(LAG(vendas) OVER (ORDER BY dia), 0), 1) AS crescimento_pct
FROM (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           COUNT(oi.product_id)             AS vendas
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS por_dia
ORDER BY dia;

-- ---------------------------------------------------------------
-- 5. [avançado] Por estado do cliente e categoria: produtos vendidos e percentual em
--    relação ao total vendido no estado (categorias beleza_saude e brinquedos).
-- 5a. Versão do curso: o WHERE já filtra as duas categorias, então o "total" é a soma
--     SÓ das duas, e não o total vendido no estado. O alias "total_categoria" na
--     verdade é o total do estado dentro desse filtro.
SELECT estado,
       categoria,
       produtos,
       SUM(produtos) OVER (PARTITION BY estado)                  AS total_das_duas_categorias,
       produtos * 1.0 / SUM(produtos) OVER (PARTITION BY estado) AS percentual
FROM (
    SELECT c.customer_state        AS estado,
           p.product_category_name AS categoria,
           COUNT(oi.product_id)    AS produtos
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    INNER JOIN products p     ON p.product_id = oi.product_id
    INNER JOIN customer c     ON c.customer_id = o.customer_id
    WHERE p.product_category_name IN ('beleza_saude', 'brinquedos')
    GROUP BY c.customer_state, p.product_category_name
) AS base;

-- 5b. Versão corrigida: o total do estado considera TODAS as categorias. Calculo a
-- janela sobre os grupos de todas as categorias e só depois filtro as duas.
SELECT estado,
       categoria,
       produtos,
       total_estado,
       ROUND(100.0 * produtos / total_estado, 2) AS pct_do_estado
FROM (
    SELECT c.customer_state        AS estado,
           p.product_category_name AS categoria,
           COUNT(oi.product_id)    AS produtos,
           SUM(COUNT(oi.product_id)) OVER (PARTITION BY c.customer_state) AS total_estado
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    INNER JOIN products p     ON p.product_id = oi.product_id
    INNER JOIN customer c     ON c.customer_id = o.customer_id
    GROUP BY c.customer_state, p.product_category_name
) AS base
WHERE categoria IN ('beleza_saude', 'brinquedos')
ORDER BY estado, categoria;
-- Obs.: produtos sem categoria entram no total do estado (formam um grupo próprio).
