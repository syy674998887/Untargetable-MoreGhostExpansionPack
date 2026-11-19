extends "res://singletons/run_data.gd"

const GHOST_WRENCH_ID = "weapon_flo_gho_wrench"

var _wrenches_at_wave_start := {}


func on_wave_start(timer: WaveTimer) -> void:
	.on_wave_start(timer)
	_wrenches_at_wave_start.clear()
	for player_index in get_player_count():
		for weapon in get_player_weapons_ref(player_index):
			if weapon.weapon_id == GHOST_WRENCH_ID:
				_wrenches_at_wave_start[weapon] = [weapon.wrench_mod_turret_kills, weapon.wrench_mod_turret_eng]


func reset_to_start_wave_state() -> void:
	for weapon in _wrenches_at_wave_start:
		var tracking = _wrenches_at_wave_start[weapon]
		weapon.wrench_mod_turret_kills = tracking[0]
		weapon.wrench_mod_turret_eng = tracking[1]
	.reset_to_start_wave_state()


func combine_weapon(weapon_data: WeaponData, other_weapon, player_index: int) -> WeaponData:
	if weapon_data.weapon_id != GHOST_WRENCH_ID:
		return .combine_weapon(weapon_data, other_weapon, player_index)
	var previous_weapons = get_player_weapons_ref(player_index).duplicate()
	var combined = .combine_weapon(weapon_data, other_weapon, player_index)
	_transfer_wrench_tracking(combined, previous_weapons, player_index)
	return combined


func meca_upgrade_weapon(weapon_data: WeaponData, upgraded_weapon: WeaponData, player_index: int) -> WeaponData:
	if weapon_data.weapon_id != GHOST_WRENCH_ID:
		return .meca_upgrade_weapon(weapon_data, upgraded_weapon, player_index)
	var previous_weapons = get_player_weapons_ref(player_index).duplicate()
	var upgraded = .meca_upgrade_weapon(weapon_data, upgraded_weapon, player_index)
	if upgraded != null:
		_transfer_wrench_tracking(upgraded, previous_weapons, player_index)
	return upgraded


func _transfer_wrench_tracking(upgraded: WeaponData, previous_weapons: Array, player_index: int) -> void:
	var kept_weapons = get_player_weapons_ref(player_index)
	upgraded.wrench_mod_turret_kills = 0
	upgraded.wrench_mod_turret_eng = 0
	for weapon in previous_weapons:
		if weapon.weapon_id == GHOST_WRENCH_ID and not kept_weapons.has(weapon):
			upgraded.wrench_mod_turret_kills += weapon.wrench_mod_turret_kills
			upgraded.wrench_mod_turret_eng += weapon.wrench_mod_turret_eng
