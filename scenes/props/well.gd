extends StaticBody2D

@export var target_scene: String = ""  # Caminho para a cena de destino (ex: "res://scenes/levels/dungeon.tscn")
@export var interaction_distance: float = 50.0  # Distância para interagir

var portal_icon: Node2D = null
var interaction_area: Area2D = null
var _player_nearby: bool = false
var _icon_tween: Tween = null
var _icon_base_position: Vector2 = Vector2(0, -11)

const VILAREJO_SCENE = "res://scenes/levels/vilarejo.tscn"
const DUNGEON_SCENE = "res://scenes/levels/dungeon.tscn"

func _ready() -> void:
	# Adicionar ao grupo "well" para facilitar a busca
	add_to_group("well")
	
	# Se target_scene não estiver configurado, detectar automaticamente
	if target_scene.is_empty():
		_auto_detect_target_scene()
	
	# Buscar nodes
	portal_icon = get_node_or_null("PortalIcon")
	interaction_area = get_node_or_null("InteractionArea")
	
	# Configurar área de interação
	if interaction_area:
		var collision = interaction_area.get_node_or_null("CollisionShape2D")
		if collision:
			var shape = collision.shape
			if shape is CircleShape2D:
				shape.radius = interaction_distance
		
		# Conectar sinais da área de interação
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	# Esconder ícone inicialmente
	if portal_icon:
		portal_icon.visible = false
		# Guardar posição base do sprite dentro do PortalIcon
		var sprite = portal_icon.get_node_or_null("Sprite2D")
		if sprite:
			_icon_base_position = sprite.position
	
	# Habilitar processamento de input para detectar cliques
	set_process_input(true)

func _process(_delta: float) -> void:
	# Verificar se pode interagir com tecla
	if _player_nearby and Input.is_action_just_pressed("ui_accept"):
		_enter_dungeon()

func _input(event: InputEvent) -> void:
	if not _player_nearby:
		return
	
	# Verificar clique do mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_mouse_over_well_or_icon():
			_enter_dungeon()
			var viewport = get_viewport()
			if viewport:
				viewport.set_input_as_handled()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		if portal_icon:
			portal_icon.visible = true
			_start_icon_animation()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		if portal_icon:
			portal_icon.visible = false
			_stop_icon_animation()

func _auto_detect_target_scene() -> void:
	# Detectar a cena atual e definir o destino automaticamente
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	if current_scene_path == DUNGEON_SCENE:
		# Se estiver na dungeon, ir para o vilarejo
		target_scene = VILAREJO_SCENE
	elif current_scene_path == VILAREJO_SCENE:
		# Se estiver no vilarejo, ir para a dungeon
		target_scene = DUNGEON_SCENE
	else:
		# Fallback: tentar usar a dungeon como padrão
		target_scene = DUNGEON_SCENE
		push_warning("Well: Cena atual não reconhecida (" + current_scene_path + "), usando dungeon como destino padrão")

func _enter_dungeon() -> void:
	# Se ainda não tiver target_scene, tentar detectar novamente
	if target_scene.is_empty():
		_auto_detect_target_scene()
	
	if target_scene.is_empty():
		push_warning("Well: target_scene não está configurado!")
		return
	
	if not ResourceLoader.exists(target_scene):
		push_error("Well: Cena não encontrada: " + target_scene)
		return
	
	# Marcar que o player deve aparecer próximo ao well na próxima cena
	var transition_manager = get_node_or_null("/root/SceneTransitionManager")
	if transition_manager:
		transition_manager.set_spawn_at_well(true)
	
	# Trocar para a cena de destino
	get_tree().change_scene_to_file(target_scene)

func _start_icon_animation() -> void:
	if not portal_icon:
		return
	
	var sprite = portal_icon.get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	# Parar animação anterior se existir
	_stop_icon_animation()
	
	# Criar novo Tween
	_icon_tween = create_tween()
	_icon_tween.set_loops()  # Loop infinito
	_icon_tween.set_trans(Tween.TRANS_SINE)
	_icon_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Animar movimento vertical (mover 4 pixels para baixo e voltar)
	var target_position = _icon_base_position + Vector2(0, 4)
	_icon_tween.tween_property(sprite, "position", target_position, 0.8)
	_icon_tween.tween_property(sprite, "position", _icon_base_position, 0.8)

func _stop_icon_animation() -> void:
	if _icon_tween:
		_icon_tween.kill()
		_icon_tween = null
	
	# Resetar posição do sprite
	if portal_icon:
		var sprite = portal_icon.get_node_or_null("Sprite2D")
		if sprite:
			sprite.position = _icon_base_position

func _is_mouse_over_well_or_icon() -> bool:
	# Obter posição do mouse no mundo (considerando a câmera)
	var camera = get_viewport().get_camera_2d()
	var mouse_world_pos: Vector2
	
	if camera:
		# Usar a câmera para converter posição do mouse
		mouse_world_pos = camera.get_global_mouse_position()
	else:
		# Fallback: usar posição global do mouse
		mouse_world_pos = get_global_mouse_position()
	
	# Verificar se está próximo do poço
	var well_world_pos = global_position
	var well_distance = mouse_world_pos.distance_to(well_world_pos)
	
	# Verificar se está próximo do ícone também
	var icon_world_pos = global_position + Vector2(0, -11)  # Posição do ícone
	var icon_distance = mouse_world_pos.distance_to(icon_world_pos)
	
	# Área de clique maior para facilitar a interação
	var click_radius = interaction_distance * 2.0
	return well_distance <= click_radius or icon_distance <= 40.0
