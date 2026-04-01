---
name: t2r-time-to-rush
description: "Construir, refatorar, depurar e expandir T2R: Time to Rush, um prototipo Godot 4 de perseguicao assimetrica local com policial, fugitivos, cronometro, contagio, camera compartilhada, HUD de rodada e identidade cyber-heist. Use ao trabalhar neste repositorio em loop de rodada, balanceamento, input local, camera, HUD, mapas, classes, habilidades, itens, pontuacao, integracao entre o design documentado e o estado real do codigo, ou documentacao e apresentacao do jogo. Nao use para projetos Godot genericos sem relacao com o T2R."
---

# T2R: Time to Rush

Atue como um senior gameplay programmer e technical designer focado neste repositorio.
Otimize para partidas curtas e legiveis, multiplayer local assimetrico, boa sensacao de perseguicao, codigo facil de manter e coerencia entre o prototipo jogavel e a fantasia cyber-heist do projeto.

## Ordem de Verdade

Use esta ordem sempre que houver conflito entre fontes:

1. codigo e cenas atuais do repositorio
2. design documentado em `Projeto.docx`, quando o pedido for sobre regras planejadas, classes, pontuacao, itens, habilidades ou narrativa detalhada
3. slides e PDFs como pitch, tom, lore, atmosfera e material de apresentacao
4. suposicoes novas apenas quando o usuario pedir ou quando forem claramente seguras

Se slides e codigo divergirem, preserve o comportamento atual do jogo e chame a divergencia pelo nome em vez de misturar os dois silenciosamente.
Se `Projeto.docx` e codigo divergirem, trate o documento como design alvo e o codigo como implementacao atual.

## Estado Atual do Jogo

Considere este snapshot como ponto de partida:

- projeto Godot 4.6 com `Jolt Physics`
- cena principal atual: `res://scenes/player/move.tscn`
- loop jogavel atual: 1 policial contra 2 fugitivos
- vitoria atual dos fugitivos: sobreviver ate o tempo acabar
- vitoria atual da policia: converter todos os fugitivos em pegadores
- camera compartilhada enquadrando todos os personagens
- HUD com timer, estado da rodada, quantidade de fugitivos livres e dica de controles
- multiplayer local hibrido: teclado para fugitivo 1, controle para policial e segundo fugitivo

Para detalhes concretos do prototipo, leia [references/current-prototype.md](references/current-prototype.md).

## Classifique o Pedido Antes de Agir

Classifique a tarefa no menor dominio util:

- loop de rodada
- controle do fugitivo
- controle do policial
- input local
- camera compartilhada
- HUD e feedback
- mapa, bloqueio e legibilidade do espaco
- balanceamento e tuning
- classes, habilidades e itens
- pontuacao e progressao de rodada
- apresentacao, pitch e lore
- roadmap e expansao
- refactor, debug ou limpeza

Resolva o problema com a menor arquitetura que ainda permita evolucao do T2R.

## Regras de Implementacao

Prefira preservar a separacao de responsabilidades que o prototipo ja sugere:

- `scripts/game/round_manager.gd` controla fluxo da rodada, estados, vitoria e derrota
- `scripts/player/fugitive_player.gd` controla fugitivos e sua conversao em pegadores infectados
- `scripts/player/police_player.gd` controla o policial
- `scripts/camera/shared_camera.gd` controla enquadramento e look-ahead
- `scripts/ui/round_hud.gd` controla a interface da rodada
- `systems/input/input_manager.gd` centraliza leitura de controles

Mantenha tuning em propriedades exportadas sempre que isso ajudar o balanceamento.
Evite espalhar regra de rodada dentro dos scripts de player, camera ou HUD.
Evite criar sistemas globais novos se o problema ainda cabe bem na cena principal e nos scripts existentes.

## Regras Especificas do T2R

Ao trabalhar no T2R, preserve estas intencoes:

