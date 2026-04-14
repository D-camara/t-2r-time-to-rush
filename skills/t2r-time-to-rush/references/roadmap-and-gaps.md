# Roadmap e Diferencas

Leia este arquivo quando a tarefa envolver alinhamento entre o prototipo jogavel e o que os slides prometem.
Agora considere tambem o `Projeto.docx` como a especificacao mais detalhada do design alvo.

## Use Este Arquivo Para

- comparar estado atual contra design alvo
- decidir se uma mudanca preserva, aproxima ou substitui o prototipo atual
- detectar quando uma tarefa esta puxando roadmap sem pedido explicito

## Diferencas Mais Importantes

### Quantidade de jogadores

- Slides: falam em `4 jogadores`
- `Projeto.docx`: descreve estrutura de pegador e corredores, com pontuacao para ate `3 sobreviventes`
- Codigo atual: implementa `1 policial + 2 fugitivos`

### Duracao da rodada

- Slides: mencionam `2 a 3 minutos por rodada`
- `Projeto.docx`: define `1 minuto por rodada`, em `5 rodadas` por padrao
- Codigo atual: usa `45 segundos`

### Encerramento quando todos sao pegos

- Slides: sugerem fantasia de `Time Recall`, com nova tentativa
- `Projeto.docx`: reforca explicitamente a ideia de voltar no tempo quando todos sao pegos
- Codigo atual: declara vitoria da policia e pede `R` para reiniciar

### Papel do policial

- Slides: deixam a leitura de `um pegador`
- `Projeto.docx`: fala em teletransporte tatico e reforcos policiais ao encostar no alvo
- Codigo atual: fugitivos capturados viram `pegadores infectados`

### Sistemas planejados

Slides e `Projeto.docx` citam como planejado, mas ainda nao implementado:

- pontuacao
- ranking
- vidas ou tentativas
- modos mais longos
- expansao do sistema base de tempo
- classes por personagem
- habilidades ativas e passivas
- itens e restricoes por numero de pegadores
- perks por rodada anterior

## Como Falar Disso para o Usuario

Ao propor mudancas, seja explicito:

- `estado atual`: o que funciona hoje
- `visao`: o que os slides desejam
- `decisao`: se a tarefa vai preservar, aproximar ou substituir o prototipo atual

## Mudancas que Merecem Confirmacao

Pare para alinhar antes de mudar:

- numero de jogadores
- condicao de reinicio automatico
- remocao do sistema de contagio
- adicao de pontuacao, vidas ou ranking
- aumento drastico do tempo de rodada

## Nao Use Este Arquivo Para

- descobrir valores exatos do prototipo atual
- localizar scripts ou cenas
- detalhar roster, habilidades ou lore

Para comportamento atual, leia `current-prototype.md`.
Para localizar arquivos, leia `repo-map.md`.
Para regras planejadas, leia `design-spec.md`.
