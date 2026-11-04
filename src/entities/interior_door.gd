extends Node2D

# Porta interativa: leva o jogador a outra cena (ex.: entrar na biblioteca e sair dela).
# Como usar: arraste scenes/prefabs/interior_door.tscn para o nível e posicione em frente à porta da casa.
# O visual é só uma dica de texto; a porta em si é a arte da casa.

@export var target_scene: String = "res://scenes/levels/biblioteca.tscn"
@export var interaction_distance: float = 22.0
@export var hint_text: String = "Enter/Espaço: Entrar na biblioteca"
# Guarda onde o jogador reaparece ao voltar para esta cena (use false na porta de saída)
@export var remember_return_position: bool = true
# Posição de retorno em relação à porta (um pouco à frente dela)
@export var return_offset: Vector2 = Vector2(0, 14)

var _player_nearby: bool = false
var _hint: Label

func _ready() -> void:
	add_to_group("interior_door")
	_build_interaction_area()
	_build_hint()

func _process(_delta: float) -> void:
	if _player_nearby and Input.is_action_just_pressed("ui_accept"):
		interact()

# Público: também chamado pelo botão de interação do mobile (mobile_controls.gd)
func interact() -> void:
	if not _player_nearby or _is_blocked():
		return
	if target_scene.is_empty() or not ResourceLoader.exists(target_scene):
		push_error("InteriorDoor: cena de destino não encontrada: " + target_scene)
		return

	_save_game()
	if remember_return_position:
		var transition_manager: Node = get_node_or_null("/root/SceneTransitionManager")
		var current_scene: Node = get_tree().current_scene
		if transition_manager and current_scene:
			transition_manager.set_return_position(global_position + return_offset, current_scene.scene_file_path)
	get_tree().change_scene_to_file(target_scene)

func is_player_nearby() -> bool:
	return _player_nearby

# Não deixa entrar com diálogo, glossário ou outra janela (mesa de alquimia) abertos
func _is_blocked() -> bool:
	var dialogue_manager: Node = get_tree().get_first_node_in_group("dialogue_manager")
	if dialogue_manager != null and dialogue_manager.has_method("get_is_dialogue_active") \
			and dialogue_manager.get_is_dialogue_active():
		return true
	var glossary: Node = get_tree().get_first_node_in_group("knowledge_glossary")
	if glossary != null and glossary.visible:
		return true
	for blocker in get_tree().get_nodes_in_group("blocks_player_movement"):
		if blocker.visible:
			return true
	return false

func _save_game() -> void:
	var save_manager: Node = get_tree().get_first_node_in_group("save_manager")
	if save_manager and save_manager.has_method("save_game"):
		save_manager.save_game()

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
	_hint.position = Vector2(-80, -22)
	_hint.z_index = 10
	_hint.visible = false
	add_child(_hint)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		_hint.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_hint.visible = false
