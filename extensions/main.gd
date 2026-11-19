extends "res://main.gd"

var _turret_tracking_hashes := [
	Keys.generate_hash("item_turret"),
	Keys.item_turret_flame_hash,
	Keys.generate_hash("item_turret_laser"),
	Keys.generate_hash("item_turret_rocket"),
	Keys.generate_hash("weapon_flo_gho_wrench_turret"),
]
var _enemies_killed_by_turrets := {}
var _wrench_candidates := []


func _on_enemy_took_damage(
	enemy: Enemy,
	value: int,
	knockback_direction: Vector2,
	is_crit: bool,
	is_dodge: bool,
	is_protected: bool,
	armor_did_something: bool,
	args: TakeDamageArgs,
	hit_type: int,
	is_one_shot: bool
) -> void:
	._on_enemy_took_damage(enemy, value, knockback_direction, is_crit, is_dodge, is_protected, armor_did_something, args, hit_type, is_one_shot)
	if enemy._pending_die and _is_turret_damage(enemy, args):
		_enemies_killed_by_turrets[enemy.get_instance_id()] = true


func _on_enemy_died(enemy: Enemy, args: Entity.DieArgs) -> void:
	var killed_by_turret = _enemies_killed_by_turrets.erase(enemy.get_instance_id())
	._on_enemy_died(enemy, args)
	if not killed_by_turret or _cleaning_up or not args.enemy_killed_by_player:
		return

	var player_index = args.killed_by_player_index
	if player_index < 0 or player_index >= _players.size() or not is_instance_valid(_players[player_index]):
		return

	_wrench_candidates.clear()
	for weapon in RunData.get_player_weapons_ref(player_index):
		if weapon.weapon_id == RunData.GHOST_WRENCH_ID:
			_wrench_candidates.append(weapon)
	if not _wrench_candidates.empty():
		Utils.get_rand_element(_wrench_candidates).record_turret_kill(player_index)


func _is_turret_damage(enemy: Enemy, args: TakeDamageArgs) -> bool:
	if args.hitbox == null and args.is_burning and enemy._burning != null:
		var burn = enemy._burning
		if is_instance_valid(burn.from):
			return burn.from is Turret
		return _turret_tracking_hashes.has(burn.tracking_key_hash) or (
			not burn.scaling_stats.empty() and Utils.get_first_scaling_stat(burn.scaling_stats) == Keys.stat_engineering_hash
		)

	var source = args.from
	if not is_instance_valid(source) and args.hitbox != null:
		source = args.hitbox.from
	if is_instance_valid(source) and source is Turret:
		return true
	return args.hitbox != null and _turret_tracking_hashes.has(args.hitbox.damage_tracking_key_hash)
