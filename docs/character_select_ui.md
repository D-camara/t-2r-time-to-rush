# Tela de selecao da equipe

Este guia explica onde editar a tela `HEIST CREW` do menu, agora com tema de assalto ao banco.

## Onde fica

- Script principal: `scripts/ui/main_menu.gd`
- Cena do menu: `scenes/ui/main_menu.tscn`
- Assets de UI: `assets/ui/`
- Licencas dos assets: `docs/licenses/`
- Fluxo atual: lobby -> selecao -> sorteio do guarda -> arena

A tela de selecao usa os botoes que ja existem em `main_menu.tscn`, mas o visual dos cards e montado por codigo em `main_menu.gd`.
Para fontes, icones e divisores baixados, veja tambem `docs/ui_assets.md`.

## Editar nome, funcao, habilidade e cooldown

No topo de `scripts/ui/main_menu.gd`, procure:

```gdscript
const CHARACTER_CARD_DATA: Dictionary = {
```

Cada personagem tem este formato:

```gdscript
"raposa": {
	"name": "RAPOSA",
	"role": "FUGA RAPIDA",
	"skill": "+10% fuga",
	"stats": "SETOR GARAGEM\nRISCO BAIXO\nCD 30s",
	"color": Color(0.937, 0.267, 0.267, 1.0),
},
```

Campos:

- `name`: nome grande do card.
- `role`: funcao da personagem no assalto.
- `skill`: descricao curta que aparece abaixo do retrato.
- `stats`: linhas de informacao, como setor, risco, cooldown, altura ou habilidade. Use `\n` para quebrar linha.
- `color`: cor principal do personagem no card e no retrato temporario.

## Trocar os retratos temporarios por fotos ou artes

Hoje os retratos sao placeholders feitos por codigo na funcao:

```gdscript
func _add_portrait_shapes(parent: Panel, accent: Color, character_index: int) -> void:
```

Quando a equipe tiver imagens finais:

1. Coloque as imagens em uma pasta nova, por exemplo `assets/ui/characters/`.
2. Importe pelo Godot para gerar os `.import`.
3. Adicione caminhos no `CHARACTER_CARD_DATA`, por exemplo:

```gdscript
"portrait": "res://assets/ui/characters/raposa.png",
```

4. Troque a criacao de `ColorRect` em `_add_portrait_shapes()` por um `TextureRect`.
5. Configure o `TextureRect` com `expand_mode` e `stretch_mode` para preencher o espaco do portrait sem distorcer.

Sugestao de tamanho das imagens: retratos verticais ou quadrados, com boa leitura pequena. Evite fundo muito escuro se o personagem tambem for escuro.

## Ordem dos personagens

A ordem na tela vem desta constante em `main_menu.gd`:

```gdscript
const CHARACTER_IDS: Array[String] = ["sagui", "coelha", "tigre", "raposa"]
```

Se mudar a ordem aqui, confira tambem se todos os ids continuam existindo em:

- `CHARACTER_CARD_DATA`
- `systems/input/input_manager.gd`
- scripts de habilidades em `scripts/skills/`

## Cuidado ao editar

- Nao remova os botoes `SaguiButton`, `CoelhaButton`, `TigreButton` e `RaposaButton` da cena sem atualizar o array `character_buttons`.
- Nao renomeie ids como `raposa`, `tigre`, `sagui`, `coelha` sem atualizar `InputManager` e o sistema de habilidades.
- Mantenha textos curtos; cards apertados podem quebrar visualmente em resolucoes menores.
- Preserve a fantasia principal: equipe tentando fugir com o cofre aberto contra guardas/seguranca.
