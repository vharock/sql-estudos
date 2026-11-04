-- 07_ddl_dml/01_criar_tabelas.sql
-- Tema: modelo de esquema, tipos de dados e CREATE TABLE
-- Base: tabelas de estudo criadas por mim | Banco: SQLite (DBeaver)
--
-- AVISO: este arquivo CRIA e APAGA tabelas. Use um banco de estudo ou uma
-- cópia do banco do Olist. As tabelas criadas aqui (Clientes, Pedidos, Produtos)
-- têm nomes diferentes das tabelas do Olist, então não as sobrescrevem.
-- Execute em blocos, e não o arquivo inteiro de uma vez.

-- ---------------------------------------------------------------
-- 1. Tipos de dados do SQLite: NULL, INTEGER, REAL, TEXT, BLOB.
-- O SQLite não tem tipo DATE: datas são guardadas como TEXT no formato
-- 'AAAA-MM-DD' ou 'AAAA-MM-DD HH:MM:SS' (esse formato ordena e compara corretamente).

-- ---------------------------------------------------------------
-- 2. [básico] Criar três tabelas relacionadas: clientes, produtos e pedidos.
-- Boas práticas aplicadas:
--  - chave primária em cada tabela;
--  - o tipo da chave estrangeira (cliente_id) igual ao da chave que ela referencia (id);
--  - nomes de colunas sem acento e sem espaço (evita ter de usar aspas).
PRAGMA foreign_keys = ON;   -- no SQLite, a verificação de chave estrangeira precisa ser ligada

DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Produtos;
DROP TABLE IF EXISTS Clientes;

CREATE TABLE Clientes (
    id      INTEGER PRIMARY KEY,
    nome    TEXT NOT NULL,
    email   TEXT,
    cidade  TEXT,
    estado  TEXT
);

CREATE TABLE Produtos (
    id     INTEGER PRIMARY KEY,
    nome   TEXT NOT NULL,
    preco  REAL
);

CREATE TABLE Pedidos (
    id          INTEGER PRIMARY KEY,
    cliente_id  INTEGER NOT NULL,
    data        TEXT,
    total       REAL,
    FOREIGN KEY (cliente_id) REFERENCES Clientes (id)
);
-- Obs.: no material do curso, Pedidos.ClienteID é TEXT e Clientes.ID é INTEGER, e nenhuma
-- tabela tem chave primária, embora a teoria fale delas. Tipos diferentes na chave
-- e na referência atrapalham os JOINs.

-- ---------------------------------------------------------------
-- 3. [básico] Conferir as tabelas criadas.
SELECT name
FROM sqlite_schema          -- em versões antigas do SQLite: sqlite_master
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%';

-- Ver as colunas e os tipos de uma tabela:
PRAGMA table_info(Clientes);

-- ---------------------------------------------------------------
-- 4. [intermediário] Por que o tipo importa: números guardados como texto.
-- Comparar como texto é comparar caractere a caractere.
SELECT '100' > '90' AS comparacao_como_texto,    -- 0 (falso): '1' vem antes de '9'
       100  >  90   AS comparacao_como_numero;   -- 1 (verdadeiro)
-- Em uma coluna TEXT, filtros como "coluna > 90" se comportam como comparação de texto.
-- Veja o efeito no exercício 3 de 05_exercicios.sql.
