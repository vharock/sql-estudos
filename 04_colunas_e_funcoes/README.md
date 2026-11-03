# 04 - Colunas e funções

Consultas que escrevi ao estudar a criação de novas colunas no `SELECT`:
operações matemáticas, condicionais (`CASE WHEN`, `IIF`), conversão de tipos,
agregações condicionais e funções de manipulação de colunas. As perguntas foram
reescritas com as minhas palavras, e cada arquivo traz o raciocínio nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver

## Arquivos

| Arquivo | O que pratiquei |
|---|---|
| [01_novas_colunas_e_case_when.sql](01_novas_colunas_e_case_when.sql) | Colunas calculadas, `CASE WHEN`, `IIF`, faixas de preço, simulação de preços, status de entrega |
| [02_tipos_e_cast.sql](02_tipos_e_cast.sql) | `PRAGMA table_info`, `typeof`, `CAST` e o efeito do tipo nos cálculos |
| [03_agregacoes_condicionais.sql](03_agregacoes_condicionais.sql) | `CASE` dentro de `SUM`, `AVG`, `MIN`, `MAX` e `COUNT`; média ponderada; descontos por categoria |
| [04_funcoes_de_manipulacao.sql](04_funcoes_de_manipulacao.sql) | `COALESCE`, `LOWER`/`UPPER`, `SUBSTR`, `REPLACE`, `ROUND` e concatenação |

## Resumo dos conceitos

- **CASE WHEN:** cria uma coluna a partir de condições. Avalia de cima para baixo e para
  no primeiro `WHEN` verdadeiro, então a ordem importa.
- **IIF:** versão curta para uma única condição, exclusiva do SQLite. `CASE WHEN`
  funciona em qualquer banco.
- **CAST:** converte o tipo de uma coluna. Converter decimal em inteiro trunca os centavos.
- **Agregação condicional:** `CASE` dentro da função de agregação faz um segundo
  filtro, independente do `WHERE`. Para a linha ser ignorada, o resultado deve ser
  `NULL` (sem `ELSE`).
- **COALESCE:** devolve o primeiro valor não vazio; serve para preencher dados faltantes.
- **LOWER / UPPER / REPLACE / SUBSTR:** padronizam e limpam texto (`SUBSTR` conta a partir de 1).
- **ROUND:** arredonda para o número de casas escolhido; é melhor aplicar no resultado final.
- **Concatenação (`||`):** se algum dos valores for `NULL`, o resultado inteiro vira `NULL`.
  Por isso uso `COALESCE` antes.

## Erros que cometi ou observei

1. **`ELSE 0` dentro de agregações:** o `COUNT` conta todas as linhas, o `AVG` dilui e o
   `MIN` vira sempre 0. Sem `ELSE`, as linhas viram `NULL` e saem do cálculo.
2. **Nome de categoria escrito de formas diferentes:** `'fashion_esports'` e
   `'fashion_esporte'` no mesmo código fizeram a categoria sumir do resultado, sem erro.
   Conferir os nomes com `SELECT DISTINCT` antes de filtrar evita isso.
3. **Faixas de `CASE` com buracos:** o intervalo que nenhuma faixa cobre cai no `ELSE`,
   sem aviso.
4. **Erros de sintaxe silenciosos ou escondidos:** vírgula antes do `FROM`, vírgula
   faltando entre duas colunas e `LEFT JOIN` sem `ON` (que vira produto cartesiano).
5. **Datas diferentes na mesma análise:** filtrar pela data de compra e agrupar pelo mês
   da avaliação mistura dois eventos. Usei o mesmo evento nos dois.
6. **Contar itens como se fossem produtos:** `COUNT(product_id)` conta vendas; para
   produtos distintos use `COUNT(DISTINCT product_id)`.
7. **`CAST` para inteiro:** trunca, não arredonda.
8. **Aspas duplas para texto:** o SQLite tolera, mas em outros bancos dá erro. Texto vai
   entre aspas simples.
9. **Concatenar com `NULL`:** o resultado é `NULL`; resolva com `COALESCE`.

## Próximos temas

Window functions, CTEs (`WITH`) e criação e alteração de tabelas.
