# Especificacao de Design

Leia este arquivo quando a tarefa vier do `Projeto.docx` ou depender de regras planejadas do jogo, personagens nomeados, habilidades, itens, pontuacao ou estrutura ideal das rodadas.

## Use Este Arquivo Para

- entender o design alvo que ainda nao esta completo no codigo
- consultar roster, habilidades e regras planejadas
- separar fantasy pitch de regra documentada
- propor expansoes futuras sem confundir com o prototipo atual

## Premissa

Depois de um grande assalto a banco, os assaltantes precisam escapar antes de serem capturados.
A policia ja cerca a area e aumenta a pressao da fuga.
Os assaltantes contam com Taime, uma cientista aliada, que possui um dispositivo experimental capaz de voltar no tempo caso todos sejam pegos.
Os policiais usam teletransporte tatico para chamar reforcos quando encostam em um assaltante.

Use essa base como fantasia de design e narrativa.
Nao assuma que tudo isso ja existe como mecanica implementada no codigo.

## O Que Nao Assumir a Partir Deste Arquivo

Nao trate estes itens como comportamento atual do jogo.
Se a tarefa for sobre o que ja funciona hoje, leia `current-prototype.md`.
Se a tarefa for sobre o que os slides vendem como tom ou direcao, leia `vision-and-lore.md`.

## Estrutura Planejada da Rodada

O documento descreve:

- formato `party game`
- 5 rodadas por padrao, customizaveis
- 1 minuto por rodada

Isso difere do prototipo atual, que hoje opera em uma rodada unica recarregada manualmente.

## Classe Pegador

Regras planejadas:

- `1 pegador -> 115% de velocidade`
- `2 pegadores -> 105% de velocidade`
- `3 pegadores -> 95% de velocidade`

Regras planejadas de itens:

- `1 pegador`: pode pegar qualquer item
- `2 pegadores`: apenas 1 pode carregar item por vez
- `3 pegadores`: itens desaparecem

Ao virar pegador:

- 2 segundos sem poder capturar

Pontuacao planejada dos pegadores:

- `+1` por captura
- `+1` bonus coletivo se converterem todos

## Classe Corredor

Regras planejadas:

- corredores por base com `100% de velocidade` sem perk
- um perk para o corredor que foi pego na rodada anterior

Pontuacao planejada quando o tempo acaba:

- `1 ou 2 sobreviventes -> 3 pontos para cada`
- `3 sobreviventes -> 4 pontos para cada`

## Familias de Personagens

O documento sugere quatro familias principais para os corredores:

- fugitivos ou sobrevivencialistas
- assaltantes de linha de frente
- vigias ou suportes
- coringas ou imprevisiveis

Ao implementar, prefira separar:

- identidade do personagem
- habilidade ativa
- habilidade passiva
- cooldown
- efeitos de estado

## Personagens e Habilidades Planejadas

### Raposa

- `Instinto de fuga` passiva: ultima viva ganha `+10%` de velocidade
- `Fuga improvisada` ativa: `+10%` de velocidade por `5s`, `cd 30s`
- `Por aqui` ativa: aliados proximos ganham `+10%` de velocidade por `5s`, `cd 1 min`

### Dragao de Komodo

- `Surpresa indesejada` ativa: counter que causa empurrao e lentidao por `5s`
- `Peste` ativa: fumaca que aplica lentidao aos policiais por `5s`
- `Sem pressa` passiva: sofre menos debuffs de lentidao

### Tigre

- `Encorajar` ativa: ele e aliados ganham resistencia a lentidao por `10s`, `cd 1 min`
- `Golpe de sorte` ativa: soco que aplica concussao e lentidao
- `Abrindo caminho` passiva: aliados proximos ganham `+5%` de velocidade por `2s` quando ele empurra ou atordoa um policial

### Rinoceronte

- `Guarda-costas` passiva: se ele e outro forem capturados ao mesmo tempo, so ele e capturado
- `Pele grossa` passiva: resiste a uma captura
- `Investida blindada` ativa: corrida curta derrubando policiais

### Sagui

- `Tecnico experiente` passiva: segura e usa equipamentos dos guardas
- `Lubrificante Industrial` ativa: cria area escorregadia para policiais
- `Montagem rapida` passiva: usar habilidade ou equipamento concede `+5%` de velocidade por `5s`

### Pica-Pau

- `Thermite` ativa: explode parede em pontos especificos, limite `2` por rodada
- `Mina inteligente` ativa: mina de proximidade que causa concussao
- `Ja me acostumei com isso` passiva: sofre menos debuffs de concussao

### Coelha

- `Pulso EMP` ativa: desativa gadgets policiais proximos
- `Drone de Invasao` ativa: hackeia dispositivo policial proximo
- `Rabbit Hole` ativa: marca ponto e se teletransporta de volta depois

### Camaleao

- `Dispositivo de invisibilidade` ativa: invisivel por `5s`
- `Presenca Fantasma` passiva: aparece menos no mapa policial
- `Sombra Enganosa` ativa: cria copia holografica que distrai o policial

## Elenco e Funcao Narrativa

Papeis narrativos importantes do documento:

- `Taime`: cientista aliada ligada ao dispositivo temporal
- `Tigre`: lider, dono do cassino As Dourado
- `Rinoceronte`: braco direito atual
- `Dragao de Komodo`: tecnico quimico
- `Sagui`: tecnico aposentado e veterano
- `Coelha`: prodigio em eletronica
- `Raposa`: ladra de rua veloz
- `Camaleao`: infiltracao e furtividade
- `Pica-Pau`: demolicoes

Use esses nomes quando a tarefa envolver pitch, documentacao, roster, UI de selecao ou habilidades.

## Inspiracoes Declaradas

O documento cita:

- `Luigi's Mansion`
- `Sneak Out`
- `Mario Party`

Use isso para orientar:

- leitura facil
- caos controlado
- partidas rapidas
- habilidades claras e memoraveis

Nao use essas referencias para justificar copiar mecanicas sem adaptacao ao T2R.
