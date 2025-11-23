extends CanvasLayer

@onready var control: Control = $Control
@onready var panel: Panel = $Control/Panel
@onready var label: RichTextLabel = $Control/Panel/Label
@onready var next_label: Label = $Control/Panel/NextLabel

var dialogue_manager: Node
var npc: Node2D = null

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
	dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if dialogue_manager:
		dialogue_manager.dialogue_started.connect(_on_dialogue_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
		dialogue_manager.dialogue_next.connect(_on_dialogue_next)

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
			# Garantir que o balão não reabra automaticamente
			await get_tree().process_frame

func _on_dialogue_next(line: String) -> void:
	# Só atualizar se este box estiver visível
	if visible:
		# Processar linha para destacar conhecimento
		# A verificação de cor é feita aqui, após o conhecimento ter sido desbloqueado
		var processed_line = _process_knowledge_tags(line)
		label.text = processed_line

func _process_knowledge_tags(line: String) -> String:
	# Substituir tags [knowledge="id"] ou [k="id"] por texto destacado
	# Usar BBCode do Godot para destacar: [color=#FFD700]texto[/color]
	var processed = line
	var knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
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
