# 06 - CTEs (WITH)

Consultas que escrevi ao estudar a cláusula `WITH` (Common Table Expression):
uma consulta dividida em etapas nomeadas. As perguntas foram reescritas com as
minhas palavras, e cada arquivo traz o raciocínio nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver

## Arquivos

| Arquivo | O que pratiquei |
|---|---|
| [01_with_basico.sql](01_with_basico.sql) | Uma CTE, duas CTEs encadeadas e unidas |
| [02_with_exercicios.sql](02_with_exercicios.sql) | Exercícios: total por categoria, mês com maior receita, estado e cidade, dias desde a primeira venda |
| [03_reescrevendo_subqueries_com_cte.sql](03_reescrevendo_subqueries_com_cte.sql) | Consultas com subqueries da pasta 03 reescritas com `WITH` |

## Estrutura

```sql
WITH etapa_1 AS (
    SELECT ...
),
etapa_2 AS (
    SELECT ... FROM etapa_1 ...
)
SELECT ...
FROM etapa_2;
```

## CTE, subquery e VIEW: qual a diferença?

| | O que é | Duração |
|---|---|---|
| **Subquery** | Consulta dentro de outra, sem nome próprio | Só naquela consulta |
| **CTE (`WITH`)** | Consulta com nome, escrita antes da principal | Só naquela consulta |
| **VIEW (`CREATE VIEW`)** | Consulta com nome guardada no banco | Fica salva e pode ser usada em outras consultas |

> A apostila trata `WITH` como uma "table view". São parentes, mas diferentes: a CTE
> some quando a consulta termina, e a view fica registrada no banco.

## Quando uso CTE em vez de subquery

- **Leitura em ordem:** a consulta lê de cima para baixo, em vez de "de dentro para fora".
- **Reutilização:** a mesma CTE pode ser usada várias vezes na consulta (por exemplo,
  no `MAX` do mês de maior receita), sem repetir o código.
- **Resumir antes de unir:** cada CTE com uma linha por pedido evita multiplicar linhas
  no `JOIN`.
- **Nomes que explicam:** `receita_por_mes` diz mais do que `t1`.
- Para consultas curtas e simples, uma subquery continua boa.

## Erros que cometi ou observei

1. **GROUP BY incompleto:** agrupar só por cidade e selecionar também o estado mistura
   cidades homônimas e mostra um estado arbitrário. O agrupamento deve ter as duas colunas.
2. **Mês sem ano:** `STRFTIME('%m', ...)` junta o mesmo mês de anos diferentes. Para
   uma série no tempo, uso `'%Y-%m'`.
3. **Contar quando o enunciado pede somar:** receita é `SUM(price)`; `COUNT` é quantidade.
4. **Nome da CTE igual ao da tabela:** a CTE tem prioridade e a leitura fica confusa.
5. **Diferença de datas truncada:** `CAST(... AS INTEGER)` sobre a diferença de
   timestamps descarta as horas. Para dias de calendário, comparo `DATE(...)`.
6. **Alias igual ao nome de uma coluna existente:** funciona no SQLite, mas confunde a leitura.
7. **Joins desnecessários:** juntar uma tabela que não é usada (como `products` em um
   total por estado) só deixa a consulta mais lenta.
8. **`HAVING` para filtrar coluna comum:** `HAVING` é para agregações; filtros de coluna
   vão no `WHERE`.

## Próximos temas

Criação e alteração de tabelas (`CREATE`, `INSERT`, `DELETE`, `ALTER`) e, possivelmente,
`VIEW`.
