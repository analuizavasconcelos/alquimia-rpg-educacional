extends CanvasLayer

# Janela da Mesa de Alquimia.
# Toda a interface é criada por código (não há .tscn), então não precisa montar nada no editor.
# Fluxo: o jogador escolhe dois reagentes -> "Combinar" -> o jogo mostra a equação e explica a reação.
# Reações bem-sucedidas desbloqueiam conhecimentos no glossário e são gravadas no save.
#
# Visual: usa a arte do pacote Sunnyside World (pasta assets/sprites/ui/alchemy/).
# Se alguma imagem faltar, a janela continua funcionando com cores lisas.

signal closed

const CraftingData = preload("res://src/systems/crafting_data.gd")

# Se aparecerem quadradinhos no lugar dos números pequenos (H₂O), troque para false.
const USE_UNICODE_SUBSCRIPTS: bool = true
const SUBSCRIPTS: Dictionary = {
	"0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
	"5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉"
}

const TEXTURE_DIR: String = "res://assets/sprites/ui/alchemy/"
const PANEL_SIZE: Vector2 = Vector2(940, 560)
const SLOT_SIZE: Vector2 = Vector2(112, 118)

const COLOR_TITLE: Color = Color(1.0, 0.9, 0.3)
const COLOR_CREAM: Color = Color(1.0, 0.95, 0.8)
const COLOR_MUTED: Color = Color(1.0, 0.95, 0.8, 0.85)
const COLOR_INK: Color = Color(0.12, 0.09, 0.18)
const COLOR_OUTLINE: Color = Color(0.1, 0.05, 0.1)

const HELP_TEXT: String = """[b]Como funciona[/b]
1. Clique em um reagente da lista para ler suas propriedades.
2. Clique em dois reagentes para colocá-los na mistura. Clicar em um frasco da mistura remove o reagente.
3. Aperte [b]Combinar[/b] e observe o resultado.
4. Se houver reação, o jogo mostra a equação balanceada, o tipo da reação e uma explicação. Novos conhecimentos vão para o glossário.
5. Se nada acontecer, tente outra combinação.

[b]Dicas[/b]
• Pense no tipo de cada reagente: metal, gás, ácido, base, sal.
• O que a combinação poderia formar? Um sal? Um óxido? Água?
• Algumas reações só acontecem com aquecimento. Existe um reagente chamado Calor.
• Reagentes com ??? ainda não foram liberados. Converse com os moradores do vilarejo para aprender os conceitos.
• Use o [b]Caderno de reações[/b] para rever o que você já descobriu.
• Esc fecha esta janela e, depois, a mesa."""

# Cores usadas só se uma textura não for encontrada
const FALLBACK_COLORS: Dictionary = {
	"panel_dark": Color(0.45, 0.28, 0.22),
	"panel_light": Color(0.75, 0.55, 0.45),
	"panel_white": Color(0.75, 0.79, 0.86)
}

var _data: CraftingData
var _knowledge_manager: Node = null
var _save_manager: Node = null
var _texture_cache: Dictionary = {}

var _slot_a: String = ""
var _slot_b: String = ""

var _reagent_container: VBoxContainer
var _slot_flasks: Array[TextureRect] = []
var _slot_labels: Array[Label] = []
var _result_disc: TextureRect
var _result_flask: TextureRect
var _result_name: Label
var _combine_button: Button
var _result_panel: PanelContainer
var _result_label: RichTextLabel
var _progress_label: Label

# Janelas extras (ficam por cima da mesa): ajuda e caderno de reações
var _root: Control
var _help_overlay: Control
var _notebook_overlay: Control
var _notebook_text: RichTextLabel

func _ready() -> void:
	layer = 10
	visible = false
	# O Player consulta este grupo para ficar parado enquanto a janela estiver aberta
	add_to_group("blocks_player_movement")
	_data = CraftingData.new()
	_build_ui()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		# Esc fecha primeiro a ajuda ou o caderno (se abertos); só depois a mesa
		if _help_overlay.visible or _notebook_overlay.visible:
			_close_overlays()
		else:
			close()
		get_viewport().set_input_as_handled()

func open() -> void:
	_knowledge_manager = get_node_or_null("/root/KnowledgeManager")
	_save_manager = get_node_or_null("/root/SaveManager")
	_clear_slots()
	_reset_result_slot()
	_close_overlays()
	_refresh_reagents()
	_refresh_progress()
	_set_result("Clique em um reagente para ver suas propriedades. Depois escolha dois reagentes e aperte [b]Combinar[/b].\n\nPrecisa de ajuda? Clique no botão [b]Ajuda[/b].")
	visible = true

