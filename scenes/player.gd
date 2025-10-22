extends CharacterBody2D

@export var speed: float = 200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
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

