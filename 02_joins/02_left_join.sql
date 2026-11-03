-- 02_joins/02_left_join.sql
-- Tema: LEFT JOIN (mantém todas as linhas da tabela da esquerda)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
-- Dica: quem não tem correspondência na tabela da direita aparece com NULL;
--       "WHERE coluna_da_direita IS NULL" encontra justamente esses casos.

-- ---------------------------------------------------------------
-- 0. [básico] Validação de tamanho: LEFT JOIN entre orders e order_items.
SELECT COUNT(DISTINCT o.order_id) AS pedidos_apos_left_join
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id;
-- Resultado: 99.441 (tamanho da tabela da esquerda)

SELECT COUNT(DISTINCT o.order_id) AS pedidos_com_item
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NOT NULL;
-- Resultado: 98.666 (igual ao INNER JOIN)

-- ---------------------------------------------------------------
-- 1. [básico] Quantas formas de pagamento diferentes foram usadas em um pedido específico?
-- Consulta direta na tabela de pagamentos: não precisa de JOIN.
SELECT COUNT(DISTINCT payment_type) AS tipos_de_pagamento
FROM order_payments
WHERE order_id = 'e481f51cbdc54678b7cc49136f2d6af7';
-- Resultado: 2

-- Versão com LEFT JOIN, para ver também status e categoria do produto:
SELECT o.order_id,
       o.order_status,
       p.product_category_name,
       op.payment_type
FROM orders o
LEFT JOIN order_items oi    ON oi.order_id = o.order_id
LEFT JOIN products p        ON p.product_id = oi.product_id
LEFT JOIN order_payments op ON op.order_id = o.order_id
WHERE o.order_id = 'e481f51cbdc54678b7cc49136f2d6af7';

-- ---------------------------------------------------------------
-- 2. [intermediário] Quais pedidos têm mais de 5 produtos distintos?
SELECT o.order_id,
       COUNT(DISTINCT oi.product_id) AS produtos_distintos
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
HAVING COUNT(DISTINCT oi.product_id) > 5;
-- Resultado: 14 pedidos

-- ---------------------------------------------------------------
-- 3. [intermediário] Qual a cardinalidade entre pedidos e avaliações?
-- Procuro pedidos com mais de uma avaliação.
SELECT o.order_id,
       COUNT(or2.review_id) AS avaliacoes
FROM orders o
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
GROUP BY o.order_id
HAVING COUNT(or2.review_id) > 1;
-- Conclusão: existem pedidos com mais de uma avaliação, então a relação é 1:N.
-- Isso importa: ao unir avaliações, esses pedidos aparecem em mais de uma linha.

-- ---------------------------------------------------------------
-- 4. [intermediário] Quantos pedidos não têm nenhuma avaliação?
SELECT COUNT(*) AS pedidos_sem_avaliacao
FROM orders o
LEFT JOIN order_reviews or2 ON or2.order_id = o.order_id
WHERE or2.order_id IS NULL;
-- Resultado no meu banco: 0 (todo pedido tem avaliação).
-- Conferência: comparar COUNT(DISTINCT order_id) das duas tabelas.

-- ---------------------------------------------------------------
-- 5. [intermediário] Quais são os 10 vendedores com mais clientes distintos?
-- CORREÇÃO: COUNT(c.customer_id) conta linhas (itens), não clientes.
-- Com DISTINCT conto clientes de verdade. O filtro tira o grupo NULL dos pedidos
-- sem item, que não pertencem a nenhum vendedor.
SELECT s.seller_id,
       COUNT(DISTINCT c.customer_id) AS clientes
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN sellers s      ON s.seller_id = oi.seller_id
LEFT JOIN customer c     ON c.customer_id = o.customer_id
WHERE s.seller_id IS NOT NULL
GROUP BY s.seller_id
ORDER BY clientes DESC
LIMIT 10;
-- Obs.: no Olist, customer_id muda a cada pedido; o cliente "real" é customer_unique_id.
-- Se a tabela do curso tiver essa coluna, vale usá-la aqui.

-- ---------------------------------------------------------------
-- 6. [básico] Quantos pedidos não têm nenhum produto associado?
SELECT COUNT(DISTINCT o.order_id) AS pedidos_sem_produto
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p     ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;
-- Resultado: 775 (bate com 99.441 - 98.666 da validação de tamanho)
