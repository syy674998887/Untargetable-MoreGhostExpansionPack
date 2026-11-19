extends "res://items/global/weapon_data.gd"

const LEGACY_MOD_DIR = "res://mods-unpacked/Untargetable-MoreGhostWeaponsFixed/"
const MOD_DIR = "res://mods-unpacked/Brotato-MoreGhostWeaponsFixed/"


func deserialize_and_merge(serialized: Dictionary) -> void:
	var weapon_data := serialized.duplicate()
	var saved_stats: Dictionary = serialized.stats.duplicate()
	for field in ["custom_on_cooldown_sprite", "projectile_scene"]:
		var path = saved_stats.get(field)
		if path is String and path.begins_with(LEGACY_MOD_DIR):
			saved_stats[field] = MOD_DIR + path.trim_prefix(LEGACY_MOD_DIR)
	weapon_data.stats = saved_stats
	.deserialize_and_merge(weapon_data)
