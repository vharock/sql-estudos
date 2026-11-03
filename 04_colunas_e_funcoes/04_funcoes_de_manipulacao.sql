-- 04_colunas_e_funcoes/04_funcoes_de_manipulacao.sql
-- Tema: funções de manipulação de colunas (COALESCE, LOWER/UPPER, SUBSTR, REPLACE, ROUND)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Estes são exemplos de estudo: a apostila desta aula não trazia exercícios.
-- Rode cada consulta, confira o resultado e escreva suas próprias variações.
--
-- Atenção ao SQLite: textos devem ficar entre ASPAS SIMPLES ('texto').
-- Aspas duplas ("texto") são para nomes de colunas; o SQLite até aceita como texto
-- por tolerância, mas em outros bancos isso dá erro.

-- ---------------------------------------------------------------
-- 1. [básico] COALESCE e COUNT: quantas avaliações têm e quantas não têm título?
-- COUNT(coluna) ignora NULL; COUNT(*) conta todas as linhas.
SELECT COUNT(*)                                 AS avaliacoes,
       COUNT(review_comment_title)              AS com_titulo,
       COUNT(*) - COUNT(review_comment_title)   AS sem_titulo
FROM order_reviews;

-- ---------------------------------------------------------------
-- 2. [básico] COALESCE: substituir o título vazio por 'VAZIO' antes de concatenar.
-- Concatenar com NULL devolve NULL; com COALESCE o texto sai completo.
SELECT o.order_id,
       o.order_status,
       or2.review_comment_title,
       o.order_status || ' - ' || or2.review_comment_title                AS sem_coalesce,
       o.order_status || ' - ' || COALESCE(or2.review_comment_title, 'VAZIO') AS com_coalesce
FROM orders o
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
LIMIT 20;
-- Obs.: no material do curso, esta consulta aparece em alguns exemplos com
-- "LEFT JOIN order_reviews or2" SEM a cláusula ON. Sem o ON, o resultado vira um
-- produto cartesiano (cada pedido combinado com reviews quaisquer).

-- ---------------------------------------------------------------
-- 3. [básico] LOWER e UPPER: padronizar o texto em minúsculas e em maiúsculas.
SELECT o.order_status,
       LOWER(o.order_status || ' - ' || COALESCE(or2.review_comment_title, 'vazio')) AS texto_minusculo,
       UPPER(o.order_status || ' - ' || COALESCE(or2.review_comment_title, 'vazio')) AS texto_maiusculo
FROM orders o
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
LIMIT 20;

-- ---------------------------------------------------------------
-- 4. [básico] COALESCE para dar nome aos produtos sem categoria e contá-los.
SELECT COALESCE(product_category_name, 'sem_categoria') AS categoria,
       COUNT(*)                                          AS produtos
FROM products
GROUP BY COALESCE(product_category_name, 'sem_categoria')
ORDER BY produtos DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- 5. [básico] SUBSTR: extrair o ano e o mês de um texto de data e contar pedidos por mês.
-- O início é contado a partir de 1. SUBSTR(texto, inicio, quantidade_de_caracteres).
-- (SUBSTRING também funciona no SQLite 3.34 ou mais; SUBSTR é a forma mais comum.)
SELECT SUBSTR(order_purchase_timestamp, 1, 7) AS ano_mes,
       COUNT(*)                                AS pedidos
FROM orders
GROUP BY SUBSTR(order_purchase_timestamp, 1, 7)
ORDER BY ano_mes;
-- Equivalente com função de data: STRFTIME('%Y-%m', order_purchase_timestamp).

-- ---------------------------------------------------------------
-- 6. [básico] REPLACE: trocar os "_" dos nomes de categoria por espaço.
-- REPLACE diferencia maiúsculas de minúsculas.
SELECT DISTINCT product_category_name                       AS original,
       REPLACE(product_category_name, '_', ' ')              AS limpo
FROM products
WHERE product_category_name IS NOT NULL
LIMIT 20;

-- ---------------------------------------------------------------
-- 7. [básico] ROUND: preço do item com 0, 1 e 2 casas decimais.
SELECT oi.price,
       ROUND(oi.price, 0) AS sem_decimais,
       ROUND(oi.price, 1) AS uma_casa,
       ROUND(oi.price, 2) AS duas_casas
FROM order_items oi
LIMIT 10;

-- ---------------------------------------------------------------
-- 8. [intermediário] Combinando tudo: as 10 categorias com mais itens vendidos, com
--    nome limpo, em maiúsculas, e preço médio com 2 casas.
SELECT UPPER(REPLACE(COALESCE(p.product_category_name, 'sem_categoria'), '_', ' ')) AS categoria,
       COUNT(*)                   AS itens_vendidos,
       ROUND(AVG(oi.price), 2)    AS preco_medio
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY itens_vendidos DESC
LIMIT 10;
-- Dica: arredondar só no resultado final. Arredondar antes de somar ou calcular
-- média acumula erro.
