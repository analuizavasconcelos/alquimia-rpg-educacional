extends CanvasLayer

# Gerenciador de controles mobile
# Inclui: analógico virtual, botão de interação, menu rápido

@onready var control: Control = $Control
@onready var joystick: Control = $Control/Joystick
@onready var interact_button: Button = $Control/InteractButton
@onready var menu_button: Button = $Control/MenuButton
@onready var quick_menu: Control = $Control/QuickMenu

var joystick_input: Vector2 = Vector2.ZERO
var is_interacting: bool = false
var _controls_enabled_manually: bool = false

func _ready() -> void:
	add_to_group("mobile_controls")
	
	# Configurar mouse_filter para capturar eventos apenas quando necessário
	# O Control principal deve passar eventos para os filhos, mas os filhos devem parar
	if control:
		control.mouse_filter = Control.MOUSE_FILTER_PASS  # Passar eventos para filhos
	
	# Restaurar estado da HUD se houver um salvo
	_restore_hud_state()
	
	# Verificar se está em mobile e mostrar/ocultar controles
	_update_controls_visibility()
	
	# Conectar botões
	if interact_button:
		interact_button.pressed.connect(_on_interact_pressed)
		# Garantir que botões capturam eventos
		interact_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_button_pressed)
		# Garantir que botões capturam eventos
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Configurar joystick
	if joystick:
		joystick.joystick_updated.connect(_on_joystick_updated)
		# Garantir que joystick captura eventos
		joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Esconder menu rápido inicialmente
	if quick_menu:
		quick_menu.visible = false
	
	# Conectar aos sinais do dialogue_manager para esconder controles durante diálogo
	# Usar call_deferred para garantir que o dialogue_manager está pronto
	call_deferred("_connect_dialogue_signals")

func _restore_hud_state() -> void:
	var transition_manager = get_node_or_null("/root/SceneTransitionManager")
	if transition_manager:
		var hud_state = transition_manager.get_saved_mobile_hud_state()
		if hud_state.has("enabled") and hud_state.has("manual"):
			_controls_enabled_manually = hud_state["manual"]
			print("📱 Estado da HUD mobile restaurado - enabled: ", hud_state["enabled"], ", manual: ", hud_state["manual"])

func _get_hud_state() -> Dictionary:
	# Método público para obter o estado atual da HUD
	var is_mobile = OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS")
	var hud_enabled = is_mobile or _controls_enabled_manually
	return {
		"enabled": hud_enabled,
		"manual": _controls_enabled_manually
	}

func _exit_tree() -> void:
	# Salvar estado da HUD antes de sair da cena
	var hud_state = _get_hud_state()
	var transition_manager = get_node_or_null("/root/SceneTransitionManager")
	if transition_manager:
		transition_manager.save_mobile_hud_state(hud_state["enabled"], hud_state["manual"])
		print("📱 Estado da HUD mobile salvo - enabled: ", hud_state["enabled"], ", manual: ", hud_state["manual"])

func _update_controls_visibility() -> void:
	# Detectar se está em mobile
	var is_mobile = OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS")
	
	# Mostrar controles em mobile ou se estiver habilitado manualmente
	# Para habilitar no desktop, pressione F1
	var should_show = is_mobile or _controls_enabled_manually
	
	# Verificar se há diálogo ativo - usar verificação rigorosa
	if _is_dialogue_really_active():
		should_show = false
		print("  ⚠️ Diálogo ativo detectado em _update_controls_visibility (verificação rigorosa) - não mostrando controles")
	else:
		# Se não há diálogo ativo, garantir que os controles estejam visíveis (se habilitados)
		if is_mobile or _controls_enabled_manually:
			should_show = true
	
	# Atualizar visibilidade do controle principal
	if control:
		control.visible = should_show
	visible = should_show
	
	# Garantir que os elementos filhos também estejam visíveis
	# Usar call_deferred para garantir que os nós estão prontos
	call_deferred("_update_children_visibility", should_show)
	
	print("Controles mobile visibility: ", should_show, " (mobile: ", is_mobile, ", manual: ", _controls_enabled_manually, ")")

