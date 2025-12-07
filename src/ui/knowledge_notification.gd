extends CanvasLayer

@onready var control: Control = $Control
@onready var panel: Panel = $Control/Panel
@onready var title_label: Label = $Control/Panel/VBox/TitleLabel
@onready var name_label: Label = $Control/Panel/VBox/NameLabel
@onready var description_label: Label = $Control/Panel/VBox/DescriptionLabel

var tween: Tween
var is_showing: bool = false

func _ready() -> void:
	visible = false
	if control:
		control.visible = false
	
	# Tornar o painel clicável
	if panel:
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.gui_input.connect(_on_panel_clicked)
	
	# Conectar ao knowledge_manager
	var knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	if knowledge_manager:
		knowledge_manager.knowledge_unlocked.connect(_on_knowledge_unlocked)
	
	# Conectar ao dialogue_manager para esconder quando o diálogo avançar
	var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if dialogue_manager:
		dialogue_manager.dialogue_next.connect(_on_dialogue_next)

func _on_knowledge_unlocked(_knowledge_id: String, knowledge_name: String, knowledge_description: String) -> void:
	# Atualizar textos
	name_label.text = knowledge_name
	description_label.text = knowledge_description
	
	# Mostrar notificação
	show_notification()

func show_notification() -> void:
	is_showing = true
	visible = true
	if control:
		control.visible = true
	
	# Animação de entrada (deslizar de cima)
	control.position.y = -250.0
	control.modulate.a = 0.0
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(control, "modulate:a", 1.0, 0.3)
	
	# NÃO esconder automaticamente - aguardar interação do jogador

func hide_notification() -> void:
	if not is_showing:
		return
	
	is_showing = false
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position:y", -250.0, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(control, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	visible = false
	if control:
		control.visible = false

func _on_panel_clicked(event: InputEvent) -> void:
	if is_showing and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_notification()

func _on_dialogue_next(_line: String) -> void:
	# Esconder o popup quando o diálogo avançar
	if is_showing:
		hide_notification()

