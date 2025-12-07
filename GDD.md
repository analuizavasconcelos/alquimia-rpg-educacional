# Game Design Document (GDD)

**Instituto Federal de Educação, Ciência e Tecnologia da Bahia (IFBA)**

**Título do jogo:** Proposta de Plataforma de Jogo Educacional Estilo RPG

**Versão do Documento:** 1.0

**Engine:** Godot 4.4

**Linguagem:** GDScript

**Gerenciador de versão:** Git

**Autores:** [A preencher]

**Orientador:** [A preencher]

---

## PARTE 1: GAME CONCEPT DOCUMENT

### 1.1 Resumo Executivo

Um RPG Top-Down de fantasia medieval onde o jogador aprende conteúdos de Química através de exploração livre, interação com NPCs e navegação em masmorras. O jogo utiliza princípios de gamificação para promover aprendizado passivo-ativo, incorporando elementos como progressão de conhecimentos, sistema de recompensas, exploração aberta e interação narrativa. O conteúdo educacional é apresentado de forma natural durante diálogos com NPCs, onde termos relevantes são destacados e desbloqueados automaticamente no glossário, permitindo que o jogador absorva conhecimentos enquanto realiza atividades típicas do gênero RPG, como explorar um vilarejo medieval e acessar uma masmorra navegável. A plataforma foi concebida como um sistema modular e expansível, permitindo a integração futura de novos módulos educacionais sem necessidade de reestruturar o núcleo do sistema.

### 1.2 Objetivos Pedagógicos

O jogo visa desenvolver competências relacionadas ao ensino de Química através de uma abordagem lúdica e imersiva. O módulo educacional inicial é focado em conteúdos de Química, com a possibilidade de expansão futura para outras disciplinas.

**Método de Integração do Conteúdo:**
- **Narrativa e Diálogos:** O conteúdo educacional é apresentado via narrativa durante diálogos com NPCs. Termos químicos relevantes são destacados visualmente e desbloqueados automaticamente no glossário de conhecimentos quando mencionados.
- **Aprendizado Passivo-Ativo:** O conhecimento é absorvido naturalmente durante a exploração e interação, permitindo que o estudante aprenda enquanto realiza atividades típicas do gênero RPG, sem interromper o fluxo de jogo.
- **Gamificação:** Sistema de desbloqueio de conhecimentos funciona como recompensa, incentivando exploração e interação contínua.
- **Retenção:** Glossário permanente permite revisão dos conhecimentos adquiridos a qualquer momento, favorecendo a consolidação do aprendizado.

**Competências Desenvolvidas:**
- Visualização de conceitos abstratos através de representações visuais e narrativas
- Estabelecimento de relações entre teoria e prática através de analogias do mundo do jogo
- Engajamento e motivação através de elementos de gamificação (progressão, recompensas, exploração)
- Aprendizado significativo através da contextualização do conteúdo em um ambiente imersivo

**Expansibilidade:**
A plataforma foi concebida como um sistema modular e expansível, permitindo a integração futura de novos módulos educacionais (Biologia, História, Matemática, Línguas Estrangeiras, etc.) sem necessidade de reestruturar o núcleo do sistema.

### 1.3 Estética e Atmosfera

**Estilo Visual:** Pixel Art estilo 16-bit com temática de fantasia medieval

**Ferramenta de Arte:** 
- Sprites: Piskel (padronizado)
- Tilesets: Assets externos (Sunnyside World)

**Paleta de Cores:** 
- Ambiente: Tons terrosos e naturais para o vilarejo
- UI: Cores vibrantes com destaque dourado para elementos importantes
- Conhecimentos: Destaque em dourado/amarelo para termos desbloqueados

**Referências Visuais:**
- The Legend of Zelda: A Link to the Past (movimentação top-down)
- Stardew Valley (estética pixel art e exploração)
- Undertale (sistema de diálogo e narrativa)

**Atmosfera:** 
- Ambientação medieval fantástica
- Tom educativo mas lúdico
- Exploração livre e descoberta

---

## PARTE 2: GAME DESIGN DOCUMENT (GDD)

### 2.1 Ciclo de Jogabilidade

O ciclo principal de jogabilidade segue o padrão de exploração e descoberta:

**Ação:** Explorar o vilarejo e a masmorra livremente

**Desafio:** Encontrar NPCs e objetos interativos que contenham informações educacionais