func _update_children_visibility(should_show: bool) -> void:
	# Verificar se há diálogo ativo usando verificação rigorosa
	if _is_dialogue_really_active():
		should_show = false
		print("  ⚠️ Diálogo ativo detectado em _update_children_visibility (verificação rigorosa) - escondendo controles")
	else:
		# Se não há diálogo ativo e should_show é true, garantir que os controles estejam visíveis
		# (não sobrescrever should_show se já for false por outras razões)
		pass
	
	if joystick:
		joystick.visible = should_show
		joystick.mouse_filter = Control.MOUSE_FILTER_STOP if should_show else Control.MOUSE_FILTER_IGNORE
	if interact_button:
		interact_button.visible = should_show
		interact_button.disabled = not should_show
		interact_button.mouse_filter = Control.MOUSE_FILTER_STOP if should_show else Control.MOUSE_FILTER_IGNORE
	if menu_button:
		menu_button.visible = should_show
		menu_button.disabled = not should_show
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP if should_show else Control.MOUSE_FILTER_IGNORE
	
	var dialogue_really_active = _is_dialogue_really_active()
	var joystick_vis = joystick.visible if joystick else false
	var interact_vis = interact_button.visible if interact_button else false
	var menu_vis = menu_button.visible if menu_button else false
	print("  - Joystick: ", joystick_vis, " (should_show: ", should_show, ", dialogue_really_active: ", dialogue_really_active, ")")
	print("  - InteractButton: ", interact_vis, " (should_show: ", should_show, ", dialogue_really_active: ", dialogue_really_active, ")")
	print("  - MenuButton: ", menu_vis, " (should_show: ", should_show, ", dialogue_really_active: ", dialogue_really_active, ")")

func _input(event: InputEvent) -> void:
	# Tecla F1 para habilitar/desabilitar controles mobile (útil para testes)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			_controls_enabled_manually = not _controls_enabled_manually
			_update_controls_visibility()
			print("Controles mobile: ", "HABILITADOS" if _controls_enabled_manually else "DESABILITADOS")

# Obter input do joystick
func get_joystick_input() -> Vector2:
	return joystick_input

# Verificar se botão de interação foi pressionado
func get_interact_pressed() -> bool:
	if is_interacting:
		is_interacting = false
		return true
	return false

func _on_joystick_updated(input_vector: Vector2) -> void:
	joystick_input = input_vector

func _on_interact_pressed() -> void:
	print("🔘 Botão Interagir pressionado")
	is_interacting = true
	# Parar propagação do evento para evitar que ative interações no cenário
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()
	# Verificar estado ANTES de tentar interagir
	var tree = get_tree()
	if not tree or not is_inside_tree():
		return
	var dialogue_manager = tree.get_first_node_in_group("dialogue_manager")
	var dialogue_active_before = false
	if dialogue_manager:
		if dialogue_manager.has_method("get_is_dialogue_active"):
			dialogue_active_before = dialogue_manager.get_is_dialogue_active()
		elif "is_dialogue_active" in dialogue_manager:
			dialogue_active_before = dialogue_manager.is_dialogue_active
	
	print("  Estado do diálogo ANTES de interagir: ", dialogue_active_before)
	var hud_visible_before = control.visible if control else false
	print("  HUD visível ANTES: ", hud_visible_before)
	
	# Simular clique próximo ao player para interagir
	_try_interact()
	
	# Verificar estado DEPOIS de tentar interagir
	if tree and is_inside_tree():
		await tree.process_frame
		# Verificar novamente se ainda está na árvore após o await
		if not is_inside_tree() or not tree:
			return
	var dialogue_active_after = false
	if dialogue_manager:
		if dialogue_manager.has_method("get_is_dialogue_active"):
			dialogue_active_after = dialogue_manager.get_is_dialogue_active()
		elif "is_dialogue_active" in dialogue_manager:
			dialogue_active_after = dialogue_manager.is_dialogue_active
	
	print("  Estado do diálogo DEPOIS de interagir: ", dialogue_active_after)
	var hud_visible_after = control.visible if control else false
	print("  HUD visível DEPOIS: ", hud_visible_after)
	
	# Se o diálogo não começou, garantir que a HUD está visível
	if not dialogue_active_after:
		var is_mobile = OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS")
		var should_show = is_mobile or _controls_enabled_manually
		if control:
			if not control.visible and should_show:
				print("  ⚠️ HUD estava escondida sem diálogo ativo! Restaurando...")
				control.visible = true
				visible = true
			# Garantir que os elementos filhos também estejam visíveis
			if should_show:
				# Aguardar um frame para garantir que o estado está correto
				var tree_check = get_tree()
				if tree_check and is_inside_tree():
					await tree_check.process_frame
					# Verificar novamente se ainda está na árvore após o await
					if not is_inside_tree():
						return
				# Verificar novamente se o diálogo não está ativo antes de mostrar
				var dialogue_manager_check = null
				if tree_check and is_inside_tree():
					dialogue_manager_check = tree_check.get_first_node_in_group("dialogue_manager")
				else:
					return
				var dialogue_still_active = false
				if dialogue_manager_check:
					if dialogue_manager_check.has_method("get_is_dialogue_active"):
						dialogue_still_active = dialogue_manager_check.get_is_dialogue_active()
					elif "is_dialogue_active" in dialogue_manager_check:
						dialogue_still_active = dialogue_manager_check.is_dialogue_active
				
				if not dialogue_still_active:
					_update_children_visibility(should_show)
				else:
					print("  ⚠️ Diálogo ficou ativo após interação - mantendo HUD escondida")

