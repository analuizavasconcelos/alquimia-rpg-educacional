# 🌳 Props Decorativos

Elementos decorativos reutilizáveis para o mundo do jogo.

## 📦 Props Disponíveis

### `rock.tscn` - Pedra
- **Tipo**: StaticBody2D (com collision)
- **Tamanho**: ~12x10 px
- **Uso**: Decoração, obstáculo
- **Collision**: Polígono circular

### `wood.tscn` - Tronco/Madeira
- **Tipo**: StaticBody2D (com collision)
- **Tamanho**: ~16x6 px
- **Uso**: Tronco caído, madeira, obstáculo
- **Collision**: Polígono retangular

### `crate.tscn` - Caixa
- **Tipo**: StaticBody2D (com collision)
- **Tamanho**: ~14x12 px
- **Uso**: Caixa, container, obstáculo
- **Collision**: Polígono retangular

### `tree.tscn` - Árvore
- **Tipo**: Node2D com TileMapLayer
- **Tamanho**: ~48x64 px (3x4 tiles)
- **Uso**: Árvore grande, decoração, obstáculo
- **Collision**: Polígono no tronco (base)

### `fence.tscn` - Cerca
- **Tipo**: Node2D com TileMapLayer
- **Tamanho**: ~32x16 px (2x1 tiles)
- **Uso**: Cerca horizontal, delimitar áreas
- **Collision**: Polígono retangular

## 🎯 Como Usar

### 1. Instanciar no Scene Editor

No Godot:
1. Abra a cena do nível (`vilarejo.tscn`)
2. Clique com botão direito no nó raiz
3. Escolha "Instantiate Child Scene"
4. Selecione o prop desejado
5. Posicione no mapa

### 2. Ajustar Collision

Para cada prop:
1. Selecione o `CollisionPolygon2D`
2. No viewport 2D, ajuste os pontos vermelhos
3. **Ctrl + Clique** para adicionar pontos
4. **Clique direito** para remover pontos

### 3. Dicas de Layout

**Árvores:**
- Espaçar pelo menos 32px entre elas
- Colocar collision só no tronco (já configurado)
- Agrupare em pequenos "bosques"

**Pedras:**
- Ótimas para marcar caminhos
- Podem ser rotacionadas para variedade
- Combinar com wood para áreas naturais

**Cercas:**
- Colocar em sequência para criar limites
- Podem delimitar fazendas, quintais
- Rotacionar 90° para cercas verticais

**Caixas:**
- Usar perto de casas ou armazéns
- Podem ser empilhadas (desabilitar collision de uma)
- Boas para criar obstáculos

## 🔧 Personalização

### Criar Variações

Para criar variações (ex: `rock_small.tscn`):
1. Duplique a cena original
2. Ajuste o `scale` do Sprite2D
3. Ajuste o polígono de collision
4. Salve com novo nome

### Adicionar Animação

Para props animados:
1. Substitua `Sprite2D` por `AnimatedSprite2D`
2. Configure SpriteFrames
3. Adicione script se necessário

## 📁 Estrutura

```
scenes/props/
├── rock.tscn          # Pedra
├── wood.tscn          # Tronco
├── crate.tscn         # Caixa
├── tree.tscn          # Árvore
├── fence.tscn         # Cerca
└── README.md          # Este arquivo
```

## 🎨 Assets Usados

- `rock.png` - Pedra
- `wood.png` - Madeira/Tronco
- `crate_base.png` - Caixa
- `SunnysideWorld_Tileset_V0.1.png` - Árvore e cerca (tiles)

