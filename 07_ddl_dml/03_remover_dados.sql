-- 07_ddl_dml/03_remover_dados.sql
-- Tema: DELETE e DROP TABLE
-- Base: tabelas de estudo | Banco: SQLite (DBeaver)
-- Pré-requisito: rodar 01 e 02. Execute em blocos, e não o arquivo inteiro de uma vez:
-- vários comandos aqui apagam dados de propósito.
--
-- Regra que sigo: antes de qualquer DELETE, rodo um SELECT com o MESMO WHERE
-- para ver quantas e quais linhas serão afetadas.

-- ---------------------------------------------------------------
-- 1. [básico] Apagar linhas específicas.
-- 1a. Conferir antes.
SELECT * FROM Clientes WHERE estado = 'RJ';
-- 1b. Apagar.
DELETE FROM Clientes
WHERE estado = 'RJ';
-- 1c. Quantas linhas foram removidas? (no SQLite)
SELECT changes() AS linhas_removidas;
-- 1d. Conferir depois.
SELECT * FROM Clientes;
-- Obs.: o exemplo do curso filtra com aspas duplas: WHERE Nome = "Texto". Se existir
-- uma coluna com esse nome, o SQLite a interpreta como coluna, e a condição
-- fica verdadeira para TODAS as linhas. Texto sempre entre aspas simples.

-- ---------------------------------------------------------------
-- 2. [intermediário] Testar um DELETE com transação e desfazer.
-- BEGIN abre uma transação; ROLLBACK desfaz tudo o que veio depois dela.
-- (No DBeaver, rode o bloco como script, com Alt+X.)
BEGIN;
DELETE FROM Clientes_olist
WHERE estado = 'SP';
SELECT COUNT(*) AS linhas_dentro_da_transacao FROM Clientes_olist;
ROLLBACK;
SELECT COUNT(*) AS linhas_depois_do_rollback FROM Clientes_olist;
-- Para confirmar a alteração em vez de desfazê-la, use COMMIT no lugar de ROLLBACK.

-- ---------------------------------------------------------------
-- 3. [básico] Apagar TODAS as linhas, mantendo a tabela.
-- No SQLite não existe TRUNCATE; usa-se DELETE sem WHERE.
-- Cuidado: sem WHERE, apaga tudo.
DELETE FROM Clientes_olist_backup;
SELECT COUNT(*) AS linhas FROM Clientes_olist_backup;

-- ---------------------------------------------------------------
-- 4. [básico] Apagar a tabela inteira (estrutura e dados).
-- Diferença: DELETE remove linhas e mantém a tabela; DROP TABLE remove a tabela.
DROP TABLE IF EXISTS Clientes_olist_backup;
