extends CanvasLayer

@onready var control: Control = $Control
@onready var title_label: Label = $Control/Panel/VBox/TitleLabel
@onready var name_label: Label = $Control/Panel/VBox/NameLabel
@onready var description_label: Label = $Control/Panel/VBox/DescriptionLabel

var tween: Tween

func _ready() -> void:
	visible = false
	if control:
		control.visible = false
	
	# Conectar ao knowledge_manager
	var knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	if knowledge_manager:
		knowledge_manager.knowledge_unlocked.connect(_on_knowledge_unlocked)

func _on_knowledge_unlocked(_knowledge_id: String, knowledge_name: String, knowledge_description: String) -> void:
	# Atualizar textos
	name_label.text = knowledge_name
	description_label.text = knowledge_description
	
	# Mostrar notificação
	show_notification()

func show_notification() -> void:
	visible = true
	if control:
		control.visible = true
	
	# Animação de entrada (deslizar de cima)
	control.position.y = -150.0
	control.modulate.a = 0.0
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(control, "modulate:a", 1.0, 0.3)
	
	# Aguardar e esconder automaticamente
	await get_tree().create_timer(3.0).timeout
	hide_notification()

func hide_notification() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position:y", -150.0, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(control, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	visible = false
	if control:
		control.visible = false

