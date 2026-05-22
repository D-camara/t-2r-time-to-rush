# Gameplay MVP por rodadas

## Estado atual implementado

- A partida tem 4 rodadas fixas.
- Em cada rodada, um jogador diferente comeca como policial inicial quando houver jogadores suficientes.
- Se houver menos de 4 jogadores, a fila de policial repete ate completar as 4 rodadas.
- Fugitivos capturados viram pegadores na mesma rodada.
- O policial vence a rodada quando todos os fugitivos sao capturados.
- Os fugitivos vencem a rodada quando o tempo acaba com pelo menos um fugitivo livre.

## Pontuacao MVP

- O policial inicial ganha 1 ponto por fugitivo capturado na rodada.
- Cada fugitivo livre quando o tempo acaba ganha 1 ponto.
- Fugitivo capturado nao ganha ponto de sobrevivencia naquela rodada.

## Fora desta etapa

Perk ativo do policial, trap colocavel e seringa de adrenalina continuam como proxima etapa. Eles devem ser implementados depois do modo de rodadas estar validado no Godot, para evitar misturar balanceamento novo com a estrutura de partida.
