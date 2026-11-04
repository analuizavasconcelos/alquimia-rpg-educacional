extends Node

# Singleton para gerenciar transições de cena e posicionamento do player
var should_spawn_at_well: bool = false

# Estado persistente entre cenas
var saved_camera_zoom: Vector2 = Vector2(5, 5)  # Zoom padrão
var saved_mobile_hud_enabled: bool = false  # Estado da HUD mobile
var saved_mobile_hud_manual: bool = false  # Se foi habilitada manualmente

func set_spawn_at_well(value: bool) -> void:
	should_spawn_at_well = value

func get_spawn_at_well() -> bool:
	return should_spawn_at_well

func clear_spawn_flag() -> void:
	should_spawn_at_well = false

# Posição de retorno: ao entrar em um interior (ex.: biblioteca), a porta guarda onde o jogador
# deve reaparecer ao voltar para a cena de origem.
var return_position: Vector2 = Vector2.ZERO
var return_scene: String = ""

func set_return_position(position: Vector2, scene_path: String) -> void:
	return_position = position
	return_scene = scene_path

func has_return_for(scene_path: String) -> bool:
	return not return_scene.is_empty() and return_scene == scene_path

# Devolve a posição guardada e limpa o registro (só vale uma vez)
func take_return_position() -> Vector2:
	var result: Vector2 = return_position
	return_position = Vector2.ZERO
	return_scene = ""
	return result

# Salvar estado da câmera
func save_camera_zoom(zoom: Vector2) -> void:
	saved_camera_zoom = zoom

# Restaurar zoom da câmera
func get_saved_camera_zoom() -> Vector2:
	return saved_camera_zoom

# Salvar estado da HUD mobile
func save_mobile_hud_state(enabled: bool, manual: bool) -> void:
	saved_mobile_hud_enabled = enabled
	saved_mobile_hud_manual = manual

# Restaurar estado da HUD mobile
func get_saved_mobile_hud_state() -> Dictionary:
	return {
		"enabled": saved_mobile_hud_enabled,
		"manual": saved_mobile_hud_manual
	}