func close() -> void:
	_close_overlays()
	visible = false
	closed.emit()

func _close_overlays() -> void:
	_help_overlay.visible = false
	_notebook_overlay.visible = false

# ---------------------------------------------------------------------------
# Texturas e estilos
# ---------------------------------------------------------------------------

func _load_tex(texture_name: String) -> Texture2D:
	if _texture_cache.has(texture_name):
		return _texture_cache[texture_name]
	var path: String = TEXTURE_DIR + texture_name + ".png"
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	else:
		push_warning("Mesa de alquimia: textura não encontrada: " + path)
	_texture_cache[texture_name] = tex
	return tex

# Moldura de 9 fatias do pacote (ou um retângulo liso, se a textura faltar)
func _texture_style(texture_name: String, tint: Color = Color.WHITE, pad_x: float = 10.0, pad_y: float = 4.0) -> StyleBox:
	var tex: Texture2D = _load_tex(texture_name)
	if tex == null:
		var flat: StyleBoxFlat = StyleBoxFlat.new()
		flat.bg_color = FALLBACK_COLORS.get(texture_name, Color(0.3, 0.2, 0.3))
		flat.set_border_width_all(2)
		flat.border_color = Color.BLACK
		flat.set_corner_radius_all(6)
		flat.content_margin_left = pad_x
		flat.content_margin_right = pad_x
		flat.content_margin_top = pad_y
		flat.content_margin_bottom = pad_y
		return flat
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = tex
	style.set_texture_margin_all(9)
	style.content_margin_left = pad_x
	style.content_margin_right = pad_x
	style.content_margin_top = pad_y
	style.content_margin_bottom = pad_y
	style.modulate_color = tint
	return style

# Cor e formato do frasco conforme o grupo da substância
func _group_visual(group: String) -> Dictionary:
	if group == "Não metal (gás)":
		return {"shape": "flask", "color": Color(0.6, 0.9, 1.0)}
	if group == "Não metal (sólido)":
		return {"shape": "jar", "color": Color(0.45, 0.45, 0.5)}
	if group.begins_with("Metal"):
		return {"shape": "jar", "color": Color(0.75, 0.8, 0.9)}
	if group == "Ácido":
		return {"shape": "flask", "color": Color(0.55, 1.0, 0.4)}
	if group == "Base":
		return {"shape": "flask", "color": Color(0.8, 0.55, 1.0)}
	if group.begins_with("Sal"):
		return {"shape": "jar", "color": Color(1.0, 1.0, 0.9)}
	if group == "Óxido":
		return {"shape": "jar", "color": Color(0.95, 0.55, 0.35)}
	if group == "Composto molecular":
		return {"shape": "flask", "color": Color(0.45, 0.65, 1.0)}
	if group == "Condição":
		return {"shape": "flask", "color": Color(1.0, 0.5, 0.2)}
	return {"shape": "flask", "color": Color.WHITE}

func _flask_texture(substance: Dictionary, big: bool) -> Texture2D:
	var visual: Dictionary = _group_visual(str(substance.get("group", "")))
	return _load_tex(str(visual["shape"]) + ("_64" if big else "_32"))

func _flask_color(substance: Dictionary) -> Color:
	var visual: Dictionary = _group_visual(str(substance.get("group", "")))
	return visual["color"]

