extends CanvasLayer

@onready var control: Control = $Control
@onready var panel: Panel = $Control/Panel
@onready var label: RichTextLabel = $Control/Panel/Label
@onready var next_label: Label = $Control/Panel/NextLabel

var dialogue_manager: Node
var npc: Node2D = null

# --- Perguntas (UI criada por código, não precisa editar o .tscn) ---
# DEFAULT_TOP = altura normal da caixa (offset negativo a partir da base da tela)
# QUESTION_BASE_HEIGHT = espaço reservado para o texto da pergunta e o feedback
const DEFAULT_TOP: float = -200.0
const QUESTION_BASE_HEIGHT: float = 200.0
const BOTTOM_MARGIN: float = 40.0
const OPTION_HEIGHT: float = 40.0
const OPTION_SEPARATION: float = 6.0

var _options_box: VBoxContainer = null
var _option_buttons: Array[Button] = []
var _question_text: String = ""

func _ready() -> void:
	# Garantir que o balão fique escondido por padrão
	visible = false
	if control:
		control.visible = false
	if panel:
		panel.visible = false
	if label:
		label.text = ""
		# RichTextLabel processa BBCode por padrão, não precisa habilitar manualmente!
	_build_options_box()
	dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if dialogue_manager:
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
		dialogue_manager.dialogue_next.connect(_on_dialogue_next)
		dialogue_manager.dialogue_question.connect(_on_dialogue_question)
		dialogue_manager.question_answered.connect(_on_question_answered)

# Input agora é processado no dialogue_manager para evitar conflitos

func _on_dialogue_started(npc_name: String) -> void:
	# Verificar se este box pertence ao NPC que iniciou o diálogo
	if npc:
		var npc_name_str = str(npc.name)
		if npc_name_str == npc_name:
			# Mostrar o balão apenas quando o diálogo iniciar
			visible = true
			if control:
				control.visible = true
			if panel:
				panel.visible = true
			_update_size()
		else:
			# Esconder se não for este NPC
			visible = false
			if control:
				control.visible = false
			if panel:
				panel.visible = false

func _on_dialogue_ended(npc_name: String) -> void:
	# Só esconder se for o NPC deste box
	if npc:
		var npc_name_str = str(npc.name)
		if npc_name_str == npc_name:
			# Esconder o balão quando o diálogo terminar
			visible = false
			if control:
				control.visible = false
			if panel:
				panel.visible = false
			if label:
				label.text = ""
			_clear_question_ui()
			# Garantir que o balão não reabra automaticamente
			await get_tree().process_frame

func _on_dialogue_next(line: String) -> void:
	# Só atualizar se este box estiver visível
	if visible:
		_clear_question_ui()  # Voltou a ser fala normal: esconde opções e restaura o tamanho da caixa
		# Processar linha para destacar conhecimento
		# A verificação de cor é feita aqui, após o conhecimento ter sido desbloqueado
		var processed_line = _process_knowledge_tags(line)
		label.text = processed_line

# ---------------------------------------------------------------------------
# PERGUNTAS
# ---------------------------------------------------------------------------

func _build_options_box() -> void:
	if not panel:
		return
	_options_box = VBoxContainer.new()
	_options_box.name = "OptionsBox"
	# Faixa na parte de baixo do painel; a altura é definida em _show_options()
	_options_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_options_box.offset_left = 25.0
	_options_box.offset_right = -25.0
	_options_box.offset_bottom = -BOTTOM_MARGIN
	_options_box.add_theme_constant_override("separation", int(OPTION_SEPARATION))
	_options_box.visible = false
	panel.add_child(_options_box)

func _on_dialogue_question(question: Dictionary) -> void:
	if not visible:
		return  # Só o balão do NPC que está falando reage
	_question_text = _process_knowledge_tags(str(question.get("text", "")))
	label.text = _question_text
	if next_label:
		next_label.visible = false  # Não dá para "continuar" sem responder
	_show_options(question.get("options", []))

func _show_options(options: Array) -> void:
	if not _options_box:
		return
	_clear_option_buttons()

	for i in range(options.size()):
		var button := Button.new()
		button.text = "%d) %s" % [i + 1, str(options[i])]
		button.custom_minimum_size = Vector2(0, OPTION_HEIGHT)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE  # Evita que E/Enter "aperte" um botão sem querer
		button.add_theme_font_size_override("font_size", 22)
		button.pressed.connect(_on_option_pressed.bind(i))
		_options_box.add_child(button)
		_option_buttons.append(button)

	# Caixa maior para caber texto + opções
	var options_height: float = options.size() * OPTION_HEIGHT + maxi(options.size() - 1, 0) * OPTION_SEPARATION
	_options_box.offset_top = _options_box.offset_bottom - options_height
	_options_box.visible = true
	control.offset_top = -(QUESTION_BASE_HEIGHT + BOTTOM_MARGIN + options_height)

