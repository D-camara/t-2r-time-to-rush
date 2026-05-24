# Asset Library UI Assets

## Button Prompts For Godot

Source: https://godotengine.org/asset-library/asset/4895

Uso no T2R:
- As texturas de botoes de controle ficam em `addons/button_prompts_for_godot/Textures/controller/`.
- O script `scripts/ui/controller_prompt_strip.gd` cria faixas com icones de controle para menu, selecao e HUD.
- Foram mantidas apenas as texturas do pacote para evitar warnings de scripts externos no Godot.

Onde editar:
- Menu e selecao: `scripts/ui/main_menu.gd`
- HUD da partida: `scripts/ui/round_hud.gd`
- Tamanho/ordem dos icones: chamadas de `set_prompts()` e `set_prompt_size()`

Prompts usados no MVP:
- `confirm`: confirmar/entrar/assinar
- `cancel`: voltar
- `start`: avancar/reiniciar
- `r1`: habilidade ativa
- `dpad`: navegacao

Se a equipe quiser trocar o visual dos botoes no futuro, substitua os PNGs em
`addons/button_prompts_for_godot/Textures/controller/` mantendo o mesmo grid de frames.