**Resolução:** Interagir com NPCs através de diálogos, onde conhecimentos são apresentados de forma contextualizada. Termos químicos são destacados automaticamente e desbloqueados no glossário.

**Recompensa:** 
- Novo conhecimento desbloqueado (notificação visual)
- Progresso no glossário de conhecimentos
- Expansão da narrativa e do mundo
- Acesso a novas áreas (masmorra)

**Loop de Feedback:**
1. Jogador explora o ambiente
2. Detecta NPC próximo (ícone de chat aparece)
3. Interage com NPC (clica)
4. Lê diálogo com termos destacados
5. Conhecimento é desbloqueado automaticamente
6. Notificação visual confirma desbloqueio
7. Jogador pode consultar glossário a qualquer momento
8. Retorna à exploração para encontrar mais NPCs

### 2.2 Mecânicas Principais

#### Movimentação

**Tipo:** Movimentação top-down

**Controles:**
- **Desktop:** WASD ou Setas do teclado (4 direções)
- **Mobile:** Joystick virtual (analógico)

**Características:**
- Movimento em grid livre (não limitado a tiles)
- Velocidade: 200 pixels/segundo
- Animações: Idle, Walking, Run
- Câmera segue o jogador automaticamente
- Sistema de colisão com obstáculos (CharacterBody2D)

**Física:**
- Movimento baseado em `move_and_slide()`
- Detecção de colisão com objetos do cenário
- Áreas de interação para NPCs e objetos

#### Interação

**Sistema de Detecção:** Detecção de proximidade automática com interação ativa

**Mecânica:**
- Quando o jogador se aproxima de um NPC ou objeto interativo, um ícone visual aparece acima do elemento
- O jogador deve pressionar E (desktop) ou botão de interação (mobile) para iniciar a interação
- Distância mínima de interação: 50 pixels

**Elementos Interativos:**
- **NPCs:** Iniciam diálogos quando interagidos
- **Poço (Well):** Transição para a masmorra (dungeon)
- **Objetos futuros:** Itens coletáveis, portas, etc.

#### Sistemas Específicos

**Sistema de Diálogo:**
- Diálogos carregados de arquivos JSON externos
- Suporte a BBCode para formatação de texto
- Tags especiais `[k="conhecimento"]` para destacar termos educacionais
- Interface de diálogo responsiva com animações
- Avanço de diálogo com E ou clique

**Sistema de Conhecimento:**
- Desbloqueio automático durante diálogos
- Glossário permanente de conhecimentos desbloqueados
- Notificações visuais ao desbloquear novos conhecimentos
- Persistência entre sessões (salvamento automático)
- Categorização de conhecimentos por tema

**Sistema de Save/Load:**
- Salvamento automático do progresso
- Persistência de conhecimentos desbloqueados
- Carregamento de jogo salvo no menu principal
- Gerenciamento de estado entre cenas

**Sistema de Transição de Cenas:**
- Transição suave entre vilarejo e masmorra
- Persistência de estado (câmera, HUD, etc.)
- Gerenciamento centralizado via singleton

**Sistema Mobile:**
- Joystick virtual para movimentação
- Botões de interação e menu
- Interface adaptativa para diferentes tamanhos de tela
- HUD que se oculta durante diálogos

### 2.3 Narrativa e Personagens

#### Contexto Atual

O jogo atualmente apresenta um escopo inicial que serve como base para futuras expansões. O protótipo implementado estabelece os fundamentos de um mundo expansível, onde a narrativa e os personagens serão desenvolvidos conforme novos módulos educacionais forem integrados.

**Estado Atual:**
- Ambiente de vilarejo medieval de fantasia explorável
- Sistema de diálogo funcional que permite apresentar conteúdo educacional
- NPCs básicos que demonstram a mecânica de interação e desbloqueio de conhecimentos
- Transição para masmorra (dungeon) como exemplo de área adicional explorável

**Estrutura para Expansão:**
- A arquitetura modular permite adicionar novos personagens, narrativas e cenários sem reestruturar o núcleo do sistema
- Cada novo módulo educacional pode trazer sua própria narrativa contextualizada
- Personagens podem ser criados para diferentes disciplinas e conteúdos
- Cenários podem ser expandidos para acomodar novos conteúdos educacionais

#### Personagens

