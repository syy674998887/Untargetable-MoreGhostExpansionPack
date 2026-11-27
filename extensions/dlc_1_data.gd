extends "res://dlcs/dlc_1/dlc_1_data.gd"

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func curse_item(
	item_data: ItemParentData,
	player_index: int,
	turn_randomization_off: bool = false,
	min_modifier: float = 0.0
) -> ItemParentData:
	var can_be_cursed: bool = ItemService.can_item_be_cursed(item_data)
	var cursed_item_data: ItemParentData =.curse_item(
			item_data,
			player_index,
			turn_randomization_off,
			min_modifier
	)
	if not can_be_cursed:
			return cursed_item_data

	return _mgep_curse_item(cursed_item_data, player_index, turn_randomization_off, min_modifier)

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func _mgep_curse_item(
	cursed_item_data: ItemParentData,
	_player_index: int,
	turn_randomization_off: bool,
	min_modifier: float
) -> ItemParentData:
	if not has_effect_mgep(cursed_item_data.effects):
			return cursed_item_data

	var new_item_data: ItemParentData = cursed_item_data.duplicate()
	var new_effects: Array = []

	for effect in new_item_data.effects:
			if not is_effect_mgep(effect):
				new_effects.append(effect)
				continue

			var effect_modifier: float = _get_cursed_item_effect_modifier(
				turn_randomization_off,
				min_modifier
			)

			var new_effect: Effect = effect.duplicate()

			var id: String = new_effect.get_id()
			var key: int = new_effect.key_hash
			var cskey: int = new_effect.custom_key_hash

			match [id, key, cskey]:
				["mgep_gain_stat_when_killed_single_scaling", _, _]:
					new_effect.scaling_percent = Utils.ncl_curse_effect_value(
						new_effect.scaling_percent,
						effect_modifier,
						{"is_negative": true, "min_num": 1}
					)

			new_effects.append(new_effect)
	new_item_data.effects = new_effects
	return new_item_data

# ══════════════════════════════════════════ Method ══════════════════════════════════════════ #
func has_effect_mgep(effects: Array) -> bool:
	for effect in effects:
			if is_effect_mgep(effect):
				return true
	return false

func is_effect_mgep(effect: Effect) -> bool:
	return (
			effect.get_id().begins_with("mgep")
			or effect.key.begins_with("mgep")
			or effect.custom_key.begins_with("mgep")
	)
