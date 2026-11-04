-- 06_cte_with/01_with_basico.sql
-- Tema: cláusula WITH (CTE, Common Table Expression)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- Uma CTE é uma "tabela temporária" que existe só durante a execução da consulta.
-- Serve para organizar a consulta em etapas nomeadas, como uma subquery no FROM,
-- mas lida de cima para baixo e reutilizável dentro da mesma consulta.
--
-- Estrutura:
--   WITH nome AS ( consulta ),
--        outro_nome AS ( consulta )
--   SELECT ... FROM nome ...

-- ---------------------------------------------------------------
-- 1. [básico] Quantas parcelas cada pedido tem?
-- Obs.: um pedido pode ter mais de uma forma de pagamento (várias linhas em
-- order_payments). Somar payment_installments soma as parcelas de todas elas;
-- por isso mostro também quantas formas de pagamento o pedido usou.
WITH pagamentos AS (
    SELECT order_id,
           SUM(payment_installments) AS parcelas,
           COUNT(*)                  AS formas_de_pagamento
    FROM order_payments
    GROUP BY order_id
)
SELECT order_id,
       parcelas,
       formas_de_pagamento
FROM pagamentos
LIMIT 20;

-- ---------------------------------------------------------------
-- 2. [intermediário] Parcelas e quantidade de itens de cada pedido (duas CTEs encadeadas).
-- Cada CTE devolve UMA linha por pedido; por isso o JOIN entre elas não multiplica
-- as linhas. Esse é um dos principais usos da CTE: resumir antes de unir.
-- Obs.: no material do curso a segunda CTE se chama "products", o mesmo nome da
-- tabela real. Dentro da consulta o nome da CTE tem prioridade, o que confunde a
-- leitura. Dou nomes que não colidem.
WITH pagamentos AS (
    SELECT order_id,
           SUM(payment_installments) AS parcelas
    FROM order_payments
    GROUP BY order_id
),
itens_pedido AS (
    SELECT order_id,
           COUNT(product_id) AS itens
    FROM order_items
    GROUP BY order_id
)
SELECT pa.order_id,
       pa.parcelas,
       ip.itens
FROM pagamentos pa
INNER JOIN itens_pedido ip ON ip.order_id = pa.order_id
LIMIT 20;
-- INNER JOIN: pedidos sem item ou sem pagamento ficam de fora.
