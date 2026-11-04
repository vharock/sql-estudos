-- 05_window_functions/02_ranking.sql
-- Tema: funções de ranqueamento (ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK, NTILE)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] ROW_NUMBER, RANK e DENSE_RANK lado a lado.
-- Preços iguais mostram a diferença:
--   ROW_NUMBER : 1, 2, 3, 4  (sempre únicos; empates saem em ordem arbitrária)
--   RANK       : 1, 2, 2, 4  (empate divide a posição e pula o próximo número)
--   DENSE_RANK : 1, 2, 2, 3  (empate divide a posição e não pula)
SELECT p.product_category_name,
       oi.price,
       ROW_NUMBER() OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS row_num,
       RANK()       OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS rank_,
       DENSE_RANK() OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS dense_rank_
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
ORDER BY p.product_category_name, oi.price DESC
LIMIT 40;

-- ---------------------------------------------------------------
-- 2. [intermediário] PERCENT_RANK e NTILE.
-- PERCENT_RANK vai de 0 a 1: (posição - 1) / (linhas da partição - 1).
-- NTILE(4) divide cada categoria em 4 grupos de tamanho parecido (quartis).
-- Com ORDER BY DESC, o grupo 1 reúne os itens mais caros.
SELECT p.product_category_name,
       oi.price,
       PERCENT_RANK() OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS percentil,
       NTILE(4)       OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS quartil
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
ORDER BY p.product_category_name, oi.price DESC
LIMIT 40;

-- ---------------------------------------------------------------
-- 3. [intermediário] Os 3 produtos mais caros de cada categoria.
-- Window function não pode ser usada no WHERE; por isso calculo a posição em uma
-- subquery e filtro na consulta de fora. Um produto pode aparecer em várias vendas,
-- então uso o preço máximo de cada produto antes de ranquear.
-- Exemplo meu para treinar o conceito; rode e confira os resultados.
SELECT categoria,
       product_id,
       preco_maximo,
       posicao
FROM (
    SELECT p.product_category_name AS categoria,
           oi.product_id,
           MAX(oi.price) AS preco_maximo,
           DENSE_RANK() OVER (PARTITION BY p.product_category_name
                              ORDER BY MAX(oi.price) DESC) AS posicao
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name, oi.product_id
) AS ranking
WHERE posicao <= 3
ORDER BY categoria, posicao;
