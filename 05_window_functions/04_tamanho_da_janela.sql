-- 05_window_functions/04_tamanho_da_janela.sql
-- Tema: controle do tamanho da janela (ROWS BETWEEN ... PRECEDING / CURRENT ROW / FOLLOWING)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- ROWS conta LINHAS, não dias. Para uma média móvel "dos últimos 3 dias", primeiro
-- agrego as vendas por dia e depois aplico a janela sobre as linhas diárias.

-- ---------------------------------------------------------------
-- 1. [intermediário] Total de vendas por dia e total acumulado.
SELECT dia,
       vendas_dia,
       SUM(vendas_dia) OVER (ORDER BY dia
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS acumulado
FROM (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           SUM(oi.price)                    AS vendas_dia
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS diario
ORDER BY dia;

-- ---------------------------------------------------------------
-- 2. [intermediário] Média móvel de 3 dias (o dia atual e os 2 anteriores).
-- Se algum dia não tiver venda, ele não aparece na tabela, e a janela passa a cobrir
-- dias não consecutivos. Vale conferir se há lacunas.
SELECT dia,
       vendas_dia,
       AVG(vendas_dia) OVER (ORDER BY dia
                             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media_movel_3_dias
FROM (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           SUM(oi.price)                    AS vendas_dia
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS diario
ORDER BY dia;

-- ---------------------------------------------------------------
-- 3. [intermediário] Outros formatos de janela sobre as vendas diárias.
SELECT dia,
       vendas_dia,
       -- dois dias antes até o dia seguinte
       AVG(vendas_dia) OVER (ORDER BY dia ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
                                                                    AS media_janela_centrada,
       -- todo o histórico até o dia atual
       AVG(vendas_dia) OVER (ORDER BY dia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                                                                    AS media_historica
FROM (
    SELECT DATE(o.order_purchase_timestamp) AS dia,
           SUM(oi.price)                    AS vendas_dia
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE(o.order_purchase_timestamp)
) AS diario
ORDER BY dia;

-- ---------------------------------------------------------------
-- 4. [avançado] Janela padrão x ROWS quando há empates na ordenação.
-- Itens do mesmo pedido têm o mesmo timestamp. Com a janela padrão (que usa os
-- valores iguais como um bloco), todos os empates recebem o MESMO total acumulado.
-- Com ROWS, o total sobe linha a linha. Com empates, a ordem entre as linhas
-- empatadas não é garantida, então vale acrescentar uma coluna de desempate.
SELECT o.order_purchase_timestamp,
       oi.price,
       SUM(oi.price) OVER (ORDER BY o.order_purchase_timestamp)
                                                         AS acumulado_janela_padrao,
       SUM(oi.price) OVER (ORDER BY o.order_purchase_timestamp
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                                                         AS acumulado_por_linha
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
ORDER BY o.order_purchase_timestamp
LIMIT 30;