func _on_option_pressed(index: int) -> void:
	if dialogue_manager:
		dialogue_manager.answer_question(index)

func _on_question_answered(correct: bool, selected_index: int, feedback: String) -> void:
	if not visible:
		return
	if selected_index >= 0 and selected_index < _option_buttons.size():
		var chosen := _option_buttons[selected_index]
		chosen.disabled = true
		chosen.modulate = Color(0.55, 1.0, 0.55) if correct else Color(1.0, 0.5, 0.5)

	var feedback_color := "#7CFC00" if correct else "#FF6B6B"
	label.text = _question_text + "\n\n[color=" + feedback_color + "]" + feedback + "[/color]"

	if correct:
		for button in _option_buttons:
			button.disabled = true
		if next_label:
			next_label.visible = true  # Agora pode continuar a conversa

func _clear_option_buttons() -> void:
	for button in _option_buttons:
		button.queue_free()
	_option_buttons.clear()

func _clear_question_ui() -> void:
	_clear_option_buttons()
	_question_text = ""
	if _options_box:
		_options_box.visible = false
	if control:
		control.offset_top = DEFAULT_TOP
	if next_label:
		next_label.visible = true

func _process_knowledge_tags(line: String) -> String:
	# Substituir tags [knowledge="id"] ou [k="id"] por texto destacado
	# Usar BBCode do Godot para destacar: [color=#FFD700]texto[/color]
	var processed = line
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	# Debug: verificar se KnowledgeManager existe
	if not knowledge_manager:
		print("⚠️ AVISO: KnowledgeManager não encontrado! Adicione na cena vilarejo.tscn")
		# Mesmo sem KnowledgeManager, ainda podemos processar as tags para destacar
	else:
		print("✅ KnowledgeManager encontrado!")
	
	# Processar tags simples: [k="id"] ou [knowledge="id"]
	var regex = RegEx.new()
	var compile_result = regex.compile("\\[k(?:nowledge)?=\"([^\"]+)\"\\]")
	
	if compile_result != OK:
		push_error("Erro ao compilar regex para processar conhecimento")
		return line
	
	var results = regex.search_all(processed)
	
	if results.is_empty():
		# Não há tags de conhecimento nesta linha
		return processed
	
	print("📚 Encontradas ", results.size(), " tag(s) de conhecimento na linha")
	
	# Processar de trás para frente para não afetar os índices
	for i in range(results.size() - 1, -1, -1):
		var result = results[i]
		var knowledge_id = result.get_string(1)
		
		# Verificar se o conhecimento já foi desbloqueado
		var is_unlocked = false
		if knowledge_manager and knowledge_manager.has_method("is_knowledge_unlocked"):
			is_unlocked = knowledge_manager.is_knowledge_unlocked(knowledge_id)
		
		# Obter nome do conhecimento
		var knowledge_name = knowledge_id
		if knowledge_manager and knowledge_manager.has_method("get_knowledge_info"):
			var info = knowledge_manager.get_knowledge_info(knowledge_id)
			if info.has("name"):
				knowledge_name = info.name
				print("  → Conhecimento '", knowledge_id, "' = '", knowledge_name, "' (desbloqueado: ", is_unlocked, ")")
			else:
				print("  ⚠️ Conhecimento '", knowledge_id, "' não encontrado no KnowledgeManager")
		else:
			print("  ⚠️ Usando ID como nome: '", knowledge_id, "'")
		
		# Escolher cor baseado se já foi desbloqueado ou não
		var color_code: String
		if is_unlocked:
			# Conhecimento já adquirido: azul claro/ciano
			color_code = "#4FC3F7"  # Azul claro
		else:
			# Conhecimento novo: dourado/amarelo
			color_code = "#FFD700"  # Dourado
		
		# Substituir tag por texto destacado com a cor apropriada
		var replacement = "[color=" + color_code + "][b]" + knowledge_name + "[/b][/color]"
		var full_match = result.get_string(0)
		processed = processed.replace(full_match, replacement)
		print("  → Substituído: '", full_match, "' por '", replacement, "' (cor: ", color_code, ")")
	
	print("📝 Linha processada: ", processed)
	return processed

func _update_size() -> void:
	# A caixa agora é fixa na parte inferior da tela, não precisa calcular tamanho dinamicamente
	# O tamanho é controlado pelos anchors no .tscn
	pass

func set_npc(npc_node: Node2D) -> void:
	npc = npc_node
