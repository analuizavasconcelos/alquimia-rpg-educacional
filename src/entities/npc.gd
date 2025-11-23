extends Node2D

@export var start_animation: StringName = "idle"
@export var facing_left := false:
	set(value):
		_facing_left = value
		_apply_facing_direction()
	get:
		return _facing_left
@export var dialogue_file: String = ""  # Caminho para o arquivo JSON de diálogo
@export var interaction_distance: float = 50.0  # Distância para interagir

@onready var body_sprite: AnimatedSprite2D = $Body
@onready var hair_sprite: AnimatedSprite2D = $Hair
var chat_icon: Node2D = null
var interaction_area: Area2D = null
var dialogue_box: CanvasLayer = null

var _current_animation: StringName = ""
var _facing_left: bool = false
var _player_nearby: bool = false
var _dialogue_manager: Node = null
var _dialogue_just_ended: bool = false  # Flag para evitar reiniciar diálogo imediatamente após fechar

func _ready() -> void:
	_facing_left = facing_left
	_apply_facing_direction()
	play_animation(start_animation)
	
	# Adicionar NPC ao grupo para facilitar busca
	add_to_group("npc")
	
	# Buscar nodes (podem não existir em todas as versões)
	chat_icon = get_node_or_null("ChatIcon")
	interaction_area = get_node_or_null("InteractionArea")
	dialogue_box = get_node_or_null("DialogueBox")
	
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
	
	# Conectar área clicável do ícone de chat
	if chat_icon:
		var icon_area = chat_icon.get_node_or_null("Area2D")
		if icon_area:
			icon_area.input_event.connect(_on_chat_icon_clicked)
	
	# Buscar DialogueManager
	_dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if not _dialogue_manager:
		# Tentar buscar na cena atual (pode estar em qualquer lugar da hierarquia)
		_dialogue_manager = get_node_or_null("/root/Vilarejo/DialogueManager")
	if not _dialogue_manager:
		# Tentar buscar em qualquer lugar
		_dialogue_manager = get_node_or_null("/root/DialogueManager")
	
	# Configurar dialogue box
	if dialogue_box:
		if dialogue_box.has_method("set_npc"):
			dialogue_box.set_npc(self)
	
	# Conectar sinal de término do diálogo para resetar flag
	if _dialogue_manager:
		_dialogue_manager.dialogue_ended.connect(_on_dialogue_ended_signal)

func play_animation(animation_name: StringName) -> void:
	if animation_name == _current_animation:
		return
	if not body_sprite.sprite_frames.has_animation(animation_name):
		push_warning("Body sprite does not have animation '%s'" % animation_name)
		return
	if not hair_sprite.sprite_frames.has_animation(animation_name):
		push_warning("Hair sprite does not have animation '%s'" % animation_name)
		return
	_current_animation = animation_name
	body_sprite.play(animation_name)
	hair_sprite.play(animation_name)

func get_current_animation() -> StringName:
	return _current_animation

func set_facing_left(enabled: bool) -> void:
	facing_left = enabled

func face_left() -> void:
	set_facing_left(true)

func face_right() -> void:
	set_facing_left(false)

func _apply_facing_direction() -> void:
	if not body_sprite or not hair_sprite:
		return
	body_sprite.flip_h = _facing_left
	hair_sprite.flip_h = _facing_left

