extends Node

signal dialogue_started(npc_name: String)
signal dialogue_ended(npc_name: String)
signal dialogue_next(line: String)
# Perguntas: emitido quando uma pergunta aparece e quando o jogador responde
signal dialogue_question(question: Dictionary)
signal question_answered(correct: bool, selected_index: int, feedback: String)

var current_dialogue: Array = []
var current_index: int = 0
var current_npc: Node2D = null
var is_dialogue_active: bool = false

# Estado da pergunta atual (só preenchido enquanto o jogador ainda não acertou)
var is_question_active: bool = false
var current_question: Dictionary = {}

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
	is_question_active = false
	current_question = {}
	
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

	# Durante uma pergunta o avanço normal (E/clique) fica bloqueado: o jogador precisa responder.
	# Teclas 1-9 escolhem a opção. Cliques NÃO são consumidos aqui para que os botões da caixa de diálogo os recebam.
	if is_question_active:
		if event is InputEventKey and event.pressed and not event.echo:
			var option_index := _key_to_option_index(event.keycode)
			if option_index >= 0:
				answer_question(option_index)
				get_viewport().set_input_as_handled()
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
	
	# Entrada em formato de objeto = pergunta (ver data/dialogues/README.md)
	var entry = current_dialogue[current_index]
	if entry is Dictionary:
		current_index += 1
		_start_question(entry)
		return

	# Mostrar linha atual
	var line: String = str(entry)

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

# ---------------------------------------------------------------------------
# PERGUNTAS
# ---------------------------------------------------------------------------

func _key_to_option_index(keycode: Key) -> int:
	if keycode >= KEY_1 and keycode <= KEY_9:
		return keycode - KEY_1
	if keycode >= KEY_KP_1 and keycode <= KEY_KP_9:
		return keycode - KEY_KP_1
	return -1

func _start_question(entry: Dictionary) -> void:
	var options = entry.get("options", [])
	var correct = entry.get("correct", -1)
	var correct_is_number: bool = typeof(correct) == TYPE_INT or typeof(correct) == TYPE_FLOAT

	# Validar o JSON (erros de digitação são comuns ao escrever perguntas à mão)
	if str(entry.get("type", "")) != "question" \
			or not (options is Array) or options.size() < 2 \
			or not correct_is_number or int(correct) < 0 or int(correct) >= options.size():
		push_error("Pergunta inválida no diálogo (precisa de type=\"question\", options com 2+ itens e correct válido): " + str(entry))
		show_next_line()  # Pula a pergunta inválida para não travar o diálogo
		return

	var npc_name := "npc"
	if current_npc:
		npc_name = str(current_npc.name)

	# JSON entrega números como float: normalizar o índice da resposta certa
	current_question = entry.duplicate(true)
	current_question["correct"] = int(correct)
	if str(current_question.get("id", "")).is_empty():
		current_question["id"] = "%s_%d" % [npc_name, current_index - 1]

	is_question_active = true
	dialogue_question.emit(current_question)

# Chamado pela caixa de diálogo (botões) ou pelas teclas 1-9
func answer_question(selected_index: int) -> void:
	if not is_question_active:
		return
	var options: Array = current_question["options"]
	if selected_index < 0 or selected_index >= options.size():
		return

	var is_correct: bool = selected_index == int(current_question["correct"])
	var feedback: String
	if is_correct:
		feedback = str(current_question.get("feedback_correct", "Correto!"))
	else:
		feedback = str(current_question.get("feedback_wrong", "Não é bem isso. Tente de novo!"))

	if is_correct:
		is_question_active = false  # Só libera o avanço do diálogo quando acerta
		_unlock_question_knowledge(current_question)

	_record_answer(str(current_question["id"]), is_correct)
	question_answered.emit(is_correct, selected_index, feedback)

	if is_correct:
		current_question = {}

# Conhecimentos listados em "unlock" só são desbloqueados quando o jogador ACERTA
func _unlock_question_knowledge(question: Dictionary) -> void:
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		return
	var unlock = question.get("unlock", [])
	var ids: Array = unlock if unlock is Array else [unlock]
	for knowledge_id in ids:
		if str(knowledge_id) != "":
			knowledge_manager.unlock_knowledge(str(knowledge_id))

func _record_answer(question_id: String, is_correct: bool) -> void:
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager and save_manager.has_method("record_answer"):
		save_manager.record_answer(question_id, is_correct)

func end_dialogue() -> void:
	# Se já não está ativo, não fazer nada (evitar múltiplas chamadas)
	if not is_dialogue_active:
		return

	var npc_name = "Unknown"
	if current_npc:
		npc_name = str(current_npc.name)
	
	# Resetar estado ANTES de emitir o sinal (para evitar condições de corrida)
	is_dialogue_active = false
	is_question_active = false
	current_question = {}
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

