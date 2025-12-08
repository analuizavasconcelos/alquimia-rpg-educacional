extends CanvasLayer

@onready var control: Control = $Control
@onready var knowledge_list: VBoxContainer = $Control/Panel/VBox/ScrollContainer/KnowledgeList
@onready var close_button: Button = $Control/Panel/CloseButton
var empty_label: Label = null

var knowledge_manager: Node = null
var knowledge_items: Dictionary = {}  # Guarda referências aos itens criados

func _ready() -> void:
	# Garantir que processa input mesmo quando pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = false
	if control:
		control.visible = false
	
	# Buscar EmptyLabel de forma segura
	empty_label = get_node_or_null("Control/Panel/VBox/ScrollContainer/KnowledgeList/EmptyLabel")
	
	# Conectar botão de fechar
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		print("✅ Botão de fechar conectado")
	else:
		print("⚠️ Botão de fechar não encontrado!")
		# Tentar buscar manualmente
		close_button = get_node_or_null("Control/Panel/CloseButton")
		if close_button:
			close_button.pressed.connect(_on_close_button_pressed)
			print("✅ Botão de fechar encontrado e conectado manualmente")
	
	# Buscar KnowledgeManager (primeiro como autoload, depois como grupo)
	knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	if knowledge_manager:
		knowledge_manager.knowledge_unlocked.connect(_on_knowledge_unlocked)
		# Atualizar lista inicial
		_update_knowledge_list()
	
	# Adicionar ao grupo para facilitar acesso
	add_to_group("knowledge_glossary")

func _input(event: InputEvent) -> void:
	# Toggle do glossário com tecla G
	if event is InputEventKey and event.pressed:
		# Tecla G para abrir/fechar
		if event.keycode == KEY_G:
			if visible:
				close_glossary()
			else:
				# Verificar se não há diálogo ativo antes de abrir
				var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
				var dialogue_active = false
				if dialogue_manager and dialogue_manager.has_method("get_is_dialogue_active"):
					dialogue_active = dialogue_manager.get_is_dialogue_active()
				
				if not dialogue_active:
					open_glossary()
			get_viewport().set_input_as_handled()
		# ESC também fecha
		elif event.keycode == KEY_ESCAPE and visible:
			close_glossary()
			get_viewport().set_input_as_handled()

func open_glossary() -> void:
	visible = true
	if control:
		control.visible = true
	
	# Garantir que o botão de fechar está conectado e funcional
	if not close_button:
		close_button = get_node_or_null("Control/CloseButton")
	
	if close_button:
		# Desconectar e reconectar para garantir que está conectado
		if close_button.pressed.is_connected(_on_close_button_pressed):
			close_button.pressed.disconnect(_on_close_button_pressed)
		close_button.pressed.connect(_on_close_button_pressed)
		close_button.visible = true
		close_button.disabled = false
		close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		print("✅ Botão de fechar configurado no open_glossary")
	
	_update_knowledge_list()
	# Não pausar o jogo, apenas bloquear input do player
	# O player já verifica se há diálogo ativo, podemos adicionar verificação de glossário também

func _on_close_button_pressed() -> void:
	print("Botão X pressionado - fechando glossário")
	# Usar call_deferred para garantir que o fechamento aconteça corretamente
	call_deferred("close_glossary")

func close_glossary() -> void:
	visible = false
	if control:
		control.visible = false

func _on_knowledge_unlocked(_knowledge_id: String, _knowledge_name: String, _knowledge_description: String) -> void:
	# Quando um conhecimento é desbloqueado, atualizar a lista
	_update_knowledge_list()

func _update_knowledge_list() -> void:
	if not knowledge_manager:
		return
	
	# Limpar lista atual (exceto empty_label)
	for child in knowledge_list.get_children():
		if child != empty_label:
			child.queue_free()
	knowledge_items.clear()
	
	# Obter conhecimentos desbloqueados
	var unlocked = []
	if knowledge_manager.has_method("is_knowledge_unlocked"):
		# Iterar sobre todos os conhecimentos disponíveis
		if "available_knowledge" in knowledge_manager:
			var available = knowledge_manager.available_knowledge
			for knowledge_id in available.keys():
				if knowledge_manager.is_knowledge_unlocked(knowledge_id):
					var info = knowledge_manager.get_knowledge_info(knowledge_id)
					unlocked.append({
						"id": knowledge_id,
						"name": info.get("name", knowledge_id),
						"description": info.get("description", ""),
						"category": info.get("category", "quimica")
					})
	
	# Ordenar por categoria e depois por nome
	unlocked.sort_custom(_sort_knowledge)
	
	# Esconder empty_label se houver conhecimentos
	if empty_label:
		if unlocked.size() > 0:
			empty_label.visible = false
		else:
			empty_label.visible = true
	
	if unlocked.size() > 0:
		# Aguardar um frame para garantir que o ScrollContainer tenha tamanho definido
		await get_tree().process_frame
		
		# Criar itens para cada conhecimento
		var current_category = ""
		for knowledge in unlocked:
			# Adicionar separador de categoria se mudou
			if knowledge.category != current_category:
				current_category = knowledge.category
				var category_label = _create_category_label(current_category)
				knowledge_list.add_child(category_label)
			
			# Criar item de conhecimento
			var item = _create_knowledge_item(knowledge.name, knowledge.description)
			knowledge_list.add_child(item)
			knowledge_items[knowledge.id] = item
		
		# Forçar atualização do layout após adicionar todos os itens
		await get_tree().process_frame
		_update_item_heights()

