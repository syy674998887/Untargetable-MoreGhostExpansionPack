extends "res://items/global/weapon_data.gd"

const TurretKillEffect = preload("res://mods-unpacked/Brotato-MoreGhostWeaponsFixed/content/effects/turret_gain_stat_every_killed_enemies_effect.gd")

var wrench_mod_turret_kills := 0
var wrench_mod_turret_eng := 0


func record_turret_kill(player_index: int) -> void:
	var effect = _find_turret_effect(effects)
	if effect == null:
		return
	wrench_mod_turret_kills += 1
	if wrench_mod_turret_kills % int(max(1, effect.value)) == 0:
		RunData.add_stat(Keys.generate_hash(effect.stat), effect.stat_nb, player_index)
		wrench_mod_turret_eng += effect.stat_nb


func _find_turret_effect(weapon_effects: Array):
	for effect in weapon_effects:
		if effect is TurretKillEffect:
			return effect
	return null


func get_effects_text(player_index: int, with_tracking_text: bool = true) -> String:
	var text = .get_effects_text(player_index, with_tracking_text)
	if with_tracking_text and wrench_mod_turret_eng > 0:
		var tracking = Text.text("EFFECT_EXTRA_TURRET_ENGINEERING", [str(wrench_mod_turret_eng)])
		text += "\n[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + tracking + "[/color]"
	return text


func duplicate(subresources := false) -> Resource:
	var copy = .duplicate(subresources)
	copy.wrench_mod_turret_kills = wrench_mod_turret_kills
	copy.wrench_mod_turret_eng = wrench_mod_turret_eng
	return copy


func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized.wrench_mod_turret_kills = str(wrench_mod_turret_kills)
	serialized.wrench_mod_turret_eng = str(wrench_mod_turret_eng)
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	var default_turret_effect = _find_turret_effect(effects)
	.deserialize_and_merge(serialized)
	if default_turret_effect != null and _find_turret_effect(effects) == null and _find_turret_effect(mutation_removed_effects) == null:
		effects.append(default_turret_effect)
	wrench_mod_turret_kills = int(serialized.get("wrench_mod_turret_kills", 0))
	wrench_mod_turret_eng = int(serialized.get("wrench_mod_turret_eng", 0))