**Protagonista:**
- **Função:** Avatar do jogador, sem diálogos próprios
- **Características Visuais:** Sprite pixel art, animações de movimento (idle, walking, run)
- **Estado:** Implementado como base, pode ser expandido conforme necessário

**NPCs Atuais (Protótipo):**
- **NPC Base, NPC Curly Hair, NPC Long Hair, NPC Mop Hair:** NPCs de demonstração que apresentam o sistema de diálogo e desbloqueio de conhecimentos
- **Função:** Validar mecânicas de interação e apresentação de conteúdo educacional
- **Localização:** Vilarejo

**Expansão Futura:**
- Novos personagens serão adicionados conforme novos módulos educacionais forem desenvolvidos
- Cada módulo pode trazer personagens especializados em diferentes áreas do conhecimento
- Narrativas podem ser desenvolvidas para contextualizar o conteúdo educacional de cada módulo
- Personagens podem ter funções específicas (alquimista, ferreiro, estudioso, etc.) conforme a necessidade do conteúdo
- Novas mecânicas podem ser implementadas para ampliar a jogabilidade

### 2.4 Interface (UI/UX)

#### Menu Principal

**Elementos:**
- Título do jogo
- Botão "Continuar" (habilitado se houver save)
- Botão "Novo Jogo"
- Botão "Sair"
- Versão do jogo

**Funcionalidades:**
- Animação de entrada (fade in)
- Verificação automática de save existente
- Transição suave para o jogo

#### HUD de Gameplay

**Elementos Visíveis:**
- Câmera que segue o jogador (não é UI, mas parte do feedback visual)

**Elementos Condicionais:**
- **Ícone de Chat:** Aparece acima de NPCs quando o jogador está próximo
- **Ícone de Portal:** Aparece acima do poço quando o jogador está próximo

**Mobile HUD:**
- **Joystick Virtual:** Canto inferior esquerdo
- **Botão Interagir:** Canto inferior direito
- **Botão Menu:** Canto superior direito
- HUD se oculta automaticamente durante diálogos

#### Interfaces de Sistema

**Janela de Diálogo:**
- Painel centralizado na tela
- Texto formatado com BBCode
- Termos de conhecimento destacados em dourado/amarelo
- Indicador de "Pressione E para continuar"
- Fecha automaticamente ao final do diálogo

**Glossário de Conhecimentos:**
- Acessível via menu rápido (ESC ou botão menu mobile)
- Lista todos os conhecimentos desbloqueados
- Organizado por categorias
- Cada entrada mostra nome e descrição
- Interface responsiva e scrollável

**Notificação de Conhecimento:**
- Popup centralizado ao desbloquear novo conhecimento
- Exibe nome e descrição do conhecimento
- Animação de entrada e saída
- Ícones decorativos (✨)

**Menu Rápido (Pause):**
- Acessível via ESC (desktop) ou botão menu (mobile)
- Opções: Glossário, Continuar, Novo Jogo, Sair
- Pausa o jogo durante a exibição

**Sistema de Save:**
- Salvamento automático (sem interface)
- Carregamento via menu principal
- Feedback visual discreto

---

## PARTE 3: ARQUITETURA TÉCNICA

### 3.1 Stack Tecnológico

**Engine:** Godot 4.4
- Renderização: Motor de renderização 2D do Godot
- Física: Sistema de física integrado (CharacterBody2D, Area2D)
- UI: Sistema de UI baseado em nós (Control, CanvasLayer)

**Lógica:** GDScript (Extensão .gd)
- Linguagem de script nativa do Godot
- Tipagem opcional
- Sistema de sinais integrado

**Dados Externos:** JSON
- Diálogos: `data/dialogues/*.json`
- Conhecimentos: Estrutura JSON para definição de conhecimentos
- Permite edição de conteúdo sem recompilar o jogo

**Arte:** 
- Sprites: PNG (Spritesheets)
- Tilesets: PNG
- UI: Elementos nativos do Godot com estilização

**Versionamento:** Git
- Controle de versão distribuído
- Estrutura de branches para desenvolvimento

### 3.2 Modelo C4

#### 3.2.1 Definição do Contexto

```
Sistema: Plataforma de Jogo Educacional Estilo RPG
Usuários: Jogadores interessados em aprendizado através de gamificação
Objetivo: Ensinar conteúdos educacionais através de gamificação
```

**Atores Externos:**
- **Jogador:** Interage com o jogo através de controles (teclado/mouse/touch)
- **Educador:** Pode editar conteúdo educacional via arquivos JSON (futuro)