# ---------------------------------------------------------------------------
# Construção da interface
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	var root: Control = Control.new()
	_root = root
	root.mouse_filter = Control.MOUSE_FILTER_STOP  # Impede cliques de chegarem ao jogo por trás
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center: CenterContainer = CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	panel.add_theme_stylebox_override("panel", _texture_style("panel_dark", Color.WHITE, 6.0, 6.0))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)

	var main: VBoxContainer = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)

	main.add_child(_make_label("Mesa de Alquimia", 32, COLOR_TITLE))
	main.add_child(_make_label("Escolha dois reagentes e combine-os. Observe o que acontece!", 18, COLOR_MUTED))

	var columns: HBoxContainer = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 20)
	main.add_child(columns)
	columns.add_child(_build_reagent_column())
	columns.add_child(_build_mix_column())

	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	main.add_child(footer)
	_progress_label = _make_label("", 18, COLOR_MUTED)
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(_progress_label)
	var help_button: Button = _make_button("Ajuda", 18)
	help_button.pressed.connect(_open_help)
	footer.add_child(help_button)
	var notebook_button: Button = _make_button("Caderno de reações", 18)
	notebook_button.pressed.connect(_open_notebook)
	footer.add_child(notebook_button)
	var close_button: Button = _make_button("Fechar (Esc)", 18)
	close_button.pressed.connect(close)
	footer.add_child(close_button)

	# Janelas extras por cima da mesa (criadas por último para ficarem na frente)
	var help_parts: Array = _build_overlay("Como usar a mesa", Vector2(780, 500))
	_help_overlay = help_parts[0]
	var help_text: RichTextLabel = help_parts[1]
	help_text.text = HELP_TEXT
	var notebook_parts: Array = _build_overlay("Caderno de reações", Vector2(820, 520))
	_notebook_overlay = notebook_parts[0]
	_notebook_text = notebook_parts[1]

# Janela grande com título, área de texto rolável e botão de fechar; devolve [janela, texto]
func _build_overlay(title: String, window_size: Vector2) -> Array:
	var overlay: Control = Control.new()
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center: CenterContainer = CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = window_size
	panel.add_theme_stylebox_override("panel", _texture_style("panel_dark", Color.WHITE, 6.0, 6.0))
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)

	var main: VBoxContainer = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)
	main.add_child(_make_label(title, 30, COLOR_TITLE))

	var text_panel: PanelContainer = PanelContainer.new()
	text_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_panel.add_theme_stylebox_override("panel", _texture_style("panel_white", Color.WHITE, 16.0, 12.0))
	main.add_child(text_panel)

	var text: RichTextLabel = RichTextLabel.new()
	text.bbcode_enabled = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", 21)
	text.add_theme_font_size_override("bold_font_size", 21)
	text.add_theme_color_override("default_color", COLOR_INK)
	text_panel.add_child(text)

	var close_button: Button = _make_button("Fechar (Esc)", 20)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.custom_minimum_size = Vector2(180, 44)
	close_button.pressed.connect(_close_overlays)
	main.add_child(close_button)
	return [overlay, text]

func _build_reagent_column() -> Control:
	var column: VBoxContainer = VBoxContainer.new()
	column.custom_minimum_size = Vector2(340, 0)
	column.add_theme_constant_override("separation", 6)
	column.add_child(_make_label("Reagentes", 24, COLOR_TITLE))

	var list_panel: PanelContainer = PanelContainer.new()
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_panel.add_theme_stylebox_override("panel", _texture_style("panel_white", Color.WHITE, 8.0, 8.0))
	column.add_child(list_panel)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_panel.add_child(scroll)

	_reagent_container = VBoxContainer.new()
	_reagent_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reagent_container.add_theme_constant_override("separation", 4)
	scroll.add_child(_reagent_container)
	return column

func _build_mix_column() -> Control:
	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	column.add_child(_make_label("Mistura", 24, COLOR_TITLE))

	var slots: HBoxContainer = HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	slots.add_theme_constant_override("separation", 10)
	column.add_child(slots)
	slots.add_child(_make_slot(0))
	slots.add_child(_make_symbol("+"))
	slots.add_child(_make_slot(1))
	slots.add_child(_make_symbol("→"))
	slots.add_child(_make_result_slot())

	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	_combine_button = _make_button("Combinar", 22)
	_combine_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_combine_button.custom_minimum_size = Vector2(0, 46)
	_combine_button.pressed.connect(_on_combine_pressed)
	actions.add_child(_combine_button)
	var clear_button: Button = _make_button("Limpar", 22)
	clear_button.custom_minimum_size = Vector2(0, 46)
	clear_button.pressed.connect(_clear_slots)
	actions.add_child(clear_button)

	_result_panel = PanelContainer.new()
	_result_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_result_panel.add_theme_stylebox_override("panel", _texture_style("panel_white", Color.WHITE, 12.0, 10.0))
	column.add_child(_result_panel)

	_result_label = RichTextLabel.new()
	_result_label.bbcode_enabled = true
	_result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_result_label.add_theme_font_size_override("normal_font_size", 19)
	_result_label.add_theme_font_size_override("bold_font_size", 19)
	_result_label.add_theme_color_override("default_color", COLOR_INK)
	_result_panel.add_child(_result_label)
	return column

