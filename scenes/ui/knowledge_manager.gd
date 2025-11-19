extends Node

signal knowledge_unlocked(knowledge_id: String, knowledge_name: String, knowledge_description: String)

# Dicionário de conhecimentos disponíveis
# Formato: { "id": { "name": "Nome", "description": "Descrição", "category": "categoria" } }
var available_knowledge: Dictionary = {
	"atomo": {
		"name": "Átomo",
		"description": "A menor unidade de matéria que mantém as propriedades de um elemento químico.",
		"category": "quimica"
	},
	"molecula": {
		"name": "Molécula",
		"description": "Grupo de átomos ligados quimicamente que representa a menor unidade de uma substância.",
		"category": "quimica"
	},
	"reacao_quimica": {
		"name": "Reação Química",
		"description": "Processo onde substâncias se transformam em outras através da quebra e formação de ligações químicas.",
		"category": "quimica"
	}
}

# Conjunto de conhecimentos desbloqueados pelo player
var unlocked_knowledge: Array[String] = []

func _ready() -> void:
	add_to_group("knowledge_manager")
	# Conhecimentos são mantidos apenas em memória durante a sessão

# Verificar se um conhecimento está desbloqueado
func is_knowledge_unlocked(knowledge_id: String) -> bool:
	return knowledge_id in unlocked_knowledge

# Desbloquear um conhecimento
func unlock_knowledge(knowledge_id: String) -> bool:
	# Verificar se o conhecimento existe
	if not knowledge_id in available_knowledge:
		push_warning("Knowledge ID não encontrado: " + knowledge_id)
		return false
	
	# Verificar se já está desbloqueado
	if is_knowledge_unlocked(knowledge_id):
		return false  # Já estava desbloqueado
	
	# Adicionar aos desbloqueados
	unlocked_knowledge.append(knowledge_id)
	
	# Emitir sinal com informações do conhecimento
	var knowledge_data = available_knowledge[knowledge_id]
	knowledge_unlocked.emit(knowledge_id, knowledge_data.name, knowledge_data.description)
	
	return true

# Obter informações de um conhecimento
func get_knowledge_info(knowledge_id: String) -> Dictionary:
	if knowledge_id in available_knowledge:
		return available_knowledge[knowledge_id]
	return {}

# Adicionar novo conhecimento ao sistema (para expansão futura)
func add_knowledge(knowledge_id: String, knowledge_name: String, description: String, category: String = "quimica") -> void:
	available_knowledge[knowledge_id] = {
		"name": knowledge_name,
		"description": description,
		"category": category
	}

