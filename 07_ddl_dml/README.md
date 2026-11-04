# 07 - Criar, inserir, alterar e remover dados (DDL e DML)

Comandos que escrevi ao estudar como criar tabelas e modificar dados. As perguntas foram
reescritas com as minhas palavras, e cada arquivo traz o raciocínio nos comentários.

**Banco:** SQLite, via DBeaver. Tabelas de estudo criadas por mim e dados do Olist.

> **Atenção:** estes scripts criam, alteram e apagam tabelas. Rodei em um banco de estudo.
> Faça o mesmo em uma cópia do banco, e execute em blocos.

## Arquivos

| Arquivo | O que pratiquei |
|---|---|
| [01_criar_tabelas.sql](01_criar_tabelas.sql) | Modelo de esquema, tipos de dados, `CREATE TABLE`, chaves primária e estrangeira |
| [02_inserir_dados.sql](02_inserir_dados.sql) | `INSERT ... VALUES`, `INSERT ... SELECT`, cópia de segurança |
| [03_remover_dados.sql](03_remover_dados.sql) | `DELETE`, transação com `ROLLBACK`, `DROP TABLE` |
| [04_alterar_tabelas.sql](04_alterar_tabelas.sql) | `ALTER TABLE` (adicionar, renomear, apagar coluna), `UPDATE`, `UPDATE` com `CASE` |
| [05_exercicios.sql](05_exercicios.sql) | Exercícios com as tabelas `Vendas` e `Entrega` |

## DDL e DML

| Grupo | O que faz | Comandos |
|---|---|---|
| **DDL** (definição) | Cria e altera a estrutura | `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE` |
| **DML** (manipulação) | Altera os dados dentro das tabelas | `INSERT`, `UPDATE`, `DELETE` |

## DELETE, DROP e TRUNCATE

- **`DELETE FROM tabela WHERE ...`:** apaga as linhas que atendem à condição.
- **`DELETE FROM tabela`** (sem `WHERE`): apaga todas as linhas e mantém a tabela. No SQLite
  não existe `TRUNCATE`; em outros bancos ele faz esse papel.
- **`DROP TABLE tabela`:** apaga a tabela inteira, com estrutura e dados.

## Hábitos de segurança que adotei

1. **`SELECT` antes de `DELETE` ou `UPDATE`**, com o mesmo `WHERE`, para ver o que será afetado.
2. **Cópia de segurança** antes de alterar uma tabela.
3. **Transação** (`BEGIN` ... `ROLLBACK`/`COMMIT`) para testar uma alteração e desfazê-la.
4. **Conferir a quantidade afetada** com `changes()` depois do comando.
5. **`WHERE` sempre**: `UPDATE` e `DELETE` sem ele atingem a tabela inteira.
6. **Rodar em um banco de estudo**, nunca em dados de produção.

## Erros que cometi ou observei

1. **Colunas inexistentes no `INSERT`:** inserir em colunas que a tabela não tem
   (`Cidade`, `Estado`) dá erro. Conferi o esquema antes.
2. **`CREATE TABLE Vendas (name, text, price, real)`:** isso cria quatro colunas sem
   tipo. O correto é `name TEXT, price REAL`.
3. **Número guardado como texto:** filtros em uma coluna `TEXT` comparam texto
   (`'100' > '90'` é falso). Dias e preços devem ser `INTEGER` ou `REAL`.
4. **Aspas duplas para texto:** o SQLite tolera, mas, se existir uma coluna com esse nome,
   a condição vira verdadeira para todas as linhas. Texto vai entre aspas simples.
5. **Faixas que se sobrepõem:** vários `UPDATE` com `>=` e `<=` nos mesmos limites dependem
   da ordem de execução. Um único `UPDATE` com `CASE` resolve.
6. **Tipo declarado não é regra no SQLite:** uma coluna `INTEGER` aceita 29.9 e o mantém
   decimal. Para truncar, use `CAST`. Tabelas `STRICT` impõem o tipo.
7. **Tipos diferentes entre chave e referência:** `ClienteID TEXT` apontando para
   `ID INTEGER` atrapalha os JOINs.
8. **Dados pessoais em exemplos:** troquei os dados do material por dados fictícios.
9. **`ALTER TABLE` com várias colunas:** o SQLite aceita uma por comando.
10. **`UPDATE` com coluna que não existe:** o exemplo do curso filtra por `state` em uma
    tabela sem essa coluna.

## Próximos passos

Chaves e restrições (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`), `VIEW` e índices.