# Slot de reagente: disco do pacote + frasco colorido; clicar no slot remove o reagente
func _make_slot(slot_index: int) -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = SLOT_SIZE
	button.tooltip_text = "Clique para remover"
	for style_name in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	button.pressed.connect(_on_slot_pressed.bind(slot_index))
	box.add_child(button)
	var parts: Array = _add_disc_and_flask(button)
	_slot_flasks.append(parts[1])

	var label: Label = _make_label("(vazio)", 16, COLOR_CREAM)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	_slot_labels.append(label)
	return box

# Slot de resultado: mostra o produto da reação (não é clicável)
func _make_result_slot() -> Control:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var host: Control = Control.new()
	host.custom_minimum_size = SLOT_SIZE
	box.add_child(host)
	var parts: Array = _add_disc_and_flask(host)
	_result_disc = parts[0]
	_result_flask = parts[1]

	_result_name = _make_label("(resultado)", 16, COLOR_CREAM)
	_result_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_result_name.custom_minimum_size = Vector2(SLOT_SIZE.x, 0)
	box.add_child(_result_name)
	return box

# Cria o disco e o frasco (inicialmente escondido) dentro de um nó; devolve [disco, frasco]
func _add_disc_and_flask(host: Control) -> Array:
	var disc: TextureRect = _make_fill_texture(_load_tex("disc_slot"))
	host.add_child(disc)
	disc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var flask: TextureRect = _make_fill_texture(null)
	host.add_child(flask)
	flask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flask.visible = false
	return [disc, flask]

func _make_fill_texture(tex: Texture2D) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _make_symbol(text: String) -> Label:
	var label: Label = _make_label(text, 34, COLOR_TITLE)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return label

func _make_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
	label.add_theme_constant_override("outline_size", 4)
	return label

func _make_button(text: String, font_size: int) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE  # Evita que E/Espaço "apertem" um botão sem querer
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_stylebox_override("normal", _texture_style("panel_light"))
	button.add_theme_stylebox_override("hover", _texture_style("panel_white"))
	button.add_theme_stylebox_override("pressed", _texture_style("panel_dark"))
	button.add_theme_stylebox_override("hover_pressed", _texture_style("panel_dark"))
	button.add_theme_stylebox_override("disabled", _texture_style("panel_light", Color(0.62, 0.62, 0.62)))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", COLOR_INK)
	button.add_theme_color_override("font_hover_color", COLOR_INK)
	button.add_theme_color_override("font_pressed_color", COLOR_CREAM)
	button.add_theme_color_override("font_hover_pressed_color", COLOR_CREAM)
	button.add_theme_color_override("font_disabled_color", Color(0.25, 0.2, 0.3, 0.8))
	return button

# ---------------------------------------------------------------------------
# Reagentes e slots
# ---------------------------------------------------------------------------

func _refresh_reagents() -> void:
	for child in _reagent_container.get_children():
		_reagent_container.remove_child(child)
		child.queue_free()

	for substance_id in _data.reagent_ids:
		var substance: Dictionary = _data.get_substance(substance_id)
		var button: Button = _make_button("", 18)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 44)
		button.add_theme_constant_override("h_separation", 8)
		if _data.is_available(substance_id, _knowledge_manager):
			button.text = _substance_label(substance)
			button.icon = _flask_texture(substance, false)
			var tint: Color = _flask_color(substance)
			for icon_color in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color"]:
				button.add_theme_color_override(icon_color, tint)
			button.pressed.connect(_on_reagent_pressed.bind(substance_id))
		else:
			var needed: String = _knowledge_name(str(substance.get("requires_knowledge", "")))
			button.text = "???  (aprenda: %s)" % needed
			button.disabled = true
		_reagent_container.add_child(button)

func _on_reagent_pressed(substance_id: String) -> void:
	_show_substance_info(substance_id)
	if substance_id == _slot_a or substance_id == _slot_b:
		return
	if _slot_a.is_empty():
		_slot_a = substance_id
	elif _slot_b.is_empty():
		_slot_b = substance_id
	else:
		_slot_b = substance_id  # Os dois slots cheios: o novo reagente substitui o segundo
	_refresh_slots()

func _on_slot_pressed(slot_index: int) -> void:
	if slot_index == 0:
		_slot_a = ""
	else:
		_slot_b = ""
	_refresh_slots()

