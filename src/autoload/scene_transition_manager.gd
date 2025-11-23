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

