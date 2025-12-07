extends CharacterBody2D

@export var speed: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
var dialogue_manager: Node = null

func _ready() -> void:
	add_to_group("player")
	# Buscar DialogueManager
	dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if not dialogue_manager:
		dialogue_manager = get_node_or_null("/root/Vilarejo/DialogueManager")
	
	# Restaurar zoom da câmera se houver um salvo (usar call_deferred para garantir que camera está pronta)
	call_deferred("_restore_camera_zoom")
	
	# Verificar se deve spawnar próximo ao well
	_check_spawn_at_well()

func _restore_camera_zoom() -> void:
	var transition_manager = get_node_or_null("/root/SceneTransitionManager")
	if transition_manager:
		var saved_zoom = transition_manager.get_saved_camera_zoom()
		if saved_zoom != Vector2.ZERO and camera:
			camera.zoom = saved_zoom
			print("📷 Zoom da câmera restaurado: ", saved_zoom)

func _exit_tree() -> void:
	# Salvar zoom da câmera antes de sair da cena
	if camera:
		var transition_manager = get_node_or_null("/root/SceneTransitionManager")
		if transition_manager:
			transition_manager.save_camera_zoom(camera.zoom)
			print("📷 Zoom da câmera salvo: ", camera.zoom)

func _physics_process(_delta: float) -> void:
	# Verificar se há diálogo REALMENTE ativo - usar verificação rigorosa
	var dialogue_really_active = _is_dialogue_really_active()
	
	# Verificar se o glossário está aberto
	var glossary = get_tree().get_first_node_in_group("knowledge_glossary")
	var glossary_open = false
	if glossary and glossary.visible:
		glossary_open = true
	
	# Se há diálogo realmente ativo ou glossário aberto, não permitir movimentação
	if dialogue_really_active or glossary_open:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		return
	
	# Pegar direção do input (teclado ou joystick mobile)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Se não há input do teclado, verificar joystick mobile
	if direction == Vector2.ZERO:
		var mobile_controls = get_tree().get_first_node_in_group("mobile_controls")
		if mobile_controls and mobile_controls.has_method("get_joystick_input"):
			direction = mobile_controls.get_joystick_input()
	
	# Definir velocidade
	velocity = direction * speed
	
	# Atualizar animação
	update_animation(direction)
	
	# Mover o personagem
	move_and_slide()

func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		# Se está se movendo, executa animação run
		animated_sprite.play("run")
		
		# Flip horizontal baseado na direção
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
	else:
		# Se está parado, executa animação idle
		animated_sprite.play("idle")

# Função para verificar rigorosamente se o diálogo está realmente ativo
func _is_dialogue_really_active() -> bool:
	if not dialogue_manager:
		return false
	
	# Verificação 1: is_dialogue_active flag
	var dialogue_active = false
	if dialogue_manager.has_method("get_is_dialogue_active"):
		dialogue_active = dialogue_manager.get_is_dialogue_active()
	elif "is_dialogue_active" in dialogue_manager:
		dialogue_active = dialogue_manager.is_dialogue_active
	
	if not dialogue_active:
		return false
	
	# Verificação 2: current_dialogue não está vazio
	if "current_dialogue" in dialogue_manager:
		var current_dialogue = dialogue_manager.current_dialogue
		if not current_dialogue or current_dialogue.size() == 0:
			return false
	
	# Verificação 3: Verificar se há algum DialogueBox visível
	var root = get_tree().current_scene
	var has_visible_box = false
	
	if root:
		# Buscar DialogueBox (Control simples)
		var dialogue_box_nodes = _find_nodes_by_name(root, "DialogueBox")
		for node in dialogue_box_nodes:
			if node and node.visible:
				has_visible_box = true
				break
		
		# Buscar NPCDialogueBox (CanvasLayer com Control dentro)
		if not has_visible_box:
			var npc_dialogue_nodes = _find_nodes_by_name(root, "NPCDialogueBox")
			for node in npc_dialogue_nodes:
				# Verificar se o CanvasLayer está visível
				if node and node.visible:
					# Verificar também o Control dentro dele
					var control_node = node.get_node_or_null("Control")
					if control_node and control_node.visible:
						has_visible_box = true
						break
					# Se o CanvasLayer está visível, considerar como diálogo ativo
					has_visible_box = true
					break
	
	# Todas as verificações devem passar
	return dialogue_active and has_visible_box

# Função auxiliar para buscar nodes por nome recursivamente
func _find_nodes_by_name(node: Node, name_to_find: String) -> Array:
	var result = []
	if node.name == name_to_find:
		result.append(node)
	
	for child in node.get_children():
		result.append_array(_find_nodes_by_name(child, name_to_find))
	
	return result

func _check_spawn_at_well() -> void:
	var transition_manager = get_node_or_null("/root/SceneTransitionManager")
	if not transition_manager:
		return
	
	# Verificar se deve spawnar próximo ao well
	if transition_manager.get_spawn_at_well():
		# Limpar a flag
		transition_manager.clear_spawn_flag()
		
		# Aguardar um frame para garantir que a cena está totalmente carregada
		await get_tree().process_frame
		
		# Procurar pelo well na cena
		var well = null
		
		# Primeiro tentar pelo grupo
		var wells = get_tree().get_nodes_in_group("well")
		if not wells.is_empty():
			well = wells[0]
		else:
			# Tentar encontrar por nome "Well" na cena
			var scene_root = get_tree().current_scene
			if scene_root:
				well = scene_root.get_node_or_null("Well")
		
		if well:
			# Posicionar o player próximo ao well (um pouco acima e à direita)
			var well_position = well.global_position
			global_position = well_position + Vector2(30, -20)
