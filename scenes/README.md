# Estrutura de Cenas

Organização das cenas do projeto.

## 📁 Estrutura

```
scenes/
├── characters/          # Personagens jogáveis e NPCs
│   └── player/         # Personagem principal
│       ├── player.gd   # Script de movimento e comportamento
│       └── player.tscn # Cena do player com animações
│
├── buildings/          # Construções reutilizáveis
│   ├── house_small.tscn   # Casa pequena
│   ├── house_medium.tscn  # Casa média
│   ├── house_large.tscn   # Casa grande
│   ├── house_blue.tscn    # Casa azul
│   ├── house_red.tscn     # Casa vermelha
│   └── README.md          # Documentação dos buildings
│
├── props/              # Props e elementos decorativos
│   ├── rock.tscn      # Pedra
│   ├── wood.tscn      # Tronco/madeira
│   ├── crate.tscn     # Caixa
│   ├── tree.tscn      # Árvore
│   ├── fence.tscn     # Cerca
│   └── README.md      # Documentação dos props
│
└── levels/             # Níveis e mapas do jogo
    └── vilarejo.tscn   # Cena principal do vilarejo
```

## 🎯 Convenções

- **characters/**: Todos os personagens (player, NPCs, inimigos)
- **buildings/**: Construções reutilizáveis (casas, lojas, etc)
- **props/**: Props decorativos (árvores, pedras, cercas, caixas, etc)
- **levels/**: Todas as cenas de níveis e mapas
- **ui/**: Interfaces e menus (a adicionar)
- **objects/**: Objetos interativos (a adicionar)

## 📝 Notas

- Cada personagem tem sua própria pasta com script (.gd) e cena (.tscn)
- Manter a estrutura organizada facilita manutenção e colaboração

