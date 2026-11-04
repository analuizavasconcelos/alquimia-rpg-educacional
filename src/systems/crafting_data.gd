extends RefCounted

# Dados do sistema de crafting: lê as substâncias e as reações dos arquivos JSON.
# Não é um Node: é só uma "caixa de dados" criada pela interface da mesa de alquimia.
# Para adicionar reações novas, edite os JSON em data/reactions/ (sem mexer em código).

const SUBSTANCES_PATH: String = "res://data/reactions/substancias.json"
const REACTIONS_PATH: String = "res://data/reactions/reacoes.json"

# id -> { id, name, formula, group, description, requires_knowledge?, product_only? }
var substances: Dictionary = {}
# Ordem em que as substâncias aparecem na lista de reagentes
var reagent_ids: Array[String] = []
# id -> { id, reagents, products, equation, type, knowledge, explanation }
var reactions: Dictionary = {}
# Ordem original do arquivo (para listar o caderno sempre na mesma ordem)
var reaction_ids: Array[String] = []

# "id_a|id_b" (ordenado) -> id da reação
var _reaction_by_key: Dictionary = {}

func _init() -> void:
	_load_substances()
	_load_reactions()

# Chave que não depende da ordem: (a, b) e (b, a) geram a mesma chave
static func make_key(id_a: String, id_b: String) -> String:
	var ids: Array = [id_a, id_b]
	ids.sort()
	return "|".join(ids)

func find_reaction(id_a: String, id_b: String) -> Dictionary:
	var reaction_id: String = _reaction_by_key.get(make_key(id_a, id_b), "")
	if reaction_id.is_empty():
		return {}
	return reactions[reaction_id]

func get_substance(substance_id: String) -> Dictionary:
	return substances.get(substance_id, {})

# Uma substância com "requires_knowledge" só fica disponível depois que o jogador aprendeu aquele conceito
func is_available(substance_id: String, knowledge_manager: Node) -> bool:
	var substance: Dictionary = get_substance(substance_id)
	if substance.is_empty():
		return false
	var required: String = str(substance.get("requires_knowledge", ""))
	if required.is_empty() or knowledge_manager == null:
		return true
	return knowledge_manager.is_knowledge_unlocked(required)

# ---------------------------------------------------------------------------
# Carregamento
# ---------------------------------------------------------------------------

func _load_substances() -> void:
	for entry in _read_list(SUBSTANCES_PATH, "substances"):
		if not (entry is Dictionary) or not entry.has("id"):
			push_warning("Substância inválida (falta 'id'): " + str(entry))
			continue
		var substance_id: String = str(entry["id"])
		substances[substance_id] = entry
		if not entry.get("product_only", false):
			reagent_ids.append(substance_id)

func _load_reactions() -> void:
	for entry in _read_list(REACTIONS_PATH, "reactions"):
		if not (entry is Dictionary) or not entry.has("id") or not entry.has("reagents"):
			push_warning("Reação inválida (precisa de 'id' e 'reagents'): " + str(entry))
			continue
		var reagents: Array = entry["reagents"]
		if reagents.size() != 2:
			push_warning("Reação '%s' precisa de exatamente 2 reagentes." % entry["id"])
			continue
		var all_ids: Array = reagents.duplicate()
		all_ids.append_array(entry.get("products", []))
		var valid: bool = true
		for substance_id in all_ids:
			if not substances.has(str(substance_id)):
				push_warning("Reação '%s' usa substância inexistente: %s" % [entry["id"], substance_id])
				valid = false
		if not valid:
			continue
		var reaction_id: String = str(entry["id"])
		reactions[reaction_id] = entry
		reaction_ids.append(reaction_id)
		_reaction_by_key[make_key(str(reagents[0]), str(reagents[1]))] = reaction_id

func _read_list(path: String, key: String) -> Array:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Não foi possível abrir: " + path)
		return []
	var json: JSON = JSON.new()
	var error: int = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("JSON inválido em %s (linha %d): %s" % [path, json.get_error_line(), json.get_error_message()])
		return []
	var data: Variant = json.data
	if not (data is Dictionary) or not (data.get(key) is Array):
		push_error("Formato inválido em %s: esperado um objeto com a lista '%s'" % [path, key])
		return []
	return data[key]
