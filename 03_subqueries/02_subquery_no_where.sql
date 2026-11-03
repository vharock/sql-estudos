-- 03_subqueries/02_subquery_no_where.sql
-- Tema: subquery no WHERE (filtra a consulta principal a partir de outra tabela)
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)

-- ---------------------------------------------------------------
-- 1. [básico] Preço médio dos itens de pedidos já entregues.
SELECT AVG(oi.price) AS preco_medio
FROM order_items oi
WHERE oi.order_id IN (SELECT o.order_id
                      FROM orders o
                      WHERE o.order_status = 'delivered');

-- 1b. Mesmo resultado com INNER JOIN.
SELECT AVG(oi.price) AS preco_medio
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- ---------------------------------------------------------------
-- 2. [básico] Preço médio de cada produto, só para produtos das categorias
--    perfumaria e artes.
-- Atenção: sem GROUP BY a consulta devolveria uma única linha, com um product_id
-- qualquer ao lado da média geral. Como quero uma média por produto, agrupo.
SELECT oi.product_id,
       AVG(oi.price) AS preco_medio
FROM order_items oi
WHERE oi.product_id IN (SELECT p.product_id
                        FROM products p
                        WHERE p.product_category_name IN ('perfumaria', 'artes'))
GROUP BY oi.product_id;

-- ---------------------------------------------------------------
-- 3. [básico] Quantos pedidos foram pagos com boleto?
SELECT COUNT(o.order_id) AS pedidos
FROM orders o
WHERE o.order_id IN (SELECT DISTINCT op.order_id
                     FROM order_payments op
                     WHERE op.payment_type = 'boleto');
-- Resultado: 19.784

-- 3b. Mesma pergunta com JOIN.
-- Dois cuidados: (1) com filtro na tabela da direita, LEFT JOIN vira INNER JOIN na
-- prática, então uso INNER JOIN; (2) um pedido pode ter vários pagamentos em boleto,
-- então conto pedidos distintos.
SELECT COUNT(DISTINCT o.order_id) AS pedidos
FROM orders o
INNER JOIN order_payments op ON op.order_id = o.order_id
WHERE op.payment_type = 'boleto';
-- Resultado: 19.784 (mesmo valor da subquery)

-- ---------------------------------------------------------------
-- 4. [avançado] Qual a categoria do produto com o maior preço de venda?
--    Resolver somente com subqueries.
-- Versão do curso (subqueries aninhadas). Funciona no SQLite porque, em uma consulta
-- com MAX(), ele devolve as outras colunas da linha do máximo. Em outros bancos
-- esse SELECT é inválido.
SELECT p.product_category_name
FROM products p
WHERE p.product_id = (
    SELECT product_id
    FROM (
        SELECT product_id,
               MAX(max_product) AS max_all
        FROM (
            SELECT product_id,
                   MAX(price) AS max_product
            FROM order_items
            GROUP BY product_id
        )
    )
);

-- 4b. Versão portátil (funciona em qualquer banco) e que não perde empates.
SELECT p.product_category_name
FROM products p
WHERE p.product_id IN (SELECT oi.product_id
                       FROM order_items oi
                       WHERE oi.price = (SELECT MAX(price) FROM order_items));

-- ---------------------------------------------------------------
-- 5. [intermediário] Bônus: quais produtos nunca foram vendidos?
-- Molde meu: rode, confira e escreva a sua variação.
SELECT p.product_id,
       p.product_category_name
FROM products p
WHERE p.product_id NOT IN (SELECT oi.product_id FROM order_items oi)
LIMIT 20;
-- Cuidado com NOT IN: se a subquery devolver algum NULL, a consulta inteira
-- retorna vazio. Aqui product_id não é nulo, mas vale conferir.