#### 3.2.2 Definição dos Containers

**Container 1: Aplicação Godot**
- **Tecnologia:** Godot 4.4 Engine
- **Responsabilidades:**
  - Renderização gráfica
  - Gerenciamento de física
  - Processamento de input
  - Gerenciamento de cenas

**Container 2: Sistema de Arquivos**
- **Tecnologia:** Sistema de arquivos local
- **Responsabilidades:**
  - Armazenamento de saves
  - Leitura de arquivos JSON (diálogos, conhecimentos)
  - Persistência de dados do jogador

#### 3.2.3 Definição de Componentes Chave

**Componente: SceneManager (SceneTransitionManager)**
- **Tipo:** Autoload Singleton
- **Responsabilidades:**
  - Gerenciar transições entre cenas
  - Persistir estado entre cenas (câmera, HUD)
  - Coordenar carregamento de cenas

**Componente: SaveManager**
- **Tipo:** Autoload Singleton
- **Responsabilidades:**
  - Salvar progresso do jogador
  - Carregar saves existentes
  - Gerenciar dados persistentes

**Componente: DialogueManager**
- **Tipo:** Node (instanciado em cenas)
- **Responsabilidades:**
  - Gerenciar estado de diálogos ativos
  - Emitir sinais de início/fim de diálogo
  - Coordenar exibição de diálogos

**Componente: KnowledgeManager**
- **Tipo:** Node (instanciado em cenas)
- **Responsabilidades:**
  - Gerenciar conhecimentos desbloqueados
  - Processar tags de conhecimento em diálogos
  - Persistir conhecimentos via SaveManager

**Componente: PlayerController (Player)**
- **Tipo:** CharacterBody2D
- **Responsabilidades:**
  - Processar input de movimento
  - Gerenciar física e colisões
  - Controlar animações
  - Detectar interações

**Componente: NPC**
- **Tipo:** CharacterBody2D
- **Responsabilidades:**
  - Carregar diálogo de arquivo JSON
  - Detectar proximidade do jogador
  - Iniciar diálogo quando interagido

**Componente: DialogueBox**
- **Tipo:** CanvasLayer/Control
- **Responsabilidades:**
  - Exibir texto do diálogo
  - Processar BBCode
  - Gerenciar avanço de diálogo

**Componente: KnowledgeGlossary**
- **Tipo:** CanvasLayer/Control
- **Responsabilidades:**
  - Exibir lista de conhecimentos desbloqueados
  - Organizar conhecimentos por categoria
  - Permitir consulta a qualquer momento

**Componente: MobileControls**
- **Tipo:** CanvasLayer/Control
- **Responsabilidades:**
  - Exibir joystick virtual
  - Exibir botões de interação
  - Gerenciar visibilidade baseada em estado do jogo

### 3.3 Estrutura de Pastas

A organização segue estritamente o padrão definido:

```
res://
├── assets/                 # Recursos Binários (Não-Script)
│   ├── sprites/            # Sprites exportados
│   │   ├── characters/     # Sprites de personagens
│   │   │   ├── IDLE/       # Animações de idle
│   │   │   ├── RUN/        # Animações de corrida
│   │   │   └── WALKING/    # Animações de caminhada
│   │   └── tilesets/       # Tilesets do jogo
│   │       ├── buildings/  # Tilesets de construções
│   │       └── world/      # Tilesets do mundo
│   ├── audio/              # SFX e BGM (futuro)
│   └── fonts/              # Fontes customizadas (futuro)
│
├── src/                    # Código Fonte (Scripts)
│   ├── autoload/           # Singletons (Autoload)
│   │   └── scene_transition_manager.gd
│   ├── entities/           # Atores (Player, NPCs, Objetos)
│   │   ├── player.gd
│   │   ├── npc.gd
│   │   └── well.gd
│   ├── systems/            # Lógica pura (Sistemas)
│   │   └── save_manager.gd
│   └── ui/                 # Scripts de Interface
│       ├── dialogue_manager.gd
│       ├── dialogue_box.gd
│       ├── knowledge_manager.gd
│       ├── knowledge_glossary.gd
│       ├── knowledge_notification.gd
│       ├── mobile_controls.gd
│       ├── joystick.gd
│       ├── quick_menu.gd
│       └── main_menu.gd
│
├── scenes/                 # Árvores de Nós (.tscn)
│   ├── levels/             # Mapas jogáveis
│   │   ├── vilarejo.tscn
│   │   └── dungeon.tscn
│   ├── prefabs/            # Objetos instanciáveis
│   │   ├── buildings/      # Construções
│   │   ├── props/          # Props decorativos
│   │   └── characters/     # Personagens (NPCs)
│   └── ui/                 # Menus e HUDs
│       ├── main_menu.tscn
│       ├── dialogue_box.tscn
│       ├── npc_dialogue_box.tscn
│       ├── knowledge_glossary.tscn
│       ├── knowledge_notification.tscn
│       └── mobile_controls.tscn
│
└── data/                   # Arquivos JSON editáveis
    └── dialogues/          # Conteúdo Educativo
        ├── npc_base.json
        ├── npc_curlyhair.json
        ├── npc_longhair.json
        └── npc_mophair.json
```

