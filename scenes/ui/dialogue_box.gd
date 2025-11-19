extends Control

@onready var label: Label = $Panel/Label
@onready var next_label: Label = $Panel/NextLabel

var dialogue_manager: Node

func _ready() -> void:
	visible = false
	dialogue_manager = get_node_or_null("/root/DialogueManager")
	if dialogue_manager:
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
		dialogue_manager.dialogue_next.connect(_on_dialogue_next)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if dialogue_manager:
			dialogue_manager.show_next_line()

func _on_dialogue_started(_npc_name: String) -> void:
	visible = true

func _on_dialogue_ended(_npc_name: String) -> void:
	visible = false
	label.text = ""

func _on_dialogue_next(line: String) -> void:
	label.text = line

