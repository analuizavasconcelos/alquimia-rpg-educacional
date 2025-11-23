extends Control

# Analógico virtual (joystick) para mobile

signal joystick_updated(input_vector: Vector2)

@onready var background: ColorRect = $Background
@onready var stick: ColorRect = $Stick

var stick_radius: float = 50.0
var deadzone: float = 10.0
var is_dragging: bool = false
var center_position: Vector2
var touch_index: int = -1  # Índice do toque que está controlando o joystick

func _ready() -> void:
	# Configurar tamanho do joystick
	custom_minimum_size = Vector2(stick_radius * 2 + 20, stick_radius * 2 + 20)
	
	# Configurar background
	if background:
		background.size = Vector2(stick_radius * 2, stick_radius * 2)
		background.position = Vector2(10, 10)
	
	# Configurar stick
	if stick:
		stick.size = Vector2(stick_radius, stick_radius)
		stick.position = Vector2(10 + stick_radius / 2, 10 + stick_radius / 2)
	
	center_position = Vector2(stick_radius + 10, stick_radius + 10)
	
	# Permitir que o joystick receba input e pare a propagação
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Garantir que o joystick processa input mesmo quando não está visível
	# (para evitar que eventos passem através quando está escondido)
	set_process_input(true)

func _is_point_in_joystick_area(point: Vector2) -> bool:
	# Verificar se o ponto está na área do joystick
	var global_rect = get_global_rect()
	if not global_rect.has_point(point):
		return false
	
	var local_pos = global_rect.get_center()
	var distance = point.distance_to(local_pos)
	return distance <= stick_radius + 50  # Área de ativação maior

func _input(event: InputEvent) -> void:
	# Suporte para toque (mobile)
	if event is InputEventScreenTouch:
		var touch_pos = event.position
		
		if event.pressed:
			# Se não está arrastando e o toque está na área do joystick
			if not is_dragging and _is_point_in_joystick_area(touch_pos):
				is_dragging = true
				touch_index = event.index
				_update_stick_position(touch_pos)
				# Parar propagação do evento
				var viewport = get_viewport()
				if viewport:
					viewport.set_input_as_handled()
		else:
			# Se este é o toque que estava controlando o joystick
			if is_dragging and event.index == touch_index:
				is_dragging = false
				touch_index = -1
				_reset_stick()
				# Parar propagação do evento
				var viewport = get_viewport()
				if viewport:
					viewport.set_input_as_handled()
	
	elif event is InputEventScreenDrag:
		# Se este é o toque que está controlando o joystick
		if is_dragging and event.index == touch_index:
			_update_stick_position(event.position)
			# Parar propagação do evento
			var viewport = get_viewport()
			if viewport:
				viewport.set_input_as_handled()
	
	# Suporte para mouse (desktop para testes)
	elif event is InputEventMouseButton:
		var mouse_pos = event.position
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Se o clique está na área do joystick
				if not is_dragging and _is_point_in_joystick_area(mouse_pos):
					is_dragging = true
					touch_index = 0  # Usar índice 0 para mouse
					_update_stick_position(mouse_pos)
					# Parar propagação do evento
					var viewport = get_viewport()
					if viewport:
						viewport.set_input_as_handled()
			else:
				# Soltar o mouse
				if is_dragging and touch_index == 0:
					is_dragging = false
					touch_index = -1
					_reset_stick()
					# Parar propagação do evento
					var viewport = get_viewport()
					if viewport:
						viewport.set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		# Se está arrastando com o mouse
		if is_dragging and touch_index == 0:
			_update_stick_position(event.position)
			# Parar propagação do evento
			var viewport = get_viewport()
			if viewport:
				viewport.set_input_as_handled()

func _update_stick_position(touch_pos: Vector2) -> void:
	if not stick:
		return
	
	# Converter posição global para local
	var global_rect = get_global_rect()
	var local_pos = global_rect.get_center()
	var offset = touch_pos - local_pos
	var distance = offset.length()
	
	# Limitar distância ao raio do joystick
	if distance > stick_radius:
		offset = offset.normalized() * stick_radius
		distance = stick_radius
	
	# Atualizar posição do stick
	stick.position = center_position + offset - Vector2(stick_radius / 2, stick_radius / 2)
	
	# Calcular input normalizado
	var input_vector = Vector2.ZERO
	if distance > deadzone:
		input_vector = offset.normalized()
		# Aplicar curva de sensibilidade (mais suave próximo ao centro)
		var normalized_distance = (distance - deadzone) / (stick_radius - deadzone)
		input_vector *= normalized_distance
	
	joystick_updated.emit(input_vector)

func _reset_stick() -> void:
	if stick:
		stick.position = center_position - Vector2(stick_radius / 2, stick_radius / 2)
	joystick_updated.emit(Vector2.ZERO)

func _process(_delta: float) -> void:
	# Se não está arrastando, resetar gradualmente
	if not is_dragging and stick:
		var target_pos = center_position - Vector2(stick_radius / 2, stick_radius / 2)
		stick.position = stick.position.lerp(target_pos, 0.2)

