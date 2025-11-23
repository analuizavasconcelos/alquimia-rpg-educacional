extends Control

# Menu rápido (pausa) com opções: Glossário, Continuar, Novo Jogo, Sair

@onready var panel: Panel = $Panel
@onready var glossary_button: Button = $Panel/VBox/GlossaryButton
@onready var continue_button: Button = $Panel/VBox/ContinueButton
@onready var new_game_button: Button = $Panel/VBox/NewGameButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	# Conectar botões
	if glossary_button:
		glossary_button.pressed.connect(_on_glossary_pressed)
		print("GlossaryButton conectado")
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		print("ContinueButton conectado")
	
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
		print("NewGameButton conectado")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("QuitButton conectado")
	
	# Esconder inicialmente
	visible = false
	
	# Garantir que os botões funcionem mesmo quando o jogo está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# Fechar menu com ESC ou botão de voltar (Android)
	if visible and (event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE)):
		_close_menu()

func _on_glossary_pressed() -> void:
	print("GlossaryButton pressionado!")
	# Parar propagação do evento
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
	# Abrir glossário de conhecimentos
	var glossary = get_tree().get_first_node_in_group("knowledge_glossary")
	
	if not glossary:
		print("⚠️ KnowledgeGlossary não encontrado!")
		_close_menu()
		return
	
	print("✅ KnowledgeGlossary encontrado: ", glossary.name)
	
	# Verificar se não há diálogo ativo antes de abrir
	var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	var dialogue_active = false
	if dialogue_manager and dialogue_manager.has_method("get_is_dialogue_active"):
		dialogue_active = dialogue_manager.get_is_dialogue_active()
	
	if dialogue_active:
		print("⚠️ Não é possível abrir glossário durante diálogo!")
		_close_menu()
		return
	
	# Usar o método open_glossary
	if glossary.has_method("open_glossary"):
		print("📖 Chamando open_glossary()...")
		glossary.open_glossary()
		print("✅ open_glossary() chamado. Visível: ", glossary.visible)
	else:
		print("⚠️ Método open_glossary() não encontrado, usando visible diretamente")
		if "visible" in glossary:
			glossary.visible = true
			# Se tem método para atualizar lista, chamar
			if glossary.has_method("_update_knowledge_list"):
				glossary._update_knowledge_list()
	
	_close_menu()

func _on_continue_pressed() -> void:
	print("ContinueButton pressionado!")
	# Parar propagação do evento
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
	# Fechar menu e continuar jogo
	_close_menu()

func _on_new_game_pressed() -> void:
	print("NewGameButton pressionado!")
	# Parar propagação do evento
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
	# Deletar save e reiniciar
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager:
		save_manager.delete_save()
	
	# Limpar conhecimentos
	var knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	if knowledge_manager and "unlocked_knowledge" in knowledge_manager:
		knowledge_manager.unlocked_knowledge.clear()
	
	# Voltar ao menu principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_quit_pressed() -> void:
	print("QuitButton pressionado!")
	# Parar propagação do evento
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
	get_tree().quit()

func _close_menu() -> void:
	visible = false
	get_tree().paused = false

func show_menu() -> void:
	visible = true
	get_tree().paused = true