func _update_item_heights() -> void:
	# Forçar recálculo do layout para que os labels calculem altura correta
	if not knowledge_list:
		return
	
	# Aguardar mais um frame para garantir que o layout foi atualizado
	await get_tree().process_frame
	
	# Obter largura disponível do ScrollContainer
	var scroll_container = knowledge_list.get_parent()
	if not scroll_container or not scroll_container is ScrollContainer:
		return
	
	# Garantir que o KnowledgeList tenha largura definida
	var scroll_width = scroll_container.size.x
	if scroll_width > 0:
		knowledge_list.custom_minimum_size = Vector2(scroll_width, 0)
	
	# Aguardar mais um frame para os labels calcularem altura
	await get_tree().process_frame
	
	# Ajustar cada painel baseado no tamanho real dos labels
	for child in knowledge_list.get_children():
		if not child is Panel:
			continue
		
		# Encontrar os labels dentro do painel
		var margin = child.get_child(0) if child.get_child_count() > 0 else null
		if not margin or not margin is MarginContainer:
			continue
		
		var vbox = margin.get_child(0) if margin.get_child_count() > 0 else null
		if not vbox or not vbox is VBoxContainer:
			continue
		
		# Calcular altura total baseada nos labels
		var total_height = 0
		var separation = vbox.get_theme_constant("separation")
		if separation <= 0:
			separation = 15
		
		for i in range(vbox.get_child_count()):
			var label = vbox.get_child(i)
			if not label is Label:
				continue
			
			# Forçar atualização do layout do label
			label.queue_redraw()
			
			# Usar o tamanho real do label após o layout ser calculado
			var label_size = label.get_combined_minimum_size()
			if label_size.y > 0:
				total_height += label_size.y
			else:
				# Tentar usar get_line_count() se disponível
				var font_size = label.get_theme_font_size("font_size")
				var line_count = label.get_line_count()
				if line_count > 0:
					total_height += line_count * (font_size + 4)
				else:
					# Altura padrão baseada no tamanho da fonte
					total_height += font_size + 8
			
			# Adicionar separação entre labels (exceto no último)
			if i < vbox.get_child_count() - 1:
				total_height += separation
		
		# Adicionar margens do MarginContainer
		var margin_top = margin.get_theme_constant("margin_top")
		if margin_top <= 0:
			margin_top = 20
		var margin_bottom = margin.get_theme_constant("margin_bottom")
		if margin_bottom <= 0:
			margin_bottom = 20
		total_height += margin_top + margin_bottom
		
		# Ajustar altura mínima do painel (com um pequeno buffer)
		if total_height > 0:
			child.custom_minimum_size = Vector2(0, total_height + 10)

func _sort_knowledge(a: Dictionary, b: Dictionary) -> bool:
	if a.category != b.category:
		return a.category < b.category
	return a.name < b.name

func _create_category_label(category: String) -> Label:
	var label = Label.new()
	# Capitalizar primeira letra manualmente
	var category_display = category
	if category.length() > 0:
		category_display = category[0].to_upper() + category.substr(1)
	label.text = "━━━ " + category_display + " ━━━"
	label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 1.0))
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func _create_knowledge_item(item_name: String, description: String) -> Panel:
	var panel = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.4, 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	panel.add_theme_stylebox_override("panel", style)
	
	# Configurar flags de tamanho: expandir horizontalmente, ajustar verticalmente ao conteúdo
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_END
	
	# MarginContainer para padding interno
	var margin = MarginContainer.new()
	panel.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 25)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 25)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_SHRINK_END
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_END
	
	var name_label = Label.new()
	name_label.text = "• " + item_name
	name_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0, 1.0))  # Dourado
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_END
	name_label.clip_contents = false
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	desc_label.add_theme_font_size_override("font_size", 24)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.size_flags_vertical = Control.SIZE_SHRINK_END
	desc_label.clip_contents = false
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	vbox.add_child(desc_label)
	
	# Não definir tamanho mínimo - o painel se ajustará ao conteúdo automaticamente
	# O VBoxContainer dentro do ScrollContainer calculará a altura correta dos labels
	
	return panel
