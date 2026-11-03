# 01 - SQL básico

Consultas que escrevi ao estudar os fundamentos de SQL: agrupamentos,
filtros e operadores. As perguntas foram reescritas com as minhas
palavras, e cada arquivo traz o raciocínio nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver
> Algumas funções mudam em outros bancos (por exemplo, `DATE()` do SQLite
> corresponde a `CAST(... AS DATE)` no PostgreSQL ou no MySQL).

## Arquivos

| Arquivo | Tema | O que pratiquei |
|---|---|---|
| [01_agrupamentos.sql](01_agrupamentos.sql) | GROUP BY | COUNT, SUM, AVG, MIN, MAX, agrupamento com 1 e 2 dimensões |
| [02_operadores_comparacao.sql](02_operadores_comparacao.sql) | WHERE | `=`, `<>`, `>`, `<`, `>=`, `<=` com números, textos e datas |
| [03_operadores_logicos.sql](03_operadores_logicos.sql) | AND / OR | Combinação de condições e uso de parênteses |
| [04_operadores_intervalo.sql](04_operadores_intervalo.sql) | BETWEEN, IN, LIKE, HAVING | Filtros por intervalo, lista, padrão de texto e resultado agregado |
| [05_operadores_condicionais.sql](05_operadores_condicionais.sql) | IS NULL, LIMIT, ORDER BY | Valores vazios, limite e ordenação |

## O que cada tema faz e quando usar

- **GROUP BY:** funciona como uma tabela dinâmica do Excel. Toda coluna
  que aparece no SELECT sem função de agregação deve estar no GROUP BY.
- **WHERE x HAVING:** o WHERE filtra as linhas *antes* de agrupar; o HAVING
  filtra o resultado *depois* de agregar (por exemplo, `COUNT(...) > 10`).
- **AND / OR:** com os dois juntos, use parênteses para deixar claro qual
  condição pertence a qual.
- **BETWEEN:** inclui os dois extremos. Equivale a `>= ... AND <= ...`.
- **IN:** substitui vários `OR` sobre a mesma coluna.
- **LIKE:** busca padrões em texto (`'a%'` começa com "a", `'%ria'` termina com "ria").
- **IS NULL:** `= NULL` nunca funciona; use `IS NULL` ou `IS NOT NULL`.

## Erros que cometi ou observei

1. **BETWEEN com timestamp:** `BETWEEN '2016-10-01' AND '2016-10-31'` em uma coluna
   com hora deixa de fora o dia 31 depois da meia-noite. Solução: `DATE(coluna) BETWEEN ...`.
2. **Refatorar com BETWEEN não é sempre equivalente:** `> A AND < B` exclui os
   extremos, e `BETWEEN` os inclui.
3. **Esquecer o GROUP BY:** a consulta devolve uma única linha com o total geral,
   e não uma linha por grupo.
4. **Grupo NULL:** ao agrupar por uma data que tem valores vazios, aparece uma linha
   sem data, que é fácil de ignorar.
5. **Tabela errada para a pergunta:** a tabela `geolocation` não é a lista de
   vendedores; ela guarda coordenadas por CEP. Vale conferir o que cada tabela representa.

## Próximos temas

JOINs, subqueries, window functions, CTEs (`WITH`) e criação/alteração de tabelas
estão nas próximas pastas.
