# 03 - Subqueries

Consultas que escrevi ao estudar subqueries: uma consulta dentro de outra,
usada para preparar dados antes de usá-los na consulta principal. As perguntas
foram reescritas com as minhas palavras, e cada arquivo traz o raciocínio
nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver

## Arquivos

| Arquivo | Onde a subquery entra | O que pratiquei |
|---|---|---|
| [01_subquery_no_select.sql](01_subquery_no_select.sql) | `SELECT` | Criar colunas a partir de outra tabela e de cálculos |
| [02_subquery_no_where.sql](02_subquery_no_where.sql) | `WHERE` | Filtrar com `IN`, `NOT IN` e valor único |
| [03_subquery_no_from.sql](03_subquery_no_from.sql) | `FROM` | Usar uma consulta agregada como tabela de origem |

## Onde usar cada tipo

| Posição | Para que serve | Regra principal |
|---|---|---|
| **No SELECT** | Criar uma nova coluna | Deve devolver um único valor por linha |
| **No WHERE** | Filtrar linhas a partir de outra tabela | Com `IN`, pode devolver vários valores; com `=`, só um |
| **No FROM** | Criar uma tabela intermediária (resumo) | Precisa de um alias |

## Subquery ou JOIN?

Muitas perguntas podem ser respondidas das duas formas, e os arquivos trazem
as duas versões lado a lado.

- **JOIN:** costuma ser mais rápido e mais legível quando preciso de colunas
  da outra tabela.
- **Subquery no WHERE:** boa quando só quero *filtrar* e não preciso trazer
  colunas da outra tabela (e evita linhas repetidas).
- **Subquery no FROM:** ideal para resumir uma tabela *antes* do JOIN e evitar
  que ele multiplique linhas.
- **Subquery no SELECT:** roda uma vez por linha, então uso com moderação.
- Quando as subqueries ficam aninhadas demais, a leitura piora. Na próxima
  pasta vou reescrevê-las com `WITH` (CTE).

## Erros que cometi ou observei

1. **Esquecer o GROUP BY:** `SELECT product_id, AVG(price)` sem agrupar devolve uma única
   linha, com um `product_id` qualquer. O SQLite não reclama.
2. **GROUP BY diferente do SELECT:** agrupar por estado e selecionar cidade também passa
   no SQLite, mas o resultado é enganoso. Todas as colunas sem agregação devem estar
   no GROUP BY.
3. **Código que só funciona no SQLite:** misturar `MAX()` com outra coluna funciona
   nele, mas é inválido em outros bancos. Conferi uma versão portátil.
4. **LEFT JOIN com filtro na tabela da direita:** na prática vira INNER JOIN. Escolher o
   INNER JOIN deixa a intenção clara.
5. **COUNT sem DISTINCT:** contar `order_id` depois de um JOIN conta itens, não pedidos.
6. **Tabela diária que mistura datas:** unir métricas de datas diferentes (avaliação,
   envio, compra) em uma mesma "data" confunde a leitura. Defina qual evento representa o dia.
7. **NOT IN com NULL:** se a subquery devolver um NULL, o resultado inteiro fica vazio.

## Próximos temas

Colunas calculadas, window functions e CTEs (`WITH`).