---

## PARTE 4: MANUAL DE MELHORES PRÁTICAS (DEV GUIDELINES)

### 4.1 Padrões de Nomenclatura

**Classes/Nós:** PascalCase
- Exemplos: `Player`, `DialogueManager`, `KnowledgeManager`, `SceneTransitionManager`

**Arquivos/Pastas:** snake_case
- Exemplos: `player.gd`, `dialogue_manager.gd`, `knowledge_glossary.tscn`, `level_01.tscn`

**Variáveis/Funções:** snake_case
- Exemplos: 
  - `var movement_speed = 200.0`
  - `func calculate_damage()`
  - `func _on_button_pressed()`

**Constantes/Enums:** SCREAMING_SNAKE_CASE
- Exemplos:
  - `const MAX_HEALTH = 100`
  - `const INTERACTION_DISTANCE = 50.0`
  - `enum STATE { IDLE, WALKING, RUNNING }`

**Sinais:** snake_case com prefixo descritivo
- Exemplos:
  - `signal dialogue_started`
  - `signal knowledge_unlocked`
  - `signal scene_changed`

### 4.2 Princípio de Composição (Composition over Inheritance)

**Evite:** Árvores de herança profundas
```gdscript
# ❌ ERRADO
class Entity extends Node2D
class Character extends Entity
class Player extends Character
class NPC extends Character
```

**Prefira:** Composição com nós filhos
```gdscript
# ✅ CORRETO
# Player é um CharacterBody2D com nós filhos:
# - AnimatedSprite2D (animações)
# - CollisionShape2D (colisão)
# - Camera2D (câmera)
# - InteractionArea (detecção de interação)
```

**Exemplo Prático:**
- O `Player` não herda de uma classe base genérica
- O `Player` é composto por componentes especializados
- Cada componente tem responsabilidade única
- Facilita manutenção e extensão

### 4.3 Uso de Signals

**Regra Fundamental:** "Call down, Signal up"
- Chame funções nos filhos (call down)
- Emita sinais para os pais (signal up)

**Exemplo Correto:**

```gdscript
# Player.gd
signal item_collected(item_name)

func _on_area_entered(area):
    if area.is_in_group("collectible"):
        var item = area.get_item()
        item_collected.emit(item.name)  # ✅ Sinal para cima

# GameManager.gd (ou HUD)
func _ready():
    var player = get_tree().get_first_node_in_group("player")
    player.item_collected.connect(_on_item_collected)  # ✅ Escuta sinal

func _on_item_collected(item_name):
    hud.update_inventory(item_name)  # ✅ Chama função do filho
```

**Exemplo Incorreto:**

```gdscript
# ❌ ERRADO - Player chamando HUD diretamente
func _on_area_entered(area):
    var hud = get_tree().get_first_node_in_group("hud")
    hud.update_inventory(item.name)  # ❌ Acoplamento direto
```

**Benefícios:**
- Baixo acoplamento entre componentes
- Fácil manutenção e testes
- Reutilização de código
- Comunicação clara entre sistemas

### 4.4 Gerenciamento de Assets

**Sprites:**
- Exporte sprites no Piskel como PNG (Spritesheet)
- Importe no Godot na pasta `assets/sprites/`
- Use AtlasTexture para spritesheets
- Organize por categoria (characters, tilesets, etc.)

**Tilesets:**
- Use tilesets externos padronizados
- Mantenha consistência visual
- Organize em `assets/sprites/tilesets/`

