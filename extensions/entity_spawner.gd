extends "res://global/entity_spawner.gd"

# EFFECT : gain_stat_when_killed_single_scaling
var mg_gain_stat_when_killed_single_scaling_killed_count: Array = [ {}, {}, {}, {}]

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _on_enemy_died(enemy: Node2D, _args: Entity.DieArgs) -> void:
	._on_enemy_died(enemy, _args)
	if !_cleaning_up:
			_mgep_gain_stat_when_killed_single_scaling_on_enemy_died()

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _mgep_gain_stat_when_killed_single_scaling_on_enemy_died() -> void:
	for player_index in RunData.players_data.size():
			var effect_items: Array = RunData.get_player_effect(
				Utils.mgep_gain_stat_when_killed_single_scaling_hash,
				player_index
			)

			var player_killed_count: Dictionary = mg_gain_stat_when_killed_single_scaling_killed_count[player_index]
			for effect_index in effect_items.size():
				player_killed_count[effect_index] = player_killed_count.get(effect_index, 0) + 1
				var effect: Array = effect_items[effect_index]
				var value: int = effect[0]
				var stat: int = effect[1]
				var stat_nb: int = effect[2]
				var scaling_stat: int = effect[3]
				var scaling_percent: float = effect[4]
				var tracking_key: int = effect[5]

				var scaling_value: int = int(value + Utils.get_stat(scaling_stat, player_index) * scaling_percent)
				if scaling_value <= 0 or player_killed_count[effect_index] % scaling_value != 0:
					continue

				player_killed_count[effect_index] = 0 # For dynamic scaling_value
				RunData.add_stat(stat, stat_nb, player_index)
				RunData.ncl_add_effect_tracking_value(tracking_key, stat_nb, player_index)

				# Update when first add hit_protection
				if stat == Keys.hit_protection_hash:
					_main._players[player_index]._hit_protection += stat_nb
