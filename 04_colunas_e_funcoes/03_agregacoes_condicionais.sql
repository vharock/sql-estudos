-- 04_colunas_e_funcoes/03_agregacoes_condicionais.sql
-- Tema: CASE WHEN dentro de funções de agregação (SUM, AVG, MIN, MAX, COUNT)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Ideia: CASE dentro da agregação faz um segundo filtro, independente do WHERE.
-- Regra de ouro: linhas que não atendem à condição devem virar NULL (sem ELSE),
-- porque as agregações ignoram NULL. Com "ELSE 0" elas entram no cálculo como zero.

-- ---------------------------------------------------------------
-- 1. [intermediário] Por categoria: itens vendidos, preço médio, preço médio só dos
--    itens acima de R$ 100, quantidade e proporção desses itens caros.
-- Exemplo meu para treinar o conceito; rode e confira os resultados.
SELECT p.product_category_name,
       COUNT(*)                                       AS itens,
       AVG(oi.price)                                  AS preco_medio,
       AVG(CASE WHEN oi.price > 100 THEN oi.price END) AS preco_medio_dos_caros,
       COUNT(CASE WHEN oi.price > 100 THEN 1 END)     AS itens_caros,
       ROUND(100.0 * COUNT(CASE WHEN oi.price > 100 THEN 1 END) / COUNT(*), 1)
                                                      AS pct_itens_caros
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY itens DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- 2. [avançado] Média ponderada das notas de avaliação dos pedidos comprados a partir
--    de 01/01/2018, com pesos por nota:
--    nota 5 = 0,2 | 4 = 0,1 | 3 = 0,3 | 2 = 0,3 | 1 = 0,1 | 0 = 0
-- Média ponderada = soma(nota x peso) / soma(pesos).
-- Calculo o peso em uma coluna da subquery e agrego na consulta principal.
-- (A regra de pesos é do exercício: o peso depende da própria nota.)
SELECT SUM(t.review_score * t.peso) / SUM(t.peso) AS media_ponderada
FROM (
    SELECT or2.review_score,
           CASE or2.review_score
                WHEN 5 THEN 0.2
                WHEN 4 THEN 0.1
                WHEN 3 THEN 0.3
                WHEN 2 THEN 0.3
                WHEN 1 THEN 0.1
                ELSE 0.0
           END AS peso
    FROM order_reviews or2
    INNER JOIN orders o ON o.order_id = or2.order_id
    WHERE DATE(o.order_purchase_timestamp) >= '2018-01-01'
) AS t;
-- Resultado do curso: 4,2021...

-- ---------------------------------------------------------------
-- 3. [avançado] Média ponderada por mês, mesmo critério.
-- 3a. Versão do curso: agrupa pelo mês de CRIAÇÃO DA AVALIAÇÃO, enquanto o filtro
--     usa a data de COMPRA. Duas datas diferentes na mesma análise, e o mês sem ano
--     misturaria anos se a base passasse de 12 meses.
SELECT t.mes,
       SUM(t.review_score * t.peso) / SUM(t.peso) AS media_ponderada
FROM (
    SELECT STRFTIME('%m', or2.review_creation_date) AS mes,
           or2.review_score,
           CASE or2.review_score
                WHEN 5 THEN 0.2 WHEN 4 THEN 0.1 WHEN 3 THEN 0.3
                WHEN 2 THEN 0.3 WHEN 1 THEN 0.1 ELSE 0.0
           END AS peso
    FROM order_reviews or2
    INNER JOIN orders o ON o.order_id = or2.order_id
    WHERE DATE(o.order_purchase_timestamp) >= '2018-01-01'
) AS t
GROUP BY t.mes
ORDER BY t.mes;

-- 3b. Versão consistente: agrupa pelo mês de COMPRA, com o ano.
-- Os valores podem diferir da versão anterior.
SELECT t.mes,
       SUM(t.review_score * t.peso) / SUM(t.peso) AS media_ponderada
FROM (
    SELECT STRFTIME('%Y-%m', o.order_purchase_timestamp) AS mes,
           or2.review_score,
           CASE or2.review_score
                WHEN 5 THEN 0.2 WHEN 4 THEN 0.1 WHEN 3 THEN 0.3
                WHEN 2 THEN 0.3 WHEN 1 THEN 0.1 ELSE 0.0
           END AS peso
    FROM order_reviews or2
    INNER JOIN orders o ON o.order_id = or2.order_id
    WHERE DATE(o.order_purchase_timestamp) >= '2018-01-01'
) AS t
GROUP BY t.mes
ORDER BY t.mes;

-- ---------------------------------------------------------------
-- 4. [avançado] Descontos concedidos em 9 categorias. Descontos: livros técnicos 10%,
--    pet shop 20%, PC gamer 50%, tablets 90%, fashion esporte 40%; as demais não têm
--    desconto. Calcular total, média, mínimo, máximo e quantidade de itens com desconto.
-- Na subquery, "desconto" vale o valor em reais do desconto, ou NULL se a categoria
-- não tem desconto (CASE sem ELSE).
-- 4a. Total geral
SELECT SUM(desconto)   AS desconto_total,
       AVG(desconto)   AS desconto_medio,
       MIN(desconto)   AS desconto_minimo,
       MAX(desconto)   AS desconto_maximo,
       COUNT(desconto) AS itens_com_desconto
FROM (
    SELECT p.product_category_name AS categoria,
           oi.price * CASE p.product_category_name
                           WHEN 'livros_tecnicos'          THEN 0.10
                           WHEN 'pet_shop'                 THEN 0.20
                           WHEN 'pc_gamer'                 THEN 0.50
                           WHEN 'tablets_impressao_imagem' THEN 0.90
                           WHEN 'fashion_esporte'          THEN 0.40
                      END AS desconto
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IN ('livros_tecnicos', 'pet_shop', 'pc_gamer',
                                      'tablets_impressao_imagem', 'fashion_esporte',
                                      'perfumaria', 'telefonia', 'beleza_saude',
                                      'ferramentas_jardim')
) AS descontos;

-- 4b. Por categoria
SELECT categoria,
       COALESCE(SUM(desconto), 0) AS desconto_total,
       AVG(desconto)              AS desconto_medio,
       MIN(desconto)              AS desconto_minimo,
       MAX(desconto)              AS desconto_maximo,
       COUNT(desconto)            AS itens_com_desconto,
       COUNT(*)                   AS itens_vendidos
FROM (
    SELECT p.product_category_name AS categoria,
           oi.price * CASE p.product_category_name
                           WHEN 'livros_tecnicos'          THEN 0.10
                           WHEN 'pet_shop'                 THEN 0.20
                           WHEN 'pc_gamer'                 THEN 0.50
                           WHEN 'tablets_impressao_imagem' THEN 0.90
                           WHEN 'fashion_esporte'          THEN 0.40
                      END AS desconto
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IN ('livros_tecnicos', 'pet_shop', 'pc_gamer',
                                      'tablets_impressao_imagem', 'fashion_esporte',
                                      'perfumaria', 'telefonia', 'beleza_saude',
                                      'ferramentas_jardim')
) AS descontos
GROUP BY categoria;
-- Por que refiz em vez de copiar a solução do curso:
--  1. "ELSE 0" dentro de COUNT conta todas as linhas (0 também é um valor), então
--     categorias sem desconto apareciam com milhares de "itens com desconto".
--  2. "ELSE 0" dentro de AVG e MIN dilui a média e faz o mínimo ser sempre 0.
--  3. 'fashion_esports' (nome errado) fazia a categoria sumir do resultado.
-- Os números novos serão diferentes dos do curso, e isso é esperado.