func _process(_delta: float) -> void:
	# Verificar se o player está próximo
	if _player_nearby:
		# Verificar se o diálogo está ativo
		var dialogue_active = false
		if _dialogue_manager and _dialogue_manager.has_method("get_is_dialogue_active"):
			dialogue_active = _dialogue_manager.get_is_dialogue_active()
		elif _dialogue_manager and "is_dialogue_active" in _dialogue_manager:
			dialogue_active = _dialogue_manager.is_dialogue_active
		
		# Verificar se o diálogo ativo é deste NPC
		var is_this_npc_dialogue = false
		if dialogue_active and _dialogue_manager and "current_npc" in _dialogue_manager:
			is_this_npc_dialogue = (_dialogue_manager.current_npc == self)
		
		if not dialogue_active or not is_this_npc_dialogue:
			# Mostrar ícone de chat se o diálogo não estiver ativo ou não for deste NPC
			if chat_icon:
				chat_icon.show_icon()
			if dialogue_box:
				dialogue_box.visible = false
			
			# Verificar input para iniciar diálogo (só se não houver diálogo ativo deste NPC e não acabou de fechar)
			if not is_this_npc_dialogue and not _dialogue_just_ended and Input.is_action_just_pressed("ui_accept"):
				start_dialogue()
		else:
			# Esconder ícone quando diálogo deste NPC está ativo
			if chat_icon:
				chat_icon.hide_icon()
	else:
		# Esconder ícone de chat quando player está longe
		if chat_icon:
			chat_icon.hide_icon()
		if dialogue_box:
			dialogue_box.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		# Garantir que o ícone apareça quando o player volta, mesmo se o diálogo estava ativo antes
		# Verificar se há diálogo ativo deste NPC
		var dialogue_active = false
		if _dialogue_manager and _dialogue_manager.has_method("get_is_dialogue_active"):
			dialogue_active = _dialogue_manager.get_is_dialogue_active()
		elif _dialogue_manager and "is_dialogue_active" in _dialogue_manager:
			dialogue_active = _dialogue_manager.is_dialogue_active
		
		var is_this_npc_dialogue = false
		if dialogue_active and _dialogue_manager and "current_npc" in _dialogue_manager:
			is_this_npc_dialogue = (_dialogue_manager.current_npc == self)
		
		# Se não há diálogo ativo ou não é deste NPC, mostrar ícone
		if not dialogue_active or not is_this_npc_dialogue:
			if chat_icon:
				chat_icon.show_icon()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		if chat_icon:
			chat_icon.hide_icon()
		if dialogue_box:
			dialogue_box.visible = false
		# Garantir que o diálogo seja finalizado se o player sair
		if _dialogue_manager and _dialogue_manager.has_method("get_is_dialogue_active"):
			if _dialogue_manager.get_is_dialogue_active():
				if "current_npc" in _dialogue_manager and _dialogue_manager.current_npc == self:
					_dialogue_manager.end_dialogue()

func _input(event: InputEvent) -> void:
	if not _player_nearby:
		return
	
	# Verificar se o diálogo já está ativo (qualquer diálogo, não só deste NPC)
	var dialogue_active = false
	if _dialogue_manager and _dialogue_manager.has_method("get_is_dialogue_active"):
		dialogue_active = _dialogue_manager.get_is_dialogue_active()
	elif _dialogue_manager and "is_dialogue_active" in _dialogue_manager:
		dialogue_active = _dialogue_manager.is_dialogue_active
	
	# Se já há um diálogo ativo, não processar clique (evitar conflito com outros NPCs)
	if dialogue_active:
		return
	
	# Verificar se o diálogo ativo é deste NPC
	var is_this_npc_dialogue = false
	if dialogue_active and _dialogue_manager and "current_npc" in _dialogue_manager:
		is_this_npc_dialogue = (_dialogue_manager.current_npc == self)
	
	# Só bloquear se o diálogo ativo for deste NPC ou se acabou de fechar
	if is_this_npc_dialogue or _dialogue_just_ended:
		return  # Não iniciar novo diálogo se já houver um ativo deste NPC ou acabou de fechar
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_mouse_over_npc_or_icon():
			# Verificar novamente se não há diálogo ativo (pode ter sido iniciado por outro NPC neste frame)
			if _dialogue_manager and _dialogue_manager.has_method("get_is_dialogue_active"):
				if _dialogue_manager.get_is_dialogue_active():
					return
			elif _dialogue_manager and "is_dialogue_active" in _dialogue_manager:
				if _dialogue_manager.is_dialogue_active:
					return
			
			# Verificar qual NPC está mais próximo do clique
			if _is_closest_npc_to_click():
				start_dialogue()