func _clear_slots() -> void:
	_slot_a = ""
	_slot_b = ""
	_refresh_slots()

func _refresh_slots() -> void:
	_apply_slot(0, _slot_a)
	_apply_slot(1, _slot_b)
	_combine_button.disabled = _slot_a.is_empty() or _slot_b.is_empty()

func _apply_slot(slot_index: int, substance_id: String) -> void:
	var flask: TextureRect = _slot_flasks[slot_index]
	var label: Label = _slot_labels[slot_index]
	if substance_id.is_empty():
		flask.visible = false
		label.text = "(vazio)"
		return
	var substance: Dictionary = _data.get_substance(substance_id)
	flask.texture = _flask_texture(substance, true)
	flask.self_modulate = _flask_color(substance)
	flask.visible = true
	label.text = _short_label(substance)

# ---------------------------------------------------------------------------
# Combinar
# ---------------------------------------------------------------------------

func _on_combine_pressed() -> void:
	if _slot_a.is_empty() or _slot_b.is_empty():
		return

	var reaction: Dictionary = _data.find_reaction(_slot_a, _slot_b)
	var combo_key: String = CraftingData.make_key(_slot_a, _slot_b)

	if reaction.is_empty():
		_record(combo_key, "")
		_show_failure()
	else:
		var reaction_id: String = str(reaction["id"])
		var is_new: bool = not (reaction_id in _get_discovered())
		_record(combo_key, reaction_id)
		_unlock_knowledge(reaction)
		_show_success(reaction, is_new)
	_refresh_progress()

func _show_success(reaction: Dictionary, is_new: bool) -> void:
	var text: String = ""
	if is_new:
		text += "[b][color=#9C4A00]Nova descoberta![/color][/b]\n"
	else:
		text += "[b][color=#1B6E1B]Reação realizada![/color][/b]\n"
	text += "\n[b]Equação:[/b] %s\n" % _pretty(str(reaction["equation"]))
	text += "[b]Tipo:[/b] %s\n" % str(reaction.get("type", ""))

	var product_names: Array[String] = []
	for product_id in reaction.get("products", []):
		product_names.append(_substance_label(_data.get_substance(str(product_id))))
	text += "[b]Produtos:[/b] %s\n" % ", ".join(product_names)
	text += "\n%s" % str(reaction.get("explanation", ""))
	_set_result(text)
	_show_result_slot(reaction)

func _show_failure() -> void:
	var messages: Array[String] = [
		"Nada aconteceu. Essas substâncias, nessas condições, não reagem entre si.",
		"Nenhuma reação visível. Será que esses dois reagentes têm afinidade?",
		"A mistura continua igual. Tente outra combinação!"
	]
	var text: String = "[b][color=#B3261E]%s[/color][/b]\n\n" % messages.pick_random()
	text += "Dica: pense no tipo de cada reagente (metal, gás, ácido, base...) e no que a combinação poderia formar. Algumas reações só acontecem com aquecimento."
	_set_result(text)
	_show_result_slot_empty()

func _unlock_knowledge(reaction: Dictionary) -> void:
	if _knowledge_manager == null:
		return
	for knowledge_id in reaction.get("knowledge", []):
		_knowledge_manager.unlock_knowledge(str(knowledge_id))

func _record(combo_key: String, reaction_id: String) -> void:
	if _save_manager and _save_manager.has_method("record_craft"):
		_save_manager.record_craft(combo_key, reaction_id)

# ---------------------------------------------------------------------------
# Slot de resultado (frasco do produto + animações curtas)
# ---------------------------------------------------------------------------

func _reset_result_slot() -> void:
	_result_flask.visible = false
	_result_disc.modulate = Color.WHITE
	_result_name.text = "(resultado)"

func _show_result_slot(reaction: Dictionary) -> void:
	var product_labels: Array[String] = []
	var first_product: Dictionary = {}
	for product_id in reaction.get("products", []):
		var product: Dictionary = _data.get_substance(str(product_id))
		if first_product.is_empty():
			first_product = product
		product_labels.append(_short_label(product))
	if first_product.is_empty():
		_reset_result_slot()
		return

	_result_disc.modulate = Color.WHITE
	_result_flask.texture = _flask_texture(first_product, true)
	_result_flask.self_modulate = _flask_color(first_product)
	_result_flask.visible = true
	_result_name.text = " + ".join(product_labels)

	# Pequena animação: o frasco "aparece" com um pulo
	_result_flask.pivot_offset = _result_flask.size / 2.0
	_result_flask.scale = Vector2(0.3, 0.3)
	_result_flask.modulate = Color(1, 1, 1, 0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_result_flask, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_result_flask, "modulate:a", 1.0, 0.25)

