extends "res://singletons/weapon_service.gd"

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func mg_gain_stat_when_killed_scaling_single(
	effects: Array,
	kill_count_dict: Dictionary,
	player: Player,
	player_index: int
) -> void:
	for effect_index in range(effects.size()):
			var effect = effects[effect_index]
			if effect.get_id() != "mgep_gain_stat_when_killed_single_scaling":
				continue

			kill_count_dict[effect_index] = kill_count_dict.get(effect_index, 0) + 1
			var scaling_value: int = effect.value + Utils.get_stat(
				effect.scaling_stat_hash,
				player_index
			) * effect.scaling_percent as int
			if scaling_value <= 0 or kill_count_dict[effect_index] % scaling_value != 0:
				continue

			kill_count_dict[effect_index] = 0
			RunData.add_stat(effect.stat_hash, effect.stat_nb, player_index)
			RunData.ncl_add_effect_tracking_value(
				effect.tracking_key_hash,
				effect.stat_nb,
				player_index
			)
			if effect.stat_hash == Keys.hit_protection_hash:
				player._hit_protection += effect.stat_nb