func _is_mouse_over_npc_or_icon() -> bool:
	# Obter posição do mouse no mundo (considerando a câmera)
	var camera = get_viewport().get_camera_2d()
	var mouse_world_pos: Vector2
	
	if camera:
		# Usar a câmera para converter posição do mouse
		mouse_world_pos = camera.get_global_mouse_position()
	else:
		# Fallback: usar posição global do mouse
		mouse_world_pos = get_global_mouse_position()
	
	# Verificar se está próximo do NPC
	var npc_world_pos = global_position
	var npc_distance = mouse_world_pos.distance_to(npc_world_pos)
	
	# Verificar se está próximo do ícone de chat também
	var icon_world_pos = global_position + Vector2(0, -40)  # Posição aproximada do ícone
	var icon_distance = mouse_world_pos.distance_to(icon_world_pos)
	
	# Área de clique maior para facilitar a interação
	var click_radius = interaction_distance * 2.5
	return npc_distance <= click_radius or icon_distance <= 40.0

func _is_closest_npc_to_click() -> bool:
	# Obter posição do mouse no mundo
	var camera = get_viewport().get_camera_2d()
	var mouse_world_pos: Vector2
	
	if camera:
		mouse_world_pos = camera.get_global_mouse_position()
	else:
		mouse_world_pos = get_global_mouse_position()
	
	# Calcular distância deste NPC ao clique
	var npc_world_pos = global_position
	var my_distance = mouse_world_pos.distance_to(npc_world_pos)
	
	# Verificar se há outros NPCs mais próximos
	var all_npcs = get_tree().get_nodes_in_group("npc")
	if all_npcs.is_empty():
		# Se não há grupo de NPCs, tentar buscar todos os NPCs na cena
		all_npcs = _find_all_npcs_in_scene()
	
	# Verificar se este é o NPC mais próximo que também está próximo do player
	for npc in all_npcs:
		if npc == self:
			continue
		
		# Verificar se o outro NPC também está na área de clique
		var other_npc_pos = npc.global_position
		var other_distance = mouse_world_pos.distance_to(other_npc_pos)
		var click_radius = interaction_distance * 2.5
		
		# Se o outro NPC está na área de clique e mais próximo, não iniciar diálogo
		# (só verificar distância, não precisa verificar _player_nearby pois se está na área de clique, está próximo)
		if other_distance <= click_radius and other_distance < my_distance:
			return false
	
	return true

func _find_all_npcs_in_scene() -> Array:
	# Buscar todos os NPCs na cena atual
	var npcs = []
	var scene_root = get_tree().current_scene
	if scene_root:
		_find_npcs_recursive(scene_root, npcs)
	return npcs

func _find_npcs_recursive(node: Node, npcs: Array) -> void:
	# Verificar se este node é um NPC (tem o script npc.gd)
	if node.has_method("start_dialogue") and node != self:
		npcs.append(node)
	
	# Buscar recursivamente nos filhos
	for child in node.get_children():
		_find_npcs_recursive(child, npcs)

func is_player_nearby() -> bool:
	# Método público para verificar se o player está próximo (ícone de diálogo ativo)
	return _player_nearby

func start_dialogue() -> void:
	# Se o diálogo acabou de fechar, não iniciar imediatamente (evitar loop)
	if _dialogue_just_ended:
		return
	
	if not _dialogue_manager:
		push_error("DialogueManager not found for NPC: " + name)
		print("Tentando encontrar DialogueManager...")
		_dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
		if not _dialogue_manager:
			push_error("DialogueManager ainda não encontrado!")
			return
	
	if dialogue_file.is_empty():
		push_error("No dialogue file specified for NPC: " + name)
		print("Configure o 'Dialogue File' no Inspector do NPC")
		return
	
	print("Carregando diálogo de: ", dialogue_file)
	var dialogue_data = _dialogue_manager.load_dialogue_from_json(dialogue_file)
	if dialogue_data.is_empty():
		push_error("Failed to load dialogue for NPC: " + name + " from file: " + dialogue_file)
		return
	
	print("Iniciando diálogo com ", dialogue_data.size(), " linhas")
	_dialogue_manager.start_dialogue(self, dialogue_data)

func _on_chat_icon_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player_nearby and not _dialogue_just_ended:
			start_dialogue()

func _on_dialogue_ended_signal(npc_name: String) -> void:
	# Se o diálogo que terminou foi deste NPC, marcar flag
	if str(name) == npc_name:
		_dialogue_just_ended = true
		# Resetar flag após um pequeno delay para permitir nova interação
		await get_tree().create_timer(0.2).timeout
		_dialogue_just_ended = false
