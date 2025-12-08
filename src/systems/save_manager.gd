extends Node

# Gerenciador de save/load do jogo
# Salva o progresso em um arquivo externo (user://save_game.json)

const SAVE_FILE_PATH = "user://save_game.json"

signal save_created
signal save_loaded
signal save_deleted

# Estrutura do save
var save_data: Dictionary = {
	"version": "1.0",
	"timestamp": "",
	"unlocked_knowledge": [],
	"player_position": null,  # Para expansão futura
	"current_scene": null     # Para expansão futura
}

var is_loading: bool = false  # Flag para evitar salvar durante carregamento
var should_load_on_next_scene: bool = false  # Flag para carregar save na próxima cena

func _ready() -> void:
	add_to_group("save_manager")
	print("💾 SaveManager inicializado")
	
	# Sempre tentar carregar save quando uma cena é carregada (se houver save disponível)
	_check_and_load_save()

func _notification(what: int) -> void:
	# Salvar quando o jogo está sendo fechado
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("💾 Salvando antes de fechar o jogo...")
		save_game()

func _check_and_load_save() -> void:
	# Verificar se há save disponível
	if not has_save_file():
		# Se não há save, mas should_load_on_next_scene está true, resetar flag
		if should_load_on_next_scene:
			should_load_on_next_scene = false
		return
	
	# Verificar se o KnowledgeManager está disponível (como autoload ou grupo)
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	if knowledge_manager:
		# KnowledgeManager encontrado, pode carregar
		if should_load_on_next_scene:
			should_load_on_next_scene = false
		load_game_when_ready()
	else:
		# Ainda não está disponível, tentar novamente em breve
		await get_tree().create_timer(0.1).timeout
		_check_and_load_save()

# Método para carregar save após a cena estar pronta
func load_game_when_ready() -> void:
	# Aguardar alguns frames para garantir que a cena está totalmente carregada
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame  # Mais um frame para garantir
	
	if has_save_file():
		load_game()
		# Notificar o KnowledgeGlossary para atualizar a lista
		await get_tree().process_frame
		var glossary = get_tree().get_first_node_in_group("knowledge_glossary")
		if glossary and glossary.has_method("_update_knowledge_list"):
			glossary._update_knowledge_list()

# Verificar se existe um save game
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

# Salvar progresso atual
func save_game() -> bool:
	# Tentar primeiro como autoload, depois como grupo
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	if not knowledge_manager:
		push_error("KnowledgeManager não encontrado para salvar!")
		return false
	
	# Atualizar dados do save
	save_data.timestamp = Time.get_datetime_string_from_system()
	
	# Salvar conhecimentos desbloqueados
	if knowledge_manager.has_method("get_unlocked_knowledge"):
		save_data.unlocked_knowledge = knowledge_manager.get_unlocked_knowledge()
	elif "unlocked_knowledge" in knowledge_manager:
		save_data.unlocked_knowledge = knowledge_manager.unlocked_knowledge.duplicate()
	else:
		save_data.unlocked_knowledge = []
	
	# Salvar em arquivo JSON
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Erro ao salvar jogo: " + str(error))
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("✅ Jogo salvo com sucesso em: ", SAVE_FILE_PATH)
	print("   Conhecimentos salvos: ", save_data.unlocked_knowledge.size())
	save_created.emit()
	return true

# Carregar progresso salvo
func load_game() -> bool:
	if not has_save_file():
		push_warning("Nenhum arquivo de save encontrado!")
		return false
	
	is_loading = true  # Marcar que estamos carregando
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Erro ao carregar jogo: " + str(error))
		is_loading = false
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Erro ao parsear JSON do save: " + json.get_error_message())
		is_loading = false
		return false
	
	save_data = json.data
	
	# Carregar conhecimentos desbloqueados
	# Tentar primeiro como autoload, depois como grupo
	var knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	if not knowledge_manager:
		knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	if knowledge_manager:
		# Limpar conhecimentos atuais
		if "unlocked_knowledge" in knowledge_manager:
			knowledge_manager.unlocked_knowledge.clear()
		
		# Restaurar conhecimentos salvos diretamente (sem emitir sinais)
		if "unlocked_knowledge" in save_data:
			if "unlocked_knowledge" in knowledge_manager:
				# Adicionar diretamente ao array para evitar sinais durante carregamento
				for knowledge_id in save_data.unlocked_knowledge:
					if knowledge_id not in knowledge_manager.unlocked_knowledge:
						knowledge_manager.unlocked_knowledge.append(knowledge_id)
		
		print("✅ Jogo carregado com sucesso!")
		print("   Conhecimentos restaurados: ", save_data.unlocked_knowledge.size())
		print("   IDs restaurados: ", save_data.unlocked_knowledge)
		is_loading = false  # Finalizar carregamento
		save_loaded.emit()
		return true
	else:
		push_warning("KnowledgeManager não encontrado para carregar save!")
		is_loading = false  # Finalizar carregamento mesmo em caso de erro
		return false

# Deletar save game
func delete_save() -> bool:
	if not has_save_file():
		return false
	
	var dir = DirAccess.open("user://")
	if dir == null:
		push_error("Erro ao acessar diretório user://")
		return false
	
	var error = dir.remove(SAVE_FILE_PATH)
	if error != OK:
		push_error("Erro ao deletar save: " + str(error))
		return false
	
	print("🗑️ Save game deletado")
	save_deleted.emit()
	return true

# Obter informações do save (sem carregar)
func get_save_info() -> Dictionary:
	if not has_save_file():
		return {}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var data = json.data
	return {
		"timestamp": data.get("timestamp", ""),
		"knowledge_count": data.get("unlocked_knowledge", []).size(),
		"version": data.get("version", "1.0")
	}

# Salvar automaticamente quando um conhecimento é desbloqueado
func _on_knowledge_unlocked(_knowledge_id: String, _knowledge_name: String, _knowledge_description: String) -> void:
	# Não salvar se estiver carregando (para evitar loop)
	if is_loading:
		return
	
	# Salvar automaticamente após um pequeno delay para evitar múltiplos saves
	await get_tree().create_timer(0.5).timeout
	
	# Verificar novamente se ainda não está carregando
	if not is_loading:
		save_game()
