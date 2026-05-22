# Assets de UI

Este projeto usa poucos assets externos de UI para manter a apresentacao leve e facil de editar.

## Pastas

- `assets/ui/fonts/`: fontes usadas nos menus.
- `assets/ui/kenney/`: botoes, icones e divisores do Kenney UI Pack.
- `docs/licenses/`: licencas dos assets baixados.

## Assets baixados

### Kenney UI Pack

- Origem: https://kenney.nl/assets/ui-pack
- Licenca: Creative Commons Zero, CC0
- Licenca local: `docs/licenses/Kenney-UI-Pack-CC0.txt`
- Uso atual: icones dos botoes principais e divisor dos cards de personagem.

Arquivos copiados:

- `assets/ui/kenney/icon_play.png`
- `assets/ui/kenney/icon_repeat.png`
- `assets/ui/kenney/divider.png`
- `assets/ui/kenney/button_blue.png`
- `assets/ui/kenney/button_green.png`
- `assets/ui/kenney/button_red.png`
- `assets/ui/kenney/button_yellow.png`
- `assets/ui/kenney/frame_outline.png`

Nem todos os PNGs copiados estao ligados no menu ainda. Eles ficaram preparados para melhorar botoes/cards sem precisar baixar o pacote inteiro de novo.

### Press Start 2P

- Origem: Google Fonts
- Licenca: SIL Open Font License 1.1
- Licenca local: `docs/licenses/OFL-PressStart2P.txt`
- Uso atual: titulos arcade, como `TIME TO RUSH` e `HEIST CREW`.

### Kenney Future

- Origem: Kenney UI Pack
- Licenca: CC0 junto com o pacote Kenney
- Uso atual: textos menores de menu, lobby e cards.

## Como trocar visual depois

Para trocar uma fonte:

1. Coloque o arquivo `.ttf` em `assets/ui/fonts/`.
2. Atualize os `preload()` no topo de `scripts/ui/main_menu.gd`.
3. Se a fonte tiver licenca propria, coloque uma copia em `docs/licenses/`.

Para trocar icones/divisores:

1. Coloque o PNG em `assets/ui/kenney/` ou em uma pasta nova dentro de `assets/ui/`.
2. Atualize o `preload()` correspondente em `scripts/ui/main_menu.gd`.
3. Teste no Godot, porque imagens muito grandes podem distorcer se usadas dentro de `TextureRect`.

Para fotos dos personagens, use o guia:

- `docs/character_select_ui.md`

## Direcao visual atual

- Tema: assalto ao banco, cofre, alarme, seguranca e fuga.
- Menu inicial: `TIME TO RUSH` com subtitulo `ASSALTO AO BANCO // COFRE`.
- Selecao: cards de equipe com funcao, habilidade e setor do assalto.
- HUD: timer de cofre, contagem de equipe e seguranca, alerta de captura.
- Fullscreen: configurado em `project.godot` na secao `[display]`.
