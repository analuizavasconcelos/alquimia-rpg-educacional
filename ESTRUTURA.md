# 📂 Estrutura do Projeto - Guia Rápido

## ✅ Arquivos Corretos (USE ESTES)

### Player
- **Script**: `scenes/characters/player/player.gd`
- **Cena**: `scenes/characters/player/player.tscn`

### Vilarejo
- **Cena**: `scenes/levels/vilarejo.tscn`

## ❌ Arquivos Deletados (NÃO EXISTEM MAIS)

~~`scenes/player.gd`~~ → Movido para `scenes/characters/player/player.gd`
~~`scenes/player.tscn`~~ → Movido para `scenes/characters/player/player.tscn`
~~`scenes/vilarejo.tscn`~~ → Movido para `scenes/levels/vilarejo.tscn`

## 🔧 Se o Godot reclamar de arquivos não encontrados:

1. **Feche o Godot completamente**
2. Delete a pasta `.godot/` (cache)
3. Reabra o projeto no Godot
4. Aguarde a reimportação de todos os assets

## 📁 Estrutura Atual

```
scenes/
├── characters/
│   └── player/
│       ├── player.gd    ✅ Script do player
│       └── player.tscn  ✅ Cena do player
└── levels/
    └── vilarejo.tscn    ✅ Cena principal
```

## ⚙️ Configurações

- **Cena Principal**: `scenes/levels/vilarejo.tscn`
- **Velocidade do Player**: 200.0 (definida em `player.gd`)
- **Controles**: Setas do teclado ou WASD