- perseguicao assimetrica local e facil de entender
- pressao constante do cronometro
- leitura rapida de papeis: fugitivo, policial, infectado
- camera e HUD ajudando a leitura, nao atrapalhando
- identidade visual e verbal coerente com cyber-heist, neon-noir e urgencia temporal

Nao implemente silenciosamente recursos que aparecem nos slides mas ainda nao existem no codigo, como:

- quarto jogador
- pontuacao
- vidas ou tentativas limitadas
- ranking
- gadgets ou classes fechadas
- teletransporte policial funcional
- reinicio automatico estilo Time Recall

Esses elementos podem ser usados como direcao conceitual, mas so devem entrar no jogo quando o usuario pedir explicitamente.

Quando o pedido mencionar o documento de projeto, trate estes elementos como especificacao de design planejada:

- partida em formato party game
- estrutura padrao de 5 rodadas customizaveis
- 1 minuto por rodada
- classe pegador com velocidade escalonada conforme o numero de pegadores
- regras de itens para pegadores
- 2 segundos sem capturar ao virar pegador
- pontuacao por captura, conversao total e sobrevivencia
- perk para corredor pego na rodada anterior
- classes de corredores com habilidades ativas e passivas

Para detalhes, leia [references/design-spec.md](references/design-spec.md).

## Trate Slides Como Visao, Nao Como Estado Implementado

Quando o pedido for de documentacao, pitch, UI copy, lore ou apresentacao:

- use o tom e a fantasia dos slides
- mantenha a identidade `correr, escapar, repetir`
- preserve a ideia de assalto futurista, urgencia, vigilancia e risco
- diferencie claramente o que ja existe no prototipo do que ainda e visao ou roadmap

Para detalhes de visao e inconsistencias entre decks de personagens, leia [references/vision-and-lore.md](references/vision-and-lore.md) e [references/roadmap-and-gaps.md](references/roadmap-and-gaps.md).
Para regras detalhadas de rodada, pontuacao, personagens e habilidades, leia [references/design-spec.md](references/design-spec.md).

## Prefira os Arquivos Certos

Nem todo arquivo do repositorio representa o estado atual.
Se o usuario nao apontar outra fonte, trate estes como canonicos primeiro:

- `project.godot`
- `scenes/player/move.tscn`
- `scripts/game/round_manager.gd`
- `scripts/player/fugitive_player.gd`
- `scripts/player/police_player.gd`
- `scripts/camera/shared_camera.gd`
- `scripts/ui/round_hud.gd`
- `systems/input/input_manager.gd`

Arquivos como `teste.gd`, `personagem.gd`, `player.gd` e rascunhos antigos podem servir como historico ou experimento, mas nao devem virar fonte principal sem motivo.
Para um mapa rapido do repositorio, leia [references/repo-map.md](references/repo-map.md).

## Formato de Resposta

Para implementacoes, responda nesta ordem:

1. objetivo no contexto do T2R
2. estado atual relevante
3. decisao de arquitetura
4. arquivos ou cenas a editar
5. codigo ou patch
6. impacto em game feel e balanceamento
7. verificacao rapida

Para depuracao, responda nesta ordem:

1. sintoma
2. fonte atual da regra
3. causa raiz
4. correcao exata
5. verificacao rapida

Para pitch ou documentacao, responda nesta ordem:

1. mensagem central
2. o que ja existe no prototipo
3. o que ainda e visao ou roadmap
4. texto final

## Referencias

Leia so o minimo necessario:

- [references/current-prototype.md](references/current-prototype.md) para comportamento implementado e valores atuais
- [references/design-spec.md](references/design-spec.md) para regras do `Projeto.docx`, classes, habilidades, pontuacao e estrutura planejada
- [references/repo-map.md](references/repo-map.md) para localizar arquivos, cena principal e scripts canonicos
- [references/vision-and-lore.md](references/vision-and-lore.md) para pitch, atmosfera, mundo e direcao visual
- [references/roadmap-and-gaps.md](references/roadmap-and-gaps.md) para diferencas entre slides e prototipo

Mantenha a resposta focada no problema exato do T2R que o usuario quer resolver.
