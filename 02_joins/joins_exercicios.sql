
-- Arquivo: 02_joins/left_join_e_exercicios.sql
-- Tema: LEFT JOIN e análise de relacionamentos
-- Banco: SQLite (DBeaver)
-- Nível: Básico a intermediário

-- =====================================================
-- 1. Montar uma visão combinada dos pedidos
-- Objetivo: visualizar pedidos, itens, produtos,
-- pagamentos, avaliações e vendedores.
-- Atenção: múltiplos relacionamentos 1:N podem
-- multiplicar as linhas do resultado.
-- =====================================================

SELECT
    o.order_id,
    o.order_status,
    oi.product_id,
    p.product_category_name,
    r.review_score,
    op.payment_value,
    op.payment_type,
    s.seller_city
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN order_payments AS op
    ON o.order_id = op.order_id
LEFT JOIN order_reviews AS r
    ON o.order_id = r.order_id
LEFT JOIN sellers AS s
    ON oi.seller_id = s.seller_id
LIMIT 20;


-- =====================================================
-- 2. Consultar os dados de um pedido específico
-- Objetivo: visualizar seus produtos e formas de pagamento.
-- =====================================================

SELECT
    o.order_id,
    o.order_status,
    p.product_category_name,
    op.payment_type
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN order_payments AS op
    ON o.order_id = op.order_id
WHERE o.order_id = 'e481f51cbdc54678b7cc49136f2d6af7';


-- =====================================================
-- 3. Pedidos com mais de cinco produtos distintos
-- Objetivo: identificar pedidos com variedade de produtos.
-- =====================================================

SELECT
    o.order_id,
    COUNT(DISTINCT oi.product_id) AS total_produtos_distintos
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING COUNT(DISTINCT oi.product_id) > 5;


-- =====================================================
-- 4. Contar pedidos
-- Objetivo: conhecer a quantidade de pedidos distintos.
-- =====================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_pedidos
FROM orders AS o;


-- =====================================================
-- 5. Contar avaliações
-- Objetivo: conhecer a quantidade de avaliações distintas.
-- =====================================================

SELECT
    COUNT(DISTINCT review_id) AS total_avaliacoes
FROM order_reviews;


-- =====================================================
-- 6. Pedidos com mais de uma avaliação
-- Objetivo: identificar pedidos associados a múltiplas
-- avaliações.
-- =====================================================

SELECT
    o.order_id,
    COUNT(r.review_id) AS total_avaliacoes
FROM orders AS o
LEFT JOIN order_reviews AS r
    ON o.order_id = r.order_id
GROUP BY o.order_id
HAVING COUNT(r.review_id) > 1;


-- =====================================================
-- 7. Pedidos sem avaliação correspondente
-- Objetivo: encontrar pedidos sem registro em order_reviews.
-- =====================================================

SELECT
    o.order_id,
    o.order_status
FROM orders AS o
LEFT JOIN order_reviews AS r
    ON o.order_id = r.order_id
WHERE r.order_id IS NULL;


-- =====================================================
-- 8. Dez vendedores com mais clientes distintos
-- Objetivo: contar os clientes associados aos pedidos
-- que contêm itens vendidos por cada vendedor.
-- =====================================================

SELECT
    s.seller_id,
    COUNT(DISTINCT c.customer_id) AS total_clientes
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN sellers AS s
    ON oi.seller_id = s.seller_id
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY s.seller_id
ORDER BY total_clientes DESC
LIMIT 10;


-- =====================================================
-- 9. Contar itens sem correspondência na tabela products
-- Objetivo: verificar possíveis problemas de integridade.
-- =====================================================

SELECT
    COUNT(*) AS total_itens_sem_produto
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