func _show_result_slot_empty() -> void:
	_result_flask.visible = false
	_result_name.text = "Nada reagiu"
	# O disco pisca em vermelho e volta ao normal
	_result_disc.modulate = Color(1.0, 0.55, 0.55)
	var tween: Tween = create_tween()
	tween.tween_property(_result_disc, "modulate", Color.WHITE, 0.6)

# ---------------------------------------------------------------------------
# Textos auxiliares
# ---------------------------------------------------------------------------

func _show_substance_info(substance_id: String) -> void:
	var substance: Dictionary = _data.get_substance(substance_id)
	if substance.is_empty():
		return
	var text: String = "[b]%s[/b]" % _substance_label(substance)
	text += "\n[color=#3949AB]%s[/color]\n\n" % str(substance.get("group", ""))
	text += str(substance.get("description", ""))
	_set_result(text)

func _open_help() -> void:
	_close_overlays()
	_help_overlay.visible = true

func _open_notebook() -> void:
	_close_overlays()
	var discovered: Array = _get_discovered()
	var text: String = "[b]Reações descobertas: %d/%d[/b]\n" % [discovered.size(), _data.reaction_ids.size()]
	text += "Cada ??? é uma reação que você ainda não descobriu. O tipo é uma pista!\n\n"
	for reaction_id in _data.reaction_ids:
		var reaction: Dictionary = _data.reactions[reaction_id]
		var reaction_type: String = str(reaction.get("type", ""))
		if reaction_id in discovered:
			text += "[b]%s[/b]  [color=#3949AB](%s)[/color]\n" % [_pretty(str(reaction["equation"])), reaction_type]
			text += "%s\n\n" % str(reaction.get("explanation", ""))
		else:
			text += "[b]???[/b]  [color=#3949AB](%s)[/color]\n\n" % reaction_type
	_notebook_text.text = text
	_notebook_text.scroll_to_line(0)
	_notebook_overlay.visible = true

func _refresh_progress() -> void:
	_progress_label.text = "Reações descobertas: %d/%d" % [_get_discovered().size(), _data.reaction_ids.size()]

func _set_result(bbcode: String) -> void:
	_result_label.text = bbcode

func _get_discovered() -> Array:
	if _save_manager and _save_manager.has_method("get_discovered_reactions"):
		return _save_manager.get_discovered_reactions()
	return []

func _substance_label(substance: Dictionary) -> String:
	var substance_name: String = str(substance.get("name", "?"))
	var formula: String = str(substance.get("formula", ""))
	if formula.is_empty():
		return substance_name
	return "%s  (%s)" % [substance_name, _pretty(formula)]

# Rótulo curto (fórmula, ou o nome quando não há fórmula) para os slots
func _short_label(substance: Dictionary) -> String:
	var formula: String = str(substance.get("formula", ""))
	if formula.is_empty():
		return str(substance.get("name", "?"))
	return _pretty(formula)

func _knowledge_name(knowledge_id: String) -> String:
	if _knowledge_manager and _knowledge_manager.has_method("get_knowledge_info"):
		var info: Dictionary = _knowledge_manager.get_knowledge_info(knowledge_id)
		return str(info.get("name", knowledge_id))
	return knowledge_id

# Converte "2 H2 + O2 -> 2 H2O" em "2 H₂ + O₂ → 2 H₂O":
# números logo depois de uma letra (ou de ")") viram subscritos; coeficientes no início do termo não.
func _pretty(text: String) -> String:
	var result: String = text.replace("->", "→")
	if not USE_UNICODE_SUBSCRIPTS:
		return result
	var output: String = ""
	var previous: String = ""
	var previous_was_subscript: bool = false
	for i in range(result.length()):
		var character: String = result.substr(i, 1)
		var is_digit: bool = SUBSCRIPTS.has(character)
		var follows_letter: bool = previous != "" and (previous.to_upper() != previous.to_lower() or previous == ")")
		if is_digit and (follows_letter or previous_was_subscript):
			output += SUBSCRIPTS[character]
			previous_was_subscript = true
		else:
			output += character
			previous_was_subscript = false
		previous = character
	return output
