# 02 - JOINs

Consultas que escrevi ao estudar uniões entre tabelas, usando as tabelas
do Olist (pedidos, itens, clientes, produtos, vendedores, pagamentos,
avaliações e geolocalização). As perguntas foram reescritas com as minhas
palavras, e cada arquivo traz o raciocínio nos comentários.

**Base:** Olist (e-commerce brasileiro) | **Banco:** SQLite, via DBeaver

## Arquivos

| Arquivo | O que pratiquei |
|---|---|
| [01_inner_join.sql](01_inner_join.sql) | INNER JOIN com 2 a 6 tabelas, filtros e validação de tamanho |
| [02_left_join.sql](02_left_join.sql) | LEFT JOIN, localização de registros sem correspondência (`IS NULL`), cardinalidade |
| [03_grande_tabela.sql](03_grande_tabela.sql) | Montagem de uma grande tabela e validação de duplicidade passo a passo |

## Os tipos de JOIN e quando usar

| JOIN | Retorna | Quando usar |
|---|---|---|
| **INNER JOIN** | Só as linhas com correspondência nas duas tabelas | Quando só importam registros completos (ex.: pedidos que têm item) |
| **LEFT JOIN** | Todas as linhas da esquerda e as correspondentes da direita (NULL se não houver) | Quando não posso perder registros da tabela principal (ex.: todos os pedidos, tenham item ou não) |
| **RIGHT JOIN** | O inverso do LEFT JOIN | Raramente necessário; basta inverter a ordem das tabelas e usar LEFT |
| **FULL OUTER JOIN** | Todas as linhas das duas tabelas, com NULL onde não há correspondência | Para comparar duas tabelas e achar o que existe só em uma delas |

> No SQLite, RIGHT e FULL JOIN só existem em versões recentes (3.39 ou mais).
> Se o DBeaver acusar erro, confira a versão do driver.

## Tamanho do resultado

- O **INNER JOIN** termina com o tamanho da menor tabela (aqui: 98.666 pedidos em vez de 99.441).
- O **LEFT JOIN** termina com o tamanho da tabela da esquerda (99.441 pedidos).
- `LEFT JOIN ... WHERE coluna_da_direita IS NULL` mostra o que não tem correspondência
  (aqui: 775 pedidos sem nenhum item).

## Antes de unir tabelas: o checklist que passei a usar

1. **Entender o negócio:** o que cada tabela representa (um pedido, um item, um pagamento).
2. **Descobrir a cardinalidade:** um pedido tem vários itens? Várias formas de pagamento?
   Mais de uma avaliação? Cada "sim" significa que o JOIN repete linhas do pedido.
3. **Validar a duplicidade depois do JOIN:** comparar `COUNT(*)` com
   `COUNT(DISTINCT order_id)` a cada tabela unida.

## Erros que cometi ou observei

1. **Contar linhas em vez de clientes:** `COUNT(c.customer_id)` conta linhas após o JOIN. Para
   contar clientes de verdade é preciso `COUNT(DISTINCT ...)`.
2. **Grupo NULL em LEFT JOIN:** pedidos sem item formam um grupo sem vendedor no `GROUP BY`.
3. **JOIN com geolocalização:** a tabela tem várias linhas por prefixo de CEP, então unir
   direto multiplica as linhas da grande tabela. O `LIMIT 20` esconde o problema; só a
   contagem mostra. Solução: resumir a tabela (uma linha por CEP) antes de unir.
4. **LIMIT sem ORDER BY:** serve para inspecionar, mas as linhas vêm em ordem imprevisível.
5. **Alias `or`:** é palavra reservada, por isso uso `or2` para `order_reviews`.
6. **Cardinalidade não é tipo de JOIN:** cardinalidade (1:1, 1:N, N:M) descreve a relação entre
   as tabelas; INNER, LEFT, RIGHT e FULL descrevem *quais linhas ficam* no resultado.
   Não são a mesma coisa.

## Próximos temas

Subqueries, colunas calculadas, window functions e CTEs.
