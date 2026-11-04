-- 07_ddl_dml/04_alterar_tabelas.sql
-- Tema: ALTER TABLE e UPDATE
-- Base: tabelas de estudo | Banco: SQLite (DBeaver)
-- Pré-requisito: rodar 01 e 02.
-- DROP COLUMN exige SQLite 3.35 ou mais; RENAME COLUMN, 3.25 ou mais.

-- ---------------------------------------------------------------
-- 1. [básico] Adicionar uma coluna. O SQLite aceita UMA coluna por comando.
ALTER TABLE Clientes ADD COLUMN idade INTEGER;
-- Para adicionar várias colunas, repita o comando:
-- ALTER TABLE Clientes ADD COLUMN telefone TEXT;
-- (No curso, o formato "ADD col1 tipo ADD col2 tipo" não funciona em nenhum dos casos.)

PRAGMA table_info(Clientes);

-- ---------------------------------------------------------------
-- 2. [básico] Renomear uma coluna.
ALTER TABLE Clientes RENAME COLUMN idade TO age;

-- ---------------------------------------------------------------
-- 3. [básico] Apagar uma coluna.
ALTER TABLE Clientes DROP COLUMN age;

-- ---------------------------------------------------------------
-- 4. [básico] Atualizar linhas com UPDATE.
-- UPDATE sem WHERE altera TODAS as linhas. Sempre confira antes com um SELECT.
SELECT * FROM Clientes WHERE cidade = 'Campinas';

UPDATE Clientes
SET email = 'ana.souza@exemplo.com'
WHERE id = 1;

-- Atualizar várias colunas de uma vez:
UPDATE Clientes
SET cidade = 'São Paulo',
    estado = 'SP'
WHERE id = 5;

SELECT * FROM Clientes;
-- Obs.: o exemplo do curso usa "WHERE state = ..." em uma tabela que não tem a coluna
-- state, o que dá erro. Criei a coluna estado na tabela de estudo.

-- ---------------------------------------------------------------
-- 5. [intermediário] UPDATE com CASE: preencher uma coluna por regra.
ALTER TABLE Clientes ADD COLUMN regiao TEXT;

UPDATE Clientes
SET regiao = CASE WHEN estado IN ('SP', 'RJ', 'MG', 'ES') THEN 'Sudeste'
                  ELSE 'Outras'
             END;

SELECT id, nome, estado, regiao FROM Clientes;
