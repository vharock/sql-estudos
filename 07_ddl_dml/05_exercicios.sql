-- 07_ddl_dml/05_exercicios.sql
-- Tema: exercícios que combinam CREATE, INSERT ... SELECT, DELETE, ALTER e UPDATE
-- Base: Olist e-commerce | Banco: SQLite (DBeaver)
--
-- AVISO: use um banco de estudo ou uma cópia do banco do Olist. Estes exercícios
-- criam e apagam as tabelas Vendas e Entrega. Execute em blocos.

-- ---------------------------------------------------------------
-- 1. [intermediário] Criar a tabela Vendas e preenchê-la com o total de vendas por
--    categoria (resultado de uma consulta com WITH).
-- Correção: o curso cria "CREATE TABLE Vendas (name, text, price, real)", o que gera
-- QUATRO colunas sem tipo, chamadas name, text, price e real. A forma certa é
-- "name TEXT, price REAL".
DROP TABLE IF EXISTS Vendas;

CREATE TABLE Vendas (
    name  TEXT,
    price REAL
);

INSERT INTO Vendas (name, price)
WITH vendas_por_categoria AS (
    SELECT p.product_category_name AS name,
           SUM(oi.price)           AS preco
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT name, preco
FROM vendas_por_categoria;

SELECT * FROM Vendas ORDER BY price DESC;

-- ---------------------------------------------------------------
-- 2. [básico] Apagar da tabela Vendas as linhas com preço menor que 500.000.
SELECT COUNT(*) AS linhas_a_apagar FROM Vendas WHERE price < 500000;

DELETE FROM Vendas
WHERE price < 500000;

SELECT changes() AS linhas_removidas;
SELECT * FROM Vendas;

-- ---------------------------------------------------------------
-- 3. [avançado] Passo a passo com a tabela Entrega.
-- 3.1 Criar a tabela. Atenção ao tipo de days_from_first_purchase.
-- O curso usa TEXT para os dias. Com TEXT, filtros como "days_from_first_purchase > 90"
-- comparam texto: '100' > '90' é FALSO. O DELETE removeria as linhas erradas.
-- Aqui uso INTEGER.
DROP TABLE IF EXISTS Entrega;

CREATE TABLE Entrega (
    category                 TEXT,
    price                    REAL,
    shipping                 TEXT,
    first_purchase_date      TEXT,
    days_from_first_purchase INTEGER
);

-- 3.2 e 3.3 Consulta (categoria, preço, data limite de envio, primeira venda da categoria
-- e dias desde a primeira venda) inserida na tabela.
INSERT INTO Entrega (category, price, shipping, first_purchase_date, days_from_first_purchase)
WITH vendas AS (
    SELECT p.product_category_name AS categoria,
           oi.price,
           oi.shipping_limit_date  AS data_limite_envio,
           FIRST_VALUE(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name
                                                     ORDER BY oi.shipping_limit_date) AS primeira_venda
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
)
SELECT categoria,
       price,
       DATE(data_limite_envio),
       DATE(primeira_venda),
       CAST(JULIANDAY(DATE(data_limite_envio)) - JULIANDAY(DATE(primeira_venda)) AS INTEGER)
FROM vendas;

SELECT COUNT(*) AS linhas_inseridas FROM Entrega;
SELECT typeof(days_from_first_purchase) AS tipo, COUNT(*) FROM Entrega GROUP BY 1;

-- 3.4 e 3.5 Remover as linhas com preço > 29,90 e mais de 90 dias, e contar quantas saíram.
SELECT COUNT(*) AS antes FROM Entrega;
SELECT COUNT(*) AS a_remover FROM Entrega
WHERE price > 29.90 AND days_from_first_purchase > 90;

DELETE FROM Entrega
WHERE price > 29.90 AND days_from_first_purchase > 90;

SELECT changes() AS linhas_removidas;
SELECT COUNT(*) AS depois FROM Entrega;

-- 3.6 Apagar a tabela.
DROP TABLE Entrega;

-- 3.7 Recriar a tabela com price INTEGER.
CREATE TABLE Entrega (
    category                 TEXT,
    price                    INTEGER,
    shipping                 TEXT,
    first_purchase_date      TEXT,
    days_from_first_purchase INTEGER
);

-- 3.8 Inserir novamente o resultado da consulta.
INSERT INTO Entrega (category, price, shipping, first_purchase_date, days_from_first_purchase)
WITH vendas AS (
    SELECT p.product_category_name AS categoria,
           oi.price,
           oi.shipping_limit_date  AS data_limite_envio,
           FIRST_VALUE(oi.shipping_limit_date) OVER (PARTITION BY p.product_category_name
                                                     ORDER BY oi.shipping_limit_date) AS primeira_venda
    FROM order_items oi
    INNER JOIN products p ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL
)
SELECT categoria,
       price,
       DATE(data_limite_envio),
       DATE(primeira_venda),
       CAST(JULIANDAY(DATE(data_limite_envio)) - JULIANDAY(DATE(primeira_venda)) AS INTEGER)
FROM vendas;

-- Observação importante: no SQLite, "INTEGER" é uma preferência, não uma regra.
-- Um valor como 29.9 continua sendo guardado como decimal. Confira:
SELECT typeof(price) AS tipo, COUNT(*) FROM Entrega GROUP BY 1;
-- Para realmente truncar os centavos, é preciso CAST(price AS INTEGER) no INSERT.
-- (Tabelas STRICT, do SQLite 3.37 ou mais, impõem o tipo declarado.)

-- 3.9 Remover as linhas com preço < 29,90 e menos de 90 dias.
SELECT COUNT(*) AS a_remover FROM Entrega
WHERE price < 29.90 AND days_from_first_purchase < 90;

DELETE FROM Entrega
WHERE price < 29.90 AND days_from_first_purchase < 90;

SELECT changes() AS linhas_removidas;

-- ---------------------------------------------------------------
-- 4. [intermediário] Adicionar a coluna desconto na tabela Vendas e preenchê-la por faixa de preço:
--    abaixo de 300 = 10,90 | de 300 a 5.000 = 11,90 | de 5.000 a 20.000 = 12,90 |
--    de 20.000 a 60.000 = 13,90 | acima de 60.000 = 15,90
-- Correções: (a) o enunciado do curso escreve "maior que 6000" na última faixa, mas as
-- faixas anteriores vão até 60.000; usei 60.000. (b) a solução do curso usa vários
-- UPDATEs com >= e <= que se sobrepõem em 5.000, 20.000 e 60.000, e o resultado
-- depende da ordem de execução. Com um único UPDATE e CASE, cada valor cai em uma só faixa.
-- Regra de fronteira que adotei: cada faixa inclui o limite inferior.
-- (Se você apagou linhas no exercício 2, refaça o exercício 1 antes.)
ALTER TABLE Vendas ADD COLUMN desconto REAL;

UPDATE Vendas
SET desconto = CASE WHEN price < 300   THEN 10.90
                    WHEN price < 5000  THEN 11.90
                    WHEN price < 20000 THEN 12.90
                    WHEN price < 60000 THEN 13.90
                    ELSE 15.90
               END;

-- Conferir: nenhuma linha deve ficar sem desconto.
SELECT COUNT(*) AS sem_desconto FROM Vendas WHERE desconto IS NULL;
SELECT name, price, desconto FROM Vendas ORDER BY price;