func _on_menu_button_pressed() -> void:
	if quick_menu:
		quick_menu.visible = not quick_menu.visible
		# Pausar/despausar jogo quando menu está aberto
		get_tree().paused = quick_menu.visible
	# Parar propagação do evento para evitar que ative interações no cenário
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()

func _try_interact() -> void:
	# Verificar se ainda está na árvore da cena
	var tree = get_tree()
	if not tree or not is_inside_tree():
		print("⚠️ MobileControls: Não está na árvore da cena, não é possível interagir")
		return
	
	# Buscar player
	var player = tree.get_first_node_in_group("player")
	if not player:
		print("⚠️ MobileControls: Player não encontrado")
		return
	
	# Buscar NPCs próximos - verificar se o ícone de diálogo está ativo
	var npcs = tree.get_nodes_in_group("npc")
	var closest_npc = null
	var closest_distance = 999999.0
	
	for npc in npcs:
		# Verificar se o NPC detecta o player próximo (ícone de diálogo ativo)
		var player_nearby = false
		if npc.has_method("is_player_nearby"):
			player_nearby = npc.is_player_nearby()
		elif "_player_nearby" in npc:
			player_nearby = npc._player_nearby
		
		# Se o ícone de diálogo está ativo, este NPC pode ser interagido
		if player_nearby:
			var distance = player.global_position.distance_to(npc.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_npc = npc
	
	# Se encontrou NPC com ícone de diálogo ativo, interagir
	# A HUD será escondida automaticamente quando o diálogo começar (via sinal dialogue_started)
	if closest_npc and closest_npc.has_method("start_dialogue"):
		print("🔘 Interagindo com NPC: ", closest_npc.name)
		closest_npc.start_dialogue()
		# Não esconder aqui - deixar o sinal dialogue_started fazer isso
		return
	
	# Buscar poço próximo - verificar se o ícone do portal está ativo
	var wells = tree.get_nodes_in_group("well")
	for well in wells:
		# Verificar se o well detecta o player próximo (ícone do portal ativo)
		var player_nearby = false
		if well.has_method("is_player_nearby"):
			player_nearby = well.is_player_nearby()
		elif "_player_nearby" in well:
			player_nearby = well._player_nearby
		
		# Se o ícone do portal está ativo, o well pode ser interagido
		if player_nearby and well.has_method("interact"):
			print("🔘 Interagindo com Well (player_nearby: ", player_nearby, ")")
			well.interact()
			return
		elif well.has_method("interact"):
			print("⚠️ Well encontrado mas player não está próximo (player_nearby: ", player_nearby, ")")

	# Buscar mesa de alquimia próxima
	for table in tree.get_nodes_in_group("alchemy_table"):
		if table.has_method("is_player_nearby") and table.is_player_nearby() and table.has_method("interact"):
			print("🔘 Interagindo com a Mesa de Alquimia")
			table.interact()
			return

	# Buscar porta de interior próxima (ex.: biblioteca)
	for door in tree.get_nodes_in_group("interior_door"):
		if door.has_method("is_player_nearby") and door.is_player_nearby() and door.has_method("interact"):
			print("🔘 Interagindo com a porta")
			door.interact()
			return

# Função para verificar rigorosamente se o diálogo está realmente ativo
func _is_dialogue_really_active() -> bool:
	var tree = get_tree()
	if not tree or not is_inside_tree():
		return false
	var dialogue_manager = tree.get_first_node_in_group("dialogue_manager")
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
	# Buscar recursivamente por DialogueBox e NPCDialogueBox
	if not tree:
		return false
	var root = tree.current_scene
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

func _on_dialogue_started(_npc_name: String) -> void:
	# Esconder controles mobile APENAS quando o diálogo realmente começar
	print("💬 Sinal dialogue_started recebido para NPC: ", _npc_name)
	# Aguardar múltiplos frames para garantir que tudo está sincronizado
	var tree = get_tree()
	if tree and is_inside_tree():
		await tree.process_frame
		# Verificar se ainda está na árvore após o await
		if not is_inside_tree():
			return
		if tree and is_inside_tree():
			await tree.process_frame
			# Verificar novamente se ainda está na árvore
			if not is_inside_tree():
				return
	
	# Verificação rigorosa múltipla
	var is_really_active = _is_dialogue_really_active()
	
	if is_really_active:
		print("  ✅ Diálogo confirmado ativo (verificação rigorosa) - escondendo HUD mobile")
		_hide_controls_during_dialogue()
	else:
		print("  ⚠️ Sinal dialogue_started recebido mas diálogo NÃO está realmente ativo!")
		print("     - dialogue_active: ", _get_dialogue_active_state())
		print("     - dialogue_box visível: ", _has_visible_dialogue_box())
		print("     - HUD permanece visível.")
		# Garantir que a HUD está visível se o diálogo não está ativo
		_show_controls_after_dialogue()

# Funções auxiliares para debug
func _get_dialogue_active_state() -> bool:
	var tree = get_tree()
	if not tree or not is_inside_tree():
		return false
	var dialogue_manager = tree.get_first_node_in_group("dialogue_manager")
	if not dialogue_manager:
		return false
	if dialogue_manager.has_method("get_is_dialogue_active"):
		return dialogue_manager.get_is_dialogue_active()
	elif "is_dialogue_active" in dialogue_manager:
		return dialogue_manager.is_dialogue_active
	return false

func _has_visible_dialogue_box() -> bool:
	var tree = get_tree()
	if not tree or not is_inside_tree():
		return false
	var root = tree.current_scene
	if not root:
		return false
	
	# Buscar DialogueBox (Control simples)
	var dialogue_boxes = _find_nodes_by_name(root, "DialogueBox")
	for box in dialogue_boxes:
		if box and box.visible:
			return true
	
	# Buscar NPCDialogueBox (CanvasLayer com Control dentro)
	var npc_dialogue_boxes = _find_nodes_by_name(root, "NPCDialogueBox")
	for box in npc_dialogue_boxes:
		if box and box.visible:
			# Verificar também o Control dentro dele
			var control_node = box.get_node_or_null("Control")
			if control_node and control_node.visible:
				return true
			# Se o CanvasLayer está visível, considerar como diálogo ativo
			return true
	
	return false

func _on_dialogue_ended(_npc_name: String) -> void:
	# Mostrar controles mobile quando diálogo terminar
	print("💬 Diálogo terminado com NPC: ", _npc_name, " - mostrando HUD mobile")
	_show_controls_after_dialogue()

func _connect_dialogue_signals() -> void:
	# Conectar aos sinais do dialogue_manager
	var tree = get_tree()
	if not tree or not is_inside_tree():
		return
	var dialogue_manager = tree.get_first_node_in_group("dialogue_manager")
	if dialogue_manager:
		# Desconectar primeiro para evitar múltiplas conexões
		if dialogue_manager.dialogue_started.is_connected(_on_dialogue_started):
			dialogue_manager.dialogue_started.disconnect(_on_dialogue_started)
		if dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
			dialogue_manager.dialogue_ended.disconnect(_on_dialogue_ended)
		
		# Conectar os sinais
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
		print("✅ Sinais do DialogueManager conectados")
		
		# Verificar estado inicial apenas uma vez usando verificação rigorosa
		if _is_dialogue_really_active():
			_hide_controls_during_dialogue()
	else:
		print("⚠️ DialogueManager não encontrado!")

func _hide_controls_during_dialogue() -> void:
	# Verificação final antes de esconder
	if not _is_dialogue_really_active():
		print("  ⚠️ Tentativa de esconder HUD mas diálogo não está realmente ativo! Cancelando.")
		return
	
	# Esconder controles durante diálogo
	print("  🫥 Escondendo HUD mobile (diálogo ativo - verificação rigorosa passou)")
	if control:
		control.visible = false
		print("  ✅ HUD escondida")

func _show_controls_after_dialogue() -> void:
	# Mostrar controles após diálogo (se estiverem habilitados)
	var is_mobile = OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS")
	var should_show = is_mobile or _controls_enabled_manually
	
	if control:
		control.visible = should_show
