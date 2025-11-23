extends CharacterBody2D

@export var speed: float = 100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var dialogue_manager: Node = null

func _ready() -> void:
	add_to_group("player")
	# Buscar DialogueManager
	dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if not dialogue_manager:
		dialogue_manager = get_node_or_null("/root/Vilarejo/DialogueManager")
	
	# Verificar se deve spawnar próximo ao well
	_check_spawn_at_well()

func _physics_process(_delta: float) -> void:
	# Verificar se há diálogo ativo - se sim, travar movimentação
	var dialogue_active = false
	if dialogue_manager:
		if dialogue_manager.has_method("get_is_dialogue_active"):
			dialogue_active = dialogue_manager.get_is_dialogue_active()
		elif "is_dialogue_active" in dialogue_manager:
			dialogue_active = dialogue_manager.is_dialogue_active
	
	# Verificar se o glossário está aberto
	var glossary = get_tree().get_first_node_in_group("knowledge_glossary")
	var glossary_open = false
	if glossary and glossary.visible:
		glossary_open = true
	
	# Se há diálogo ativo ou glossário aberto, não permitir movimentação
	if dialogue_active or glossary_open:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		return
	
	# Pegar direção do input
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
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
