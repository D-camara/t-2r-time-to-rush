# Time To Rush (T2R)

Um jogo de estratégia e ação em 3D desenvolvido em **Godot 4.6**, onde os jogadores controlam diferentes personagens com habilidades únicas para completar objetivos e escapar de perseguidores.

## 🎮 Sobre o Projeto

Time To Rush é um jogo multiplayer cooperativo que combina elementos de stealth, ação e estratégia. Os jogadores devem trabalhar juntos para completar objetivos de extração enquanto evitam ser capturados por caçadores.

### Características Principais

- **Sistema de Habilidades Dinâmico**: Cada personagem possui habilidades únicas (Extraction, Assaltante, Sagui, etc.)
- **Múltiplos Mapas**: Ambientes diversos incluindo zonas de extração, heliponto e colis
- **Inimigos Inteligentes**: Sistema de captura de caçadores com IA de navegação
- **UI Interativa**: Menu principal, sistema de navegação e HUD em tempo real
- **Física Realista**: Utiliza Jolt Physics engine para simulações precisas
- **Sistema de Câmera Avançado**: Câmera dinâmica que acompanha o gameplay

## 🚀 Começando

### Pré-requisitos

- **Godot 4.6** ou superior
- Windows 11 (ou compatível com Vulkan/D3D12)
- Git para controle de versão

### Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd t-2r-time-to-rush
```

2. **Abra o projeto no Godot**
   - Abra o Godot Engine 4.6
   - Selecione "Open Project" e aponte para o diretório do projeto
   - Aguarde o Godot importar os assets

3. **Configuração Inicial**
   - O projeto usa D3D12 no Windows (veja `project.godot`)
   - InputManager está configurado como autoload
   - Cena principal: `res://scenes/ui/main_menu.tscn`

4. **Execute o Projeto**
   - Clique em "Run" ou pressione `F5`
   - O jogo iniciará no menu principal

## 📁 Estrutura do Projeto

```
t-2r-time-to-rush/
├── addons/                    # Extensões do Godot
│   └── button_prompts_for_godot/
├── assets/                    # Recursos do jogo (texturas, modelos, etc)
├── docs/                      # Documentação adicional
├── scenes/                    # Cenas do Godot (.tscn)
│   ├── ui/                    # Interface do usuário
│   │   └── main_menu.tscn     # Menu principal
│   ├── game/                  # Cenas de gameplay
│   ├── player/                # Cenas dos personagens jogáveis
│   ├── enemies/               # Cenas dos inimigos
│   ├── skills/                # Cenas das habilidades
│   ├── maps/                  # Cenas dos mapas
│   ├── props/                 # Adereços e objetos do mundo
│   └── MAPADEFINITIVO.tscn    # Mapa principal definitivo
├── scripts/                   # Scripts GDScript
│   ├── player/                # Lógica do jogador
│   ├── enemies/               # Lógica dos inimigos
│   ├── skills/                # Sistema de habilidades
│   ├── game/                  # Lógica de gameplay
│   ├── camera/                # Sistema de câmera
│   └── input_manager.gd       # Gerenciador de entrada
├── systems/                   # Sistemas globais
│   └── input/                 # Sistema de entrada
├── skills/                    # Definições de skills
├── project.godot              # Configuração do projeto Godot
└── AGENTS.md                  # Instruções para agentes IA
```

## 🎯 Branches Principais

- **main**: Branch de produção (versão estável)
- **mvp-dia**: Branch de desenvolvimento MVP em progresso

## 🎮 Gameplay

### Objetivos
- Completar objetivos de extração
- Evitar ser capturado pelos caçadores
- Usar as habilidades de forma estratégica

### Controles
- **WASD**: Movimento do personagem
- **Mouse**: Câmera
- **Espaço**: Pular/Ação (sujeito a mudanças conforme o desenvolvimento)
- *Mais controles serão adicionados conforme o desenvolvimento avança*

## 🛠️ Desenvolvido Com

- **Engine**: Godot 4.6 (Forward Plus Rendering)
- **Physics**: Jolt Physics
- **Linguagem**: GDScript
- **Renderização**: D3D12 (Windows)

## 📊 Recursos Principais

### Mapas Disponíveis
- **MAPADEFINITIVO.tscn** - Mapa principal definitivo
- **MAPAQSEDEF.tscn** - Mapa em desenvolvimento
- **mapacheli.tscn** - Zona de heliponto
- **mapacolis.tscn** - Zona de colis
- Outros mapas temáticos em desenvolvimento

### Sistema de Habilidades
- Extraction
- Assaltante
- Sagui
- Sistema extensível para novos personagens

### Gerenciamento de Entrada
O projeto utiliza um sistema centralizado de input (`InputManager`) para:
- Mapeamento de controles
- Detecção de ações
- Suporte a múltiplos dispositivos

## 🐛 Desenvolvimento Recente

### Últimos Commits
- Fix: Extraction, Assaltante, Sagui skill
- Atualização de branches
- Remove helipad access colliders and keep extraction zone
- Implementação de heliponto
- Cores da HUD

## 🤝 Como Contribuir

1. Crie uma branch a partir de `main`: `git checkout -b feature/sua-feature`
2. Faça suas alterações
3. Commit suas mudanças: `git commit -m "feat: descrição da feature"`
4. Push para a branch: `git push origin feature/sua-feature`
5. Abra um Pull Request

### Convenção de Commits
- `feat:` - Nova feature
- `fix:` - Correção de bug
- `docs:` - Mudanças de documentação
- `refactor:` - Refatoração de código
- `test:` - Adição/modificação de testes
- `style:` - Mudanças de formatação

## 📝 Notas Importantes

- O projeto está em desenvolvimento ativo na branch `mvp-dia`
- Assets de grande tamanho estão em `scenes/` (alguns arquivos ultrapassam 4MB)
- Sistema de physics utiliza Jolt para performance otimizada
- UI baseada em sistema moderno do Godot 4.6

## 🔧 Troubleshooting

### Problema: Jogo não inicia
- Certifique-se de estar usando Godot 4.6+
- Verifique se todos os assets foram importados corretamente
- Limpe o cache: Delete a pasta `.godot/`

### Problema: Erro de renderização
- Verifique se sua GPU suporta D3D12 (Windows) ou Vulkan
- Atualize drivers de GPU
- Tente alterar o driver em `project.godot`

### Problema: Controles não funcionam
- Verifique as bindings do InputManager em `systems/input/input_manager.gd`
- Valide as ações de entrada em Project → Project Settings → Input Map

## 📞 Contato & Suporte

Para dúvidas ou issues, abra uma issue no repositório GitHub ou entre em contato com a equipe de desenvolvimento.

## 📄 Licença

[Adicione informações de licença aqui]

---

**Desenvolvido com ❤️ usando Godot Engine**

*Última atualização: Maio de 2026*
