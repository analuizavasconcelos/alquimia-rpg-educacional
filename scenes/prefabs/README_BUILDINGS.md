# 🏠 Buildings (Construções)

Cenas reutilizáveis de construções para o jogo.

## 📦 Cenas Disponíveis

### 1. **house_small.tscn** (Casa Pequena Laranja)
- Tamanho: 64x80 pixels
- Colisão: 48x40
- Uso: Casas simples, residências pequenas

### 2. **house_medium.tscn** (Casa Média Verde)
- Tamanho: 80x96 pixels
- Colisão: 64x48
- Uso: Casas residenciais médias

### 3. **house_large.tscn** (Casa Grande Laranja)
- Tamanho: 96x112 pixels
- Colisão: 80x56
- Uso: Casas nobres, lojas grandes

### 4. **house_blue.tscn** (Casa Azul)
- Tamanho: 80x96 pixels
- Colisão: 64x48
- Uso: Variação de casa residencial

### 5. **house_red.tscn** (Casa Vermelha)
- Tamanho: 96x112 pixels
- Colisão: 72x56
- Uso: Loja, taverna, casa especial

## 🎯 Como Usar

### No Editor do Godot:
1. Abra a cena do nível (ex: `vilarejo.tscn`)
2. Arraste a cena da casa desejada para o viewport
3. Posicione onde quiser
4. A colisão já está configurada!

### Por Código:
```gdscript
# Instanciar uma casa dinamicamente
var house = preload("res://scenes/prefabs/house_small.tscn")
var house_instance = house.instantiate()
house_instance.position = Vector2(200, 150)
add_child(house_instance)
```

## 🏗️ Estrutura de Cada Casa

Cada cena de building contém:
- **StaticBody2D**: Corpo físico estático (não se move)
- **Sprite2D**: Imagem da construção
  - `region_enabled = true`: Recorta parte do tileset
  - `region_rect`: Área específica da textura
- **CollisionShape2D**: Forma de colisão (impede player de atravessar)

## ✨ Vantagens desta Abordagem

✅ **Reutilizável**: Mesma cena em vários lugares  
✅ **Organizado**: Cada tipo de casa em seu arquivo  
✅ **Fácil de editar**: Mude 1 arquivo, atualiza em todo lugar  
✅ **Performance**: Godot otimiza cenas instanciadas  
✅ **Colisão automática**: Player não atravessa casas  

## 🔧 Personalizando

Para criar novos tipos de casa:
1. Duplique uma cena existente
2. Mude o `region_rect` no Sprite2D para outra parte do tileset
3. Ajuste o tamanho da `CollisionShape2D`
4. Salve com um novo nome

## 📝 Exemplo de Organização no Vilarejo

```
Vilarejo
├── Ground (TileMapLayer)
├── Buildings (Node2D)
│   ├── HouseSmall
│   ├── HouseSmall2
│   ├── HouseMedium
│   └── HouseLarge
└── Player
```

## 🎨 Assets Usados

- **Texture**: `assets/sprites/tilesets/buildings/tileset/SUNNYSIDE_WORLD_BUILDINGS_V0.01.png`
- Cada casa usa uma região diferente do tileset

