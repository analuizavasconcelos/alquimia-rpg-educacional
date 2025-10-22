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
└── levels/             # Níveis e mapas do jogo
    └── vilarejo.tscn   # Cena principal do vilarejo
```

## 🎯 Convenções

- **characters/**: Todos os personagens (player, NPCs, inimigos)
- **levels/**: Todas as cenas de níveis e mapas
- **ui/**: Interfaces e menus (a adicionar)
- **objects/**: Objetos interativos (a adicionar)

## 📝 Notas

- Cada personagem tem sua própria pasta com script (.gd) e cena (.tscn)
- Manter a estrutura organizada facilita manutenção e colaboração

