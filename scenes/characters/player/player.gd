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
