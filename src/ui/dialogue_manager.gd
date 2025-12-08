extends Node

signal dialogue_started(npc_name: String)
signal dialogue_ended(npc_name: String)
signal dialogue_next(line: String)

var current_dialogue: Array = []
var current_index: int = 0
var current_npc: Node2D = null
var is_dialogue_active: bool = false

func start_dialogue(npc: Node2D, dialogue_data: Array) -> void:
	# Se já há um diálogo ativo, finalizar antes de iniciar outro
	if is_dialogue_active:
		end_dialogue()
		# Pequeno delay para garantir que o estado foi resetado
		await get_tree().process_frame
	
	current_npc = npc
	current_dialogue = dialogue_data
	current_index = 0
	is_dialogue_active = true
	
	var npc_name: String = "Unknown"
	if npc:
		npc_name = str(npc.name)
	dialogue_started.emit(npc_name)
	show_next_line()

func get_is_dialogue_active() -> bool:
	return is_dialogue_active

func _ready() -> void:
	# Garantir que este node processe input
	set_process_input(true)

func _input(event: InputEvent) -> void:
	# Só processar input se o diálogo estiver ativo
	if not is_dialogue_active:
		return
	
	# Processar input para avançar diálogo
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		# show_next_line() já verifica se há mais linhas e fecha automaticamente
		show_next_line()
		get_viewport().set_input_as_handled()

func show_next_line() -> void:
	# Verificar se ainda há linhas para mostrar ANTES de mostrar
	if current_index >= current_dialogue.size():
		# Todas as linhas foram exibidas, fechar diálogo imediatamente
		end_dialogue()
		return
	
	# Mostrar linha atual
	var line = current_dialogue[current_index]
	
	# Emitir a linha PRIMEIRO para que a verificação de cor aconteça
	# A verificação verifica se está desbloqueado ANTES de desbloquear
	dialogue_next.emit(line)
	
	# DEPOIS processar e desbloquear conhecimentos na linha
	# Isso garante que na primeira vez aparece em dourado (novo)
	# e nas próximas vezes aparece em azul (já adquirido)
	_process_knowledge_in_line(line)
	
	current_index += 1
	
	# O diálogo só fecha quando o jogador pressionar E novamente
	# e show_next_line() for chamado novamente (que detectará current_index >= size)

func _process_knowledge_in_line(line: String) -> void:
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	if not knowledge_manager:
		return
	
	# Procurar por tags de conhecimento: [knowledge="id"] ou [k="id"]
	var regex = RegEx.new()
	regex.compile("\\[k(?:nowledge)?=\"([^\"]+)\"\\]")
	var results = regex.search_all(line)
	
	for result in results:
		var knowledge_id = result.get_string(1)
		# Tentar desbloquear o conhecimento
		if knowledge_manager.has_method("unlock_knowledge"):
			knowledge_manager.unlock_knowledge(knowledge_id)

func end_dialogue() -> void:
	# Se já não está ativo, não fazer nada (evitar múltiplas chamadas)
	if not is_dialogue_active:
		return
	
	var npc_name = "Unknown"
	if current_npc:
		npc_name = str(current_npc.name)
	
	# Resetar estado ANTES de emitir o sinal (para evitar condições de corrida)
	is_dialogue_active = false
	current_npc = null
	current_dialogue.clear()
	current_index = 0
	
	# Emitir sinal de término
	dialogue_ended.emit(npc_name)

func load_dialogue_from_json(file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to load dialogue file: " + file_path)
		return []
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse JSON: " + json.get_error_message())
		return []
	
	var data = json.data
	if not data.has("dialogue") or not data["dialogue"] is Array:
		push_error("Invalid dialogue format in JSON")
		return []
	
	return data["dialogue"]