**UI:**
- Use elementos nativos do Godot quando possível
- Customize com StyleBoxFlat para estilização
- Mantenha temas consistentes

### 4.5 Versionamento e Git

**Commit Messages:** Utilize Conventional Commit Messages

**Formato:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Tipos:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Tarefas de manutenção

**Exemplos:**
```
feat(dialogue): adiciona sistema de tags de conhecimento
fix(player): corrige colisão com obstáculos
docs(readme): atualiza estrutura de pastas
refactor(knowledge): simplifica lógica de desbloqueio
```

**Micro commits:**
- Crie commits pequenos e focados
- Um commit = uma mudança lógica
- Facilita revisão e rollback
- Histórico semântico claro

**Gitignore:**
- Certifique-se de que `.godot/` está no `.gitignore`
- Ignore arquivos temporários
- Mantenha apenas código fonte e assets

### 4.6 Expansão

**Fonte de Dados Externa:**
- Utilize arquivos JSON para conteúdo editável
- Diálogos em `data/dialogues/*.json`
- Conhecimentos podem ser definidos em JSON
- Permite adicionar conteúdo sem recompilar

**Vantagens:**
- Atualizações de conteúdo sem rebuild
- Facilita colaboração com educadores
- Separação entre código e conteúdo
- Versionamento independente

**Estrutura de Expansão Futura:**
- Novos módulos educacionais via JSON
- Sistema de plugins para novos conteúdos
- API para integração externa (futuro)

---

## PARTE 5: CRONOGRAMA DE EXPANSÃO

### 5.1 Fases de Desenvolvimento

#### 5.1.1 Protótipo

**Objetivo:** Validar conceito e mecânicas básicas

**Entregáveis:**
- ✅ Movimentação top-down funcional
- ✅ Sistema básico de diálogo com NPCs
- ✅ Sistema de conhecimento com desbloqueio
- ✅ Interface básica (menu, diálogo, glossário)
- ✅ Cena do vilarejo explorável
- ✅ Transição para masmorra
- ✅ Suporte mobile (controles touch)

**Status:** ✅ Concluído

#### 5.1.2 Core

**Objetivo:** Implementar funcionalidades essenciais e polir experiência

**Entregáveis:**
- ✅ Sistema de save/load completo
- ✅ Persistência de conhecimentos
- ✅ Glossário funcional e responsivo
- ✅ Notificações de conhecimento
- ✅ Sistema de transição de cenas
- ✅ HUD mobile completo e responsivo
- ✅ Exportação para Android
- 🔄 Expansão de diálogos e conhecimentos
- 🔄 Mais NPCs com conteúdo educacional
- 🔄 Expansão da masmorra

**Status:** 🟡 Em desenvolvimento


### 5.2 Roadmap Futuro

**Fase 4: Expansão de Conteúdo**
- Novos módulos educacionais (Inglês, Física, Biologia, etc.)
- Sistema de quests/missões
- Mais áreas exploráveis
- Sistema de inventário
- Sistema de crafting (relacionado a Química)

---

## ANEXOS

### A. Referências Técnicas

- **Godot Documentation:** https://docs.godotengine.org/
- **GDScript Style Guide:** Padrões oficiais do Godot
- **Conventional Commits:** https://www.conventionalcommits.org/

### B. Estrutura de Dados

**Formato de Diálogo (JSON):**
```json
{
  "dialogue": [
    "Olá! Bem-vindo ao vilarejo!",
    "Você sabe o que é um [k=\"átomo\"]?",
    "É a menor partícula de um elemento químico!"
  ]
}
```

**Formato de Conhecimento (Estrutura Interna):**
```gdscript
{
  "id": "atomo",
  "name": "Átomo",
  "description": "A menor partícula de um elemento químico...",
  "category": "Estrutura Atômica"
}
```

### C. Checklist de Implementação

**Sistemas Core:**
- [x] Movimentação do jogador
- [x] Sistema de diálogo
- [x] Sistema de conhecimento
- [x] Sistema de save/load
- [x] Interface mobile
- [x] Transição de cenas

**Conteúdo:**
- [x] Cena do vilarejo
- [x] Cena da masmorra
- [x] NPCs básicos
- [ ] Expansão de diálogos
- [ ] Mais conhecimentos

---

**Documento gerado em:** [07/12/2025]

**Última atualização:** [07/12/2025]

**Versão:** 1.0

