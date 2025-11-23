extends Node

# Singleton para gerenciar transições de cena e posicionamento do player
var should_spawn_at_well: bool = false

func set_spawn_at_well(value: bool) -> void:
	should_spawn_at_well = value

func get_spawn_at_well() -> bool:
	return should_spawn_at_well

func clear_spawn_flag() -> void:
	should_spawn_at_well = false

