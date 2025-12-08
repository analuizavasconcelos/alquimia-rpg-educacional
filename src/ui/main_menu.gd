extends Control

signal new_game_pressed
signal continue_pressed
signal quit_pressed

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var vbox_container: VBoxContainer = $VBoxContainer

var _button_tween: Tween = null

func _ready() -> void:
	# Verificar se os nós estão prontos
	if not continue_button or not new_game_button or not quit_button or not vbox_container:
		push_error("❌ Erro: Alguns nós do menu não foram encontrados!")
		return
	
	# Conectar sinais dos botões
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Conectar sinais de hover para animações
	continue_button.mouse_entered.connect(_on_continue_hover)
	continue_button.mouse_exited.connect(_on_continue_exit)
	new_game_button.mouse_entered.connect(_on_new_game_hover)
	new_game_button.mouse_exited.connect(_on_new_game_exit)
	quit_button.mouse_entered.connect(_on_quit_hover)
	quit_button.mouse_exited.connect(_on_quit_exit)
	
	# Verificar se há um jogo salvo para habilitar/desabilitar o botão Continuar
	_update_continue_button()
	
	# Animação de entrada do menu
	_animate_menu_entrance()

func _update_continue_button() -> void:
	if not continue_button:
		return
	# Verificar se existe um save game
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager and save_manager.has_save_file():
		continue_button.disabled = false
		print("✅ Save encontrado - Botão Continuar habilitado")
	else:
		continue_button.disabled = true
		print("ℹ️ Nenhum save encontrado - Botão Continuar desabilitado")

func _animate_menu_entrance() -> void:
	if not vbox_container:
		return
	# Fade in do menu
	vbox_container.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(vbox_container, "modulate:a", 1.0, 0.5)
	
	# Pequena animação de escala
	vbox_container.scale = Vector2(0.9, 0.9)
	tween.parallel().tween_property(vbox_container, "scale", Vector2(1.0, 1.0), 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

func _on_continue_hover() -> void:
	if continue_button:
		_animate_button_hover(continue_button)

func _on_continue_exit() -> void:
	if continue_button:
		_animate_button_exit(continue_button)

func _on_new_game_hover() -> void:
	if new_game_button:
		_animate_button_hover(new_game_button)

func _on_new_game_exit() -> void:
	if new_game_button:
		_animate_button_exit(new_game_button)

func _on_quit_hover() -> void:
	if quit_button:
		_animate_button_hover(quit_button)

func _on_quit_exit() -> void:
	if quit_button:
		_animate_button_exit(quit_button)

func _animate_button_hover(button: Button) -> void:
	# Animação sutil ao passar o mouse
	if _button_tween:
		_button_tween.kill()
	
	_button_tween = create_tween()
	_button_tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)
	_button_tween.set_ease(Tween.EASE_OUT)

func _animate_button_exit(button: Button) -> void:
	# Resetar escala quando o mouse sair
	if _button_tween:
		_button_tween.kill()
	
	_button_tween = create_tween()
	_button_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	_button_tween.set_ease(Tween.EASE_OUT)

func _on_continue_pressed() -> void:
	if not continue_button or continue_button.disabled:
		return
	continue_pressed.emit()
	_load_game()

func _on_new_game_pressed() -> void:
	new_game_pressed.emit()
	_start_new_game()

func _on_quit_pressed() -> void:
	quit_pressed.emit()
	_quit_game()

func _load_game() -> void:
	# Marcar que deve carregar save na próxima cena
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager and save_manager.has_save_file():
		save_manager.should_load_on_next_scene = true
	
	# Transicionar para a cena do jogo
	_transition_to_scene("res://scenes/levels/vilarejo.tscn")

func _start_new_game() -> void:
	# Deletar save existente para iniciar novo jogo
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager:
		save_manager.delete_save()
		print("🆕 Novo jogo iniciado - Save anterior deletado")
	
	# Limpar conhecimentos desbloqueados
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	if knowledge_manager and "unlocked_knowledge" in knowledge_manager:
		knowledge_manager.unlocked_knowledge.clear()
		print("🆕 Conhecimentos resetados")
	
	# Transicionar para a cena do jogo
	_transition_to_scene("res://scenes/levels/vilarejo.tscn")

func _transition_to_scene(scene_path: String) -> void:
	# Animação de saída antes de trocar de cena
	if vbox_container:
		var tween = create_tween()
		tween.tween_property(vbox_container, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
	else:
		get_tree().change_scene_to_file(scene_path)

func _quit_game() -> void:
	# Animação de saída antes de fechar
	if vbox_container:
		var tween = create_tween()
		tween.tween_property(vbox_container, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): get_tree().quit())
	else:
		get_tree().quit()
