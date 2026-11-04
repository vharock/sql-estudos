-- 05_window_functions/03_valores_deslocados.sql
-- Tema: funções de valor (LAG, LEAD, FIRST_VALUE, LAST_VALUE, NTH_VALUE)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- LAG  olha para a linha ANTERIOR (na ordem definida no OVER).
-- LEAD olha para a linha SEGUINTE.
-- Ao usar ORDER BY DESC, "anterior" e "seguinte" se invertem em relação ao tempo.
-- Aqui uso ordem crescente de data para a leitura ficar natural.

-- ---------------------------------------------------------------
-- 1. [intermediário] Para cada venda de uma categoria, a data da venda anterior e da seguinte.
SELECT p.product_category_name,
       oi.shipping_limit_date,
       LAG(oi.shipping_limit_date)  OVER (PARTITION BY p.product_category_name
                                          ORDER BY oi.shipping_limit_date) AS data_anterior,
       LEAD(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name
                                          ORDER BY oi.shipping_limit_date) AS data_seguinte
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
ORDER BY p.product_category_name, oi.shipping_limit_date
LIMIT 30;
-- A primeira linha de cada categoria não tem anterior (NULL); a última não tem seguinte.

-- ---------------------------------------------------------------
-- 2. [avançado] FIRST_VALUE e LAST_VALUE: primeira e última data de venda da categoria.
-- ARMADILHA: com ORDER BY, a janela padrão vai do início até a linha atual. Assim, o
-- LAST_VALUE devolve sempre o valor da própria linha. Para pegar a última linha da
-- categoria, é preciso ampliar a janela até o fim.
-- (O material do curso descreve FIRST_VALUE/LAST_VALUE como "menor/maior valor", mas
-- eles devolvem o primeiro/último valor NA ORDEM definida no OVER.)
SELECT p.product_category_name,
       oi.shipping_limit_date,
       FIRST_VALUE(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name
                                                 ORDER BY oi.shipping_limit_date) AS primeira_data,
       LAST_VALUE(oi.shipping_limit_date)  OVER (PARTITION BY p.product_category_name
                                                 ORDER BY oi.shipping_limit_date) AS ultima_data_errada,
       LAST_VALUE(oi.shipping_limit_date)  OVER (PARTITION BY p.product_category_name
                                                 ORDER BY oi.shipping_limit_date
                                                 ROWS BETWEEN UNBOUNDED PRECEDING
                                                          AND UNBOUNDED FOLLOWING) AS ultima_data
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
ORDER BY p.product_category_name, oi.shipping_limit_date
LIMIT 30;

-- ---------------------------------------------------------------
-- 3. [avançado] NTH_VALUE: a segunda data de venda da categoria.
-- Mesma armadilha da janela padrão: na primeira linha da categoria ainda não existe
-- uma segunda linha na janela, então o resultado é NULL.
SELECT p.product_category_name,
       oi.shipping_limit_date,
       NTH_VALUE(oi.shipping_limit_date, 2) OVER (PARTITION BY p.product_category_name
                                                  ORDER BY oi.shipping_limit_date
                                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                                           AND UNBOUNDED FOLLOWING) AS segunda_data
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
ORDER BY p.product_category_name, oi.shipping_limit_date
LIMIT 30;
