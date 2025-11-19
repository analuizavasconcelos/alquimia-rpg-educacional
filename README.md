# Jogo TCC - Vilarejo

Jogo top-down simples criado no Godot 4.4 com cena de vilarejo e player jogável.

## 🎮 Como Jogar

### Controles
- **Setas do Teclado** ou **WASD**: Mover o personagem
  - ⬆️ / W: Cima
  - ⬇️ / S: Baixo
  - ⬅️ / A: Esquerda
  - ➡️ / D: Direita

## 📁 Estrutura do Projeto

```
jogo_tcc/
├── scenes/
│   ├── characters/
│   │   └── player/           # Personagem jogável
│   │       ├── player.gd     # Script de movimento
│   │       └── player.tscn   # Cena com animações
│   └── levels/
│       └── vilarejo.tscn     # Cena principal do vilarejo
├── assets/
│   ├── characters/           # Sprites dos personagens
│   ├── world/                # Tilesets do mundo
│   └── buildings/            # Assets de construções
└── project.godot             # Configuração do projeto
```

## 🚀 Como Executar

1. Abra o projeto no Godot 4.4
2. Pressione **F5** ou clique em **Play** (▶️)
3. Use as setas do teclado ou WASD para mover o personagem

## ✨ Características

- ✅ Movimento top-down em 4 direções
- ✅ Animações: idle (parado) e run (movimento)
- ✅ Sistema de colisão com obstáculos
- ✅ Câmera que segue o jogador automaticamente
- ✅ Cenário de vilarejo com TileMap
- ✅ Velocidade configurável (200 pixels/s)

---

Desenvolvido para o TCC
