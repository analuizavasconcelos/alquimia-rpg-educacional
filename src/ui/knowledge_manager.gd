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
	},
	"elemento_quimico": {
		"name": "Elemento Químico",
		"description": "Substância pura formada por apenas um tipo de átomo, identificada pelo número atômico.",
		"category": "quimica"
	},
	"tabela_periodica": {
		"name": "Tabela Periódica",
		"description": "Organização dos elementos químicos em ordem crescente de número atômico, agrupados por propriedades similares.",
		"category": "quimica"
	},
	"ligacao_quimica": {
		"name": "Ligação Química",
		"description": "Força que mantém os átomos unidos para formar moléculas e compostos.",
		"category": "quimica"
	},
	"composto": {
		"name": "Composto",
		"description": "Substância formada por dois ou mais elementos químicos diferentes, combinados em proporções fixas.",
		"category": "quimica"
	},
	"substancia": {
		"name": "Substância",
		"description": "Material com composição química definida e propriedades características constantes.",
		"category": "quimica"
	},
	"mistura": {
		"name": "Mistura",
		"description": "Combinação de duas ou mais substâncias que mantêm suas propriedades individuais.",
		"category": "quimica"
	},
	"ion": {
		"name": "Íon",
		"description": "Átomo ou molécula que ganhou ou perdeu elétrons, adquirindo carga elétrica.",
		"category": "quimica"
	},
	"acido": {
		"name": "Ácido",
		"description": "Substância que doa prótons (íons H+) em solução aquosa, apresentando sabor azedo.",
		"category": "quimica"
	},
	"base": {
		"name": "Base",
		"description": "Substância que aceita prótons (íons H+) em solução aquosa, apresentando sabor amargo e textura escorregadia.",
		"category": "quimica"
	},
	"ph": {
		"name": "pH",
		"description": "Escala que mede a acidez ou basicidade de uma solução, variando de 0 (muito ácido) a 14 (muito básico).",
		"category": "quimica"
	},
	"solucao": {
		"name": "Solução",
		"description": "Mistura homogênea formada por um soluto dissolvido em um solvente.",
		"category": "quimica"
	}
}

# Conjunto de conhecimentos desbloqueados pelo player
var unlocked_knowledge: Array[String] = []

func _ready() -> void:
	add_to_group("knowledge_manager")
	# Conectar com SaveManager para salvar automaticamente
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		knowledge_unlocked.connect(save_manager._on_knowledge_unlocked)
		print("✅ KnowledgeManager (singleton) conectado ao SaveManager")
		# Carregar save quando o singleton é inicializado
		if save_manager.has_save_file():
			await get_tree().process_frame
			await get_tree().process_frame
			save_manager.load_game()
	else:
		print("⚠️ SaveManager não encontrado no autoload")

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

# Obter lista de conhecimentos desbloqueados (para save/load)
func get_unlocked_knowledge() -> Array[String]:
	return unlocked_knowledge.duplicate()

