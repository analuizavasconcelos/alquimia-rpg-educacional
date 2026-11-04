extends Node2D

# Biblioteca: interior onde fica a mesa de alquimia.
# O cenário (piso, paredes, tapete) é desenhado por código a partir do tileset do pacote Sunnyside,
# e os móveis são criados como sprites com colisão. Tudo em coordenadas da sala (canto superior esquerdo = 0,0).
# Para mudar a decoração, edite as listas SHELVES e PROPS abaixo.

const TILESET_PATH: String = "res://assets/sprites/tilesets/interior/spr_tileset_sunnysideworld_16px.png"
const TILE: int = 16
const ROOM_COLUMNS: int = 15
const ROOM_ROWS: int = 9
const WALL_ROWS: int = 2

const BACKGROUND_COLOR: Color = Color(0.094, 0.078, 0.145)
# Posições dos tiles (coluna, linha) no tileset de 16 px
const FLOOR_TILE: Vector2i = Vector2i(10, 9)
const WALL_TILE: Vector2i = Vector2i(4, 12)
# Regiões (x, y, largura, altura) em pixels no tileset
const RUG_REGION: Rect2 = Rect2(643, 562, 43, 44)
const DOORMAT_REGION: Rect2 = Rect2(750, 574, 20, 20)
const BOOKSHELF_A: Rect2 = Rect2(672, 530, 16, 20)
const CABINET_B: Rect2 = Rect2(688, 530, 16, 20)
const DRAWERS_C: Rect2 = Rect2(704, 530, 16, 20)
const BOOKSHELF_D: Rect2 = Rect2(720, 530, 16, 20)
const CLOTH_TABLE: Rect2 = Rect2(768, 536, 14, 14)
const BENCH: Rect2 = Rect2(784, 539, 14, 11)
const STOOL: Rect2 = Rect2(800, 538, 10, 12)

# Estantes encostadas na parede do fundo: [região, índice da coluna]. A coluna 7 (meio) fica vazia.
const SHELVES: Array = [
	[BOOKSHELF_A, 1], [BOOKSHELF_D, 2], [CABINET_B, 3], [BOOKSHELF_D, 4], [DRAWERS_C, 5], [BOOKSHELF_A, 6],
	[BOOKSHELF_D, 8], [DRAWERS_C, 9], [BOOKSHELF_A, 10], [CABINET_B, 11], [BOOKSHELF_D, 12], [BOOKSHELF_A, 13],
]

# Móveis soltos: [região, posição (centro da base), tamanho da colisão (Vector2.ZERO = sem colisão)]
const PROPS: Array = [
	[CLOTH_TABLE, Vector2(36, 110), Vector2(12, 8)],
	[STOOL, Vector2(20, 112), Vector2(8, 6)],
	[STOOL, Vector2(54, 112), Vector2(8, 6)],
	[BENCH, Vector2(196, 112), Vector2(14, 8)],
]

var _tileset: Texture2D = null

func _ready() -> void:
	if ResourceLoader.exists(TILESET_PATH):
		_tileset = load(TILESET_PATH) as Texture2D
	else:
		push_warning("Biblioteca: tileset não encontrado: " + TILESET_PATH)
	_build_boundaries()
	_build_shelves()
	_build_props()
	queue_redraw()

func _draw() -> void:
	# O desenho do nó raiz fica por baixo de todos os filhos (jogador, móveis, mesa)
	draw_rect(Rect2(-1500, -1500, 3000, 3000), BACKGROUND_COLOR)
	if _tileset == null:
		draw_rect(Rect2(0, 0, ROOM_COLUMNS * TILE, ROOM_ROWS * TILE), Color(0.55, 0.33, 0.28))
		return
	for row in range(ROOM_ROWS):
		var tile: Vector2i = WALL_TILE if row < WALL_ROWS else FLOOR_TILE
		for column in range(ROOM_COLUMNS):
			var source: Rect2 = Rect2(tile.x * TILE, tile.y * TILE, TILE, TILE)
			draw_texture_rect_region(_tileset, Rect2(column * TILE, row * TILE, TILE, TILE), source)
	# Tapete no centro (a mesa de alquimia fica em cima dele) e tapete da porta
	var rug_position: Vector2 = Vector2(ROOM_COLUMNS * TILE / 2.0 - RUG_REGION.size.x / 2.0, 62)
	draw_texture_rect_region(_tileset, Rect2(rug_position, RUG_REGION.size), RUG_REGION)
	var mat_position: Vector2 = Vector2(ROOM_COLUMNS * TILE / 2.0 - DOORMAT_REGION.size.x / 2.0, ROOM_ROWS * TILE - DOORMAT_REGION.size.y + 2)
	draw_texture_rect_region(_tileset, Rect2(mat_position, DOORMAT_REGION.size), DOORMAT_REGION)

# Paredes invisíveis: o jogador não sai da sala
func _build_boundaries() -> void:
	var width: float = ROOM_COLUMNS * TILE
	var height: float = ROOM_ROWS * TILE
	var body: StaticBody2D = StaticBody2D.new()
	body.name = "Boundaries"
	add_child(body)
	# [centro, tamanho]: topo (parede do fundo), esquerda, direita, base
	var boxes: Array = [
		[Vector2(width / 2.0, WALL_ROWS * TILE + 2 - 8), Vector2(width + 32, 16)],
		[Vector2(-8, height / 2.0), Vector2(16, height + 32)],
		[Vector2(width + 8, height / 2.0), Vector2(16, height + 32)],
		[Vector2(width / 2.0, height + 8), Vector2(width + 32, 16)],
	]
	for box in boxes:
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = box[1]
		var collision: CollisionShape2D = CollisionShape2D.new()
		collision.shape = shape
		collision.position = box[0]
		body.add_child(collision)

func _build_shelves() -> void:
	if _tileset == null:
		return
	for entry in SHELVES:
		var region: Rect2 = entry[0]
		var column: int = entry[1]
		# Base da estante na parede do fundo (as estantes já são barradas pela parede invisível)
		_add_sprite(region, Vector2(column * TILE + TILE / 2.0, WALL_ROWS * TILE + 2))

func _build_props() -> void:
	if _tileset == null:
		return
	for entry in PROPS:
		var region: Rect2 = entry[0]
		var base_position: Vector2 = entry[1]
		var collision_size: Vector2 = entry[2]
		var sprite: Sprite2D = _add_sprite(region, base_position)
		if collision_size != Vector2.ZERO:
			var body: StaticBody2D = StaticBody2D.new()
			var shape: RectangleShape2D = RectangleShape2D.new()
			shape.size = collision_size
			var collision: CollisionShape2D = CollisionShape2D.new()
			collision.shape = shape
			collision.position = Vector2(0, -collision_size.y / 2.0)
			body.add_child(collision)
			sprite.add_child(body)

# Cria um sprite a partir de uma região do tileset; a posição é o centro da base do móvel (usada para a ordem de desenho)
func _add_sprite(region: Rect2, base_position: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _tileset
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = false
	sprite.offset = Vector2(-region.size.x / 2.0, -region.size.y)
	sprite.position = base_position
	add_child(sprite)
	return sprite
