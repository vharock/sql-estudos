-- 06_cte_with/02_with_exercicios.sql
-- Tema: exercícios com WITH
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Total de vendas (soma dos preços) por categoria.
-- Correções em relação à versão do curso: filtro de categoria vazia no WHERE
-- (HAVING serve para filtrar agregações) e INNER JOIN, já que a categoria é obrigatória.
WITH vendas_por_categoria AS (
    SELECT p.product_category_name AS categoria,
           SUM(oi.price)           AS total_vendas
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT categoria,
       total_vendas
FROM vendas_por_categoria
ORDER BY total_vendas DESC;

-- ---------------------------------------------------------------
-- 2. [intermediário] Receita por mês e o mês com a maior receita.
-- 2a. Versão do curso: agrupa só pelo número do mês ('%m') e conta produtos.
--     Dois problemas: (1) soma janeiro de 2017 com janeiro de 2018, pois não há ano;
--     (2) COUNT de produtos é quantidade vendida, e não receita.
WITH receita_por_mes AS (
    SELECT STRFTIME('%m', o.order_purchase_timestamp) AS mes,
           COUNT(oi.product_id)                       AS total_vendas
    FROM orders o
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY mes
)
SELECT mes, total_vendas
FROM receita_por_mes
WHERE total_vendas = (SELECT MAX(total_vendas) FROM receita_por_mes);

-- 2b. Versão corrigida: receita (SUM do preço) por ano e mês.
-- A CTE é lida duas vezes (na consulta principal e na subquery do MAX), sem
-- precisar repetir o código. Se houver empate, todos os meses empatados aparecem.
WITH receita_por_mes AS (
    SELECT STRFTIME('%Y-%m', o.order_purchase_timestamp) AS mes,
           SUM(oi.price)                                  AS receita
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY STRFTIME('%Y-%m', o.order_purchase_timestamp)
)
SELECT mes, receita
FROM receita_por_mes
WHERE receita = (SELECT MAX(receita) FROM receita_por_mes);

-- ---------------------------------------------------------------
-- 3. [avançado] Total de vendas por estado e por cidade, na mesma tabela.
-- Correção importante: a versão do curso agrupa a CTE de cidades só por
-- customer_city, mas seleciona também o estado. Cidades de mesmo nome em estados
-- diferentes se misturam, e o estado exibido é arbitrário. Agrupo por estado E cidade.
-- Também criei uma CTE-base com os joins, para escrevê-los uma única vez.
WITH vendas AS (
    SELECT c.customer_state AS estado,
           c.customer_city  AS cidade,
           oi.product_id
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    INNER JOIN customer c     ON c.customer_id = o.customer_id
),
vendas_por_estado AS (
    SELECT estado,
           COUNT(product_id) AS total_vendas
    FROM vendas
    GROUP BY estado
),
vendas_por_cidade AS (
    SELECT estado,
           cidade,
           COUNT(product_id) AS total_vendas
    FROM vendas
    GROUP BY estado, cidade
)
SELECT e.estado,
       c.cidade,
       e.total_vendas AS total_vendas_estado,
       c.total_vendas AS total_vendas_cidade
FROM vendas_por_estado e
INNER JOIN vendas_por_cidade c ON c.estado = e.estado
ORDER BY e.estado, c.total_vendas DESC
LIMIT 30;
-- Obs.: o join com products da versão do curso era desnecessário e foi removido.

-- ---------------------------------------------------------------
-- 4. [avançado] Para cada venda de uma categoria: preço, data limite de envio, data da
--    primeira venda da categoria e dias desde a primeira venda.
-- A CTE calcula a primeira venda com uma window function; a consulta principal usa
-- o resultado como se fosse uma tabela.
-- Obs.: CAST(... AS INTEGER) sobre a diferença de timestamps trunca as horas
-- (23 horas de diferença = 0 dias, mesmo em dias de calendário diferentes). Por isso
-- mostro também a diferença em dias corridos de calendário, usando DATE().
WITH vendas AS (
    SELECT p.product_category_name AS categoria,
           oi.price,
           oi.shipping_limit_date  AS data_limite_envio,
           FIRST_VALUE(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name
                                                     ORDER BY oi.shipping_limit_date) AS primeira_venda
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
)
SELECT categoria,
       price,
       DATE(data_limite_envio) AS data_envio,
       DATE(primeira_venda)    AS data_primeira_venda,
       CAST(JULIANDAY(data_limite_envio) - JULIANDAY(primeira_venda) AS INTEGER)
                                                          AS dias_pelo_timestamp,
       CAST(JULIANDAY(DATE(data_limite_envio)) - JULIANDAY(DATE(primeira_venda)) AS INTEGER)
                                                          AS dias_de_calendario
FROM vendas
ORDER BY categoria, data_limite_envio
LIMIT 30;
-- Alternativa mais simples para a primeira venda: MIN(oi.shipping_limit_date)
-- OVER (PARTITION BY p.product_category_name), sem ORDER BY.
-- Dei alias novos às colunas: no material do curso, "shipping_limit_date" é usado como
-- alias de uma coluna que já existe com o mesmo nome, o que pode confundir.
