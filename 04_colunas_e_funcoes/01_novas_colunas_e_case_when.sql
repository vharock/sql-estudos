-- 04_colunas_e_funcoes/01_novas_colunas_e_case_when.sql
-- Tema: criar colunas no SELECT (operações, CASE WHEN, IIF)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Colunas calculadas: valor total (preço + frete) e preço com
--    acréscimo de 10%.
SELECT oi.price,
       oi.freight_value,
       oi.price + oi.freight_value AS valor_total,
       oi.price * 1.10             AS preco_com_acrescimo_10
FROM order_items oi
LIMIT 10;

-- ---------------------------------------------------------------
-- 2. [básico] Classificar cada item como "barato" (abaixo de R$ 100) ou "caro".
SELECT oi.price,
       CASE WHEN oi.price < 100.0 THEN 'barato' ELSE 'caro' END AS classificacao
FROM order_items oi
LIMIT 10;

-- 2b. Mesmo resultado com IIF (função do SQLite; em outros bancos use CASE WHEN).
SELECT oi.price,
       IIF(oi.price < 100.0, 'barato', 'caro') AS classificacao
FROM order_items oi
LIMIT 10;

-- ---------------------------------------------------------------
-- 3. [básico] CASE WHEN com várias faixas.
-- O CASE avalia de cima para baixo e para no primeiro WHEN verdadeiro.
-- Por isso não preciso repetir o limite inferior em cada faixa.
SELECT oi.price,
       CASE WHEN oi.price < 20  THEN 'super_barato'
            WHEN oi.price < 100 THEN 'barato'
            WHEN oi.price < 180 THEN 'normal'
            ELSE 'caro'
       END AS classificacao
FROM order_items oi
LIMIT 20;
-- Cuidado: se uma faixa deixar um intervalo sem cobertura (por exemplo, usar
-- "> 150 AND < 180" e esquecer 100 a 150), esses valores caem no ELSE sem aviso.

-- ---------------------------------------------------------------
-- 4. [intermediário] Classificar cada item vendido em categorias A a E, segundo o preço:
--    abaixo de 50 = A | 50 a 100 = B | 100 a 500 = C | 500 a 1.500 = D | acima de 1.500 = E
-- Fronteiras: cada faixa inclui o limite inferior e exclui o superior,
-- exceto a D, que inclui 1.500 (o enunciado diz "acima de 1.500" para a E).
SELECT oi.product_id,
       oi.price,
       CASE WHEN oi.price < 50    THEN 'Categoria A'
            WHEN oi.price < 100   THEN 'Categoria B'
            WHEN oi.price < 500   THEN 'Categoria C'
            WHEN oi.price <= 1500 THEN 'Categoria D'
            ELSE 'Categoria E'
       END AS categoria
FROM order_items oi;
-- Obs.: classifico o preço de cada VENDA. Um mesmo produto pode cair em categorias
-- diferentes se seu preço variou ao longo do tempo.

-- ---------------------------------------------------------------
-- 5. [intermediário] Quantos itens vendidos há em cada categoria A a E?
SELECT categoria,
       COUNT(*)                  AS itens_vendidos,
       COUNT(DISTINCT product_id) AS produtos_distintos
FROM (
    SELECT oi.product_id,
           CASE WHEN oi.price < 50    THEN 'Categoria A'
                WHEN oi.price < 100   THEN 'Categoria B'
                WHEN oi.price < 500   THEN 'Categoria C'
                WHEN oi.price <= 1500 THEN 'Categoria D'
                ELSE 'Categoria E'
           END AS categoria
    FROM order_items oi
) AS faixas
GROUP BY categoria
ORDER BY categoria;
-- Obs.: a soma de produtos_distintos passa do total de produtos, porque um produto
-- pode aparecer em mais de uma faixa de preço.

-- ---------------------------------------------------------------
-- 6. [intermediário] Simulação de preços: para 9 categorias, mostrar o novo preço
--    (livros técnicos -10%, pet shop -20%, PC gamer +50%, tablets +10%,
--    fashion esporte +5%) e se a categoria foi alterada.
-- Antes: conferir o nome exato das categorias (o do fashion costuma causar erro).
SELECT DISTINCT product_category_name
FROM products
WHERE product_category_name LIKE 'fashion%'
   OR product_category_name LIKE 'tablets%'
   OR product_category_name LIKE 'pc_%';
-- IMPORTANTE: no material do curso, o CASE usa 'fashion_esports' e o IN/WHERE usa
-- 'fashion_esporte'. Com nomes diferentes, o preço do fashion não é alterado e o
-- status sai errado. Padronizo com o nome que existe na base ('fashion_esporte').
SELECT p.product_category_name,
       oi.price,
       CASE p.product_category_name
            WHEN 'livros_tecnicos'          THEN oi.price * 0.90
            WHEN 'pet_shop'                 THEN oi.price * 0.80
            WHEN 'pc_gamer'                 THEN oi.price * 1.50
            WHEN 'tablets_impressao_imagem' THEN oi.price * 1.10
            WHEN 'fashion_esporte'          THEN oi.price * 1.05
            ELSE oi.price
       END AS novo_preco,
       CASE WHEN p.product_category_name IN ('livros_tecnicos', 'pet_shop', 'pc_gamer',
                                             'tablets_impressao_imagem', 'fashion_esporte')
            THEN 'alterado'
            ELSE 'normal'
       END AS status
FROM order_items oi
INNER JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IN ('livros_tecnicos', 'pet_shop', 'pc_gamer',
                                  'tablets_impressao_imagem', 'fashion_esporte',
                                  'perfumaria', 'telefonia', 'beleza_saude',
                                  'ferramentas_jardim')
LIMIT 50;
-- Usei INNER JOIN porque o filtro está na tabela da direita (LEFT JOIN não faria diferença).

-- ---------------------------------------------------------------
-- 7. [intermediário] Status de entrega de cada pedido:
--    sem data de entrega = pendente | até 01/06/2017 = entregue | depois = programado
-- A ordem importa: o IS NULL vem primeiro, porque comparar NULL com data não é verdadeiro
-- nem falso.
SELECT o.order_id,
       o.order_delivered_customer_date,
       CASE WHEN o.order_delivered_customer_date IS NULL THEN 'pendente'
            WHEN o.order_delivered_customer_date <= '2017-06-01 00:00:00' THEN 'entregue'
            ELSE 'programado'
       END AS status_entrega
FROM orders o
LIMIT 50;
-- Obs.: "programado" é uma regra do exercício; no Olist a coluna já traz a data real
-- de entrega, então datas futuras são só entregas posteriores a 01/06/2017.
