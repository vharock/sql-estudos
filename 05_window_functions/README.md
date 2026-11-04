# 05 - Window functions

Consultas que escrevi ao estudar funções de janela (`OVER`): cálculos que olham
para um grupo de linhas sem colapsá-las. As perguntas foram reescritas com as
minhas palavras, e cada arquivo traz o raciocínio nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver
> Window functions exigem SQLite 3.25 ou mais.

## Arquivos

| Arquivo | O que pratiquei |
|---|---|
| [01_agregacao_em_janelas.sql](01_agregacao_em_janelas.sql) | `AVG`, `MAX`, `MIN`, `SUM` com `OVER`, comparação com `GROUP BY`, participação no total |
| [02_ranking.sql](02_ranking.sql) | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `PERCENT_RANK`, `NTILE`, top N por grupo |
| [03_valores_deslocados.sql](03_valores_deslocados.sql) | `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE` |
| [04_tamanho_da_janela.sql](04_tamanho_da_janela.sql) | `ROWS BETWEEN`, acumulado, média móvel, janela padrão x `ROWS` |
| [05_exercicios.sql](05_exercicios.sql) | Exercícios que combinam janelas com subqueries e JOINs |

## Estrutura de uma window function

```sql
FUNCAO(coluna) OVER (
    PARTITION BY coluna_do_grupo      -- divide em grupos (opcional)
    ORDER BY coluna_de_ordem          -- ordena dentro do grupo (opcional)
    ROWS BETWEEN ... AND ...          -- define o tamanho da janela (opcional)
)
```

## GROUP BY x window function

| | GROUP BY | Window function |
|---|---|---|
| Linhas no resultado | Uma por grupo | Todas as linhas originais |
| Resultado do cálculo | Aparece uma vez por grupo | Repetido em cada linha do grupo |
| Quando usar | Resumos | Comparar cada linha com o grupo (ranking, % do total, acumulado, variação) |

## Famílias de funções

- **Agregação** (`AVG`, `SUM`, `MIN`, `MAX`, `COUNT`): totais e médias por grupo ou acumulados.
- **Ranking** (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `PERCENT_RANK`, `NTILE`): posições e faixas.
  Os três primeiros diferem nos empates: `ROW_NUMBER` nunca repete, `RANK` repete e pula,
  `DENSE_RANK` repete e não pula.
- **Valor** (`LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE`): buscam o valor de
  outra linha. `LAG` olha a linha anterior, e `LEAD` a seguinte.

## Erros que cometi ou observei

1. **`ORDER BY` muda a janela:** com `ORDER BY` dentro do `OVER`, a janela padrão vai do
   início até a linha atual. Isso transforma `MIN`, `SUM` etc. em valores acumulados.
2. **`LAST_VALUE` devolve a própria linha:** pela mesma razão. Para pegar a última linha
   do grupo, é preciso `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.
3. **Empates e janela padrão:** linhas com a mesma ordenação (itens do mesmo pedido, por
   exemplo) recebem o mesmo acumulado. `ROWS` evita isso, e uma coluna de desempate
   garante uma ordem fixa.
4. **`ROWS` conta linhas, não dias:** para uma média móvel de dias, agrego por dia antes.
5. **"Dia" que na verdade é timestamp:** agrupar pela data com hora faz o `LAG` olhar o
   segundo anterior, e não o dia anterior. Usar `DATE()` corrige.
6. **Filtro antes ou depois da janela:** o `WHERE` roda antes da janela. Um percentual "do
   total do estado" calculado depois de filtrar categorias vira percentual das categorias
   filtradas. Para filtrar depois, uso subquery.
7. **Window function no `WHERE`:** não é permitido; o filtro por posição (top N) exige
   subquery.
8. **JOINs que repetem linhas:** juntar avaliações ou pagamentos duplica itens e distorce
   médias e somas. Junto só as tabelas necessárias.
9. **Descrições erradas na teoria:** `FIRST_VALUE` e `LAST_VALUE` não são "menor" e "maior"
   valor, e sim o primeiro e o último na ordem definida.

## Próximos temas

CTEs (`WITH`) e criação e alteração de tabelas.
