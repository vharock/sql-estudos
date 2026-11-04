-- 07_ddl_dml/02_inserir_dados.sql
-- Tema: INSERT (valores diretos e resultado de uma consulta)
-- Base: tabelas de estudo + Olist | Banco: SQLite (DBeaver)
-- Pré-requisito: rodar 01_criar_tabelas.sql

-- ---------------------------------------------------------------
-- 1. [básico] Inserir várias linhas com VALUES.
-- Dados fictícios. Textos entre aspas simples.
INSERT INTO Clientes (id, nome, email, cidade, estado)
VALUES
    (1, 'Ana Souza',    'ana@exemplo.com',    'Campinas',       'SP'),
    (2, 'Bruno Lima',   'bruno@exemplo.com',  'Niterói',        'RJ'),
    (3, 'Carla Dias',   'carla@exemplo.com',  'Belo Horizonte', 'MG'),
    (4, 'Diego Rocha',  'diego@exemplo.com',  'São Paulo',      'SP'),
    (5, 'Elisa Prado',  'elisa@exemplo.com',  'Santos',         'SP');

SELECT * FROM Clientes;
-- Obs.: o curso usa aspas duplas ("Texto") e dados de uma pessoa real. Usei aspas simples
-- e dados fictícios.

-- ---------------------------------------------------------------
-- 2. [intermediário] Inserir o resultado de uma consulta (INSERT ... SELECT).
-- Útil para popular tabelas novas e para criar cópias de segurança.
-- A coluna de destino precisa existir e o número de colunas do SELECT deve bater
-- com o número de colunas do INSERT.
-- Correção: o exemplo do curso insere em colunas (Cidade, Estado) que a tabela
-- Clientes não tem, e coloca um customer_id (texto) em uma coluna INTEGER.
-- Por isso criei uma tabela própria para os clientes do Olist.
DROP TABLE IF EXISTS Clientes_olist;

CREATE TABLE Clientes_olist (
    customer_id        TEXT,
    customer_unique_id TEXT,
    cidade             TEXT,
    estado             TEXT
);

INSERT INTO Clientes_olist (customer_id, customer_unique_id, cidade, estado)
SELECT c.customer_id,
       c.customer_unique_id,
       c.customer_city,
       c.customer_state
FROM customer c
ORDER BY c.customer_id      -- sem ORDER BY, o LIMIT escolhe 10 linhas arbitrárias
LIMIT 10;

SELECT * FROM Clientes_olist;

-- ---------------------------------------------------------------
-- 3. [básico] Cópia de segurança de uma tabela antes de alterá-la.
DROP TABLE IF EXISTS Clientes_olist_backup;

CREATE TABLE Clientes_olist_backup AS
SELECT * FROM Clientes_olist;
-- CREATE TABLE ... AS SELECT copia colunas e dados, mas não copia chaves nem restrições.

SELECT COUNT(*) AS linhas_na_copia FROM Clientes_olist_backup;
