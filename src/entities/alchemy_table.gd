extends StaticBody2D

# Mesa de Alquimia: objeto interativo do cenário que abre a janela de crafting de reações.
# Como usar: arraste scenes/prefabs/alchemy_table.tscn para o nível (ex.: vilarejo.tscn).
# O visual usa a arte do pacote Sunnyside World (tileset de interiores); se a imagem faltar,
# a mesa é desenhada como um retângulo simples.

const CraftingUI = preload("res://src/ui/crafting_ui.gd")

const TILESET_PATH: String = "res://assets/sprites/tilesets/interior/spr_tileset_sunnysideworld_16px.png"
# Regiões (x, y, largura, altura) no tileset: mesa de madeira, frasco azul e jarro de barro
const TABLE_REGION: Rect2 = Rect2(797, 573, 22, 25)
const FLASK_REGION: Rect2 = Rect2(738, 516, 12, 13)
const JAR_REGION: Rect2 = Rect2(753, 515, 12, 14)

@export var interaction_distance: float = 40.0
@export var table_size: Vector2 = Vector2(24, 14)
@export var hint_text: String = "Enter/Espaço: Mesa de Alquimia"

var _tileset: Texture2D = null
var _player_nearby: bool = false
var _crafting_ui: CraftingUI
var _hint: Label

func _ready() -> void:
	add_to_group("alchemy_table")
	if ResourceLoader.exists(TILESET_PATH):
		_tileset = load(TILESET_PATH) as Texture2D
	else:
		push_warning("Mesa de alquimia: tileset não encontrado: " + TILESET_PATH)
	queue_redraw()
	_build_interaction_area()
	_build_hint()

	_crafting_ui = CraftingUI.new()
	add_child(_crafting_ui)
	_crafting_ui.closed.connect(_on_crafting_closed)

func _draw() -> void:
	if _tileset == null:
		# Visual simples, usado só se a imagem do pacote não for encontrada
		var top: Rect2 = Rect2(-table_size / 2.0, table_size)
		draw_rect(top, Color(0.45, 0.30, 0.15))
		draw_rect(top, Color(0.25, 0.15, 0.05), false, 1.0)
		return
	# A origem do nó fica no centro da base da mesa (onde está a colisão)
	draw_texture_rect_region(_tileset, Rect2(-11, -19, 22, 25), TABLE_REGION)
	draw_texture_rect_region(_tileset, Rect2(-10, -18, 12, 13), FLASK_REGION)
	draw_texture_rect_region(_tileset, Rect2(0, -19, 12, 14), JAR_REGION)

func _process(_delta: float) -> void:
	if _player_nearby and Input.is_action_just_pressed("ui_accept"):
		interact()

func _unhandled_input(event: InputEvent) -> void:
	if not _player_nearby:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_global_mouse_position().distance_to(global_position) <= maxf(table_size.x, table_size.y):
			interact()
			get_viewport().set_input_as_handled()

# Público: também chamado pelo botão de interação do mobile (mobile_controls.gd)
func interact() -> void:
	if not _player_nearby or _crafting_ui.visible or _is_dialogue_active():
		return
	_hint.visible = false
	_crafting_ui.open()

func is_player_nearby() -> bool:
	return _player_nearby

func _is_dialogue_active() -> bool:
	var dialogue_manager: Node = get_tree().get_first_node_in_group("dialogue_manager")
	return dialogue_manager != null and dialogue_manager.has_method("get_is_dialogue_active") \
			and dialogue_manager.get_is_dialogue_active()

# ---------------------------------------------------------------------------
# Construção dos nós filhos (área de interação, dica). A colisão fica no .tscn.
# ---------------------------------------------------------------------------

func _build_interaction_area() -> void:
	var area: Area2D = Area2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = interaction_distance
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _build_hint() -> void:
	_hint = Label.new()
	_hint.text = hint_text
	_hint.add_theme_font_size_override("font_size", 8)
	_hint.add_theme_color_override("font_outline_color", Color.BLACK)
	_hint.add_theme_constant_override("outline_size", 3)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.size = Vector2(160, 12)
	_hint.position = Vector2(-80, -36)
	_hint.z_index = 10
	_hint.visible = false
	add_child(_hint)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		if not _crafting_ui.visible:
			_hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_hint.visible = false

func _on_crafting_closed() -> void:
	if _player_nearby:
		_hint.visible = true
