extends "res://weapons/melee/melee_weapon.gd"

# 幽魂扳手本体。
#
# 它召唤的炮塔通过 meta 弱引用回指某一把扳手（见 extensions/turret.gd），
# 炮塔造成的击杀在这里累计，从而记到这把扳手头上，
# 不需要改动 weapon_data / run_data / main。

const GhostWrenchTurretEffect = preload("res://mods-unpacked/Untargetable-MoreGhostExpansionPack/extensions/effects/ghost_wrench_turret_effect.gd")

var _ghost_wrench_turrets: Array = []


func _ready() -> void:
	# _ready 在 Godot 3 会沿脚本继承链自动逐层调用，这里不要手动调 ._ready()。
	add_to_group(GhostWrenchTurretEffect.WRENCH_GROUP)


func is_ghost_wrench_weapon() -> bool:
	return true


func get_ghost_wrench_tier() -> int:
	for effect in effects:
		if (
			effect != null
			and effect.has_method("is_ghost_wrench_turret_effect")
			and effect.is_ghost_wrench_turret_effect()
		):
			return effect.get_ghost_wrench_turret_tier()
	return -1


# ══════════════════════════════════════════ Turret registration (weak reference) ══════════════════════════════════════════ #
func register_ghost_wrench_turret(turret: Node) -> void:
	if turret == null:
		return
	_prune_ghost_wrench_turrets()
	for ref in _ghost_wrench_turrets:
		if ref.get_ref() == turret:
			return
	_ghost_wrench_turrets.append(weakref(turret))


func unregister_ghost_wrench_turret(turret: Node) -> void:
	_prune_ghost_wrench_turrets()
	var kept: Array = []
	for ref in _ghost_wrench_turrets:
		if ref.get_ref() != turret:
			kept.append(ref)
	_ghost_wrench_turrets = kept


func get_ghost_wrench_turret_count() -> int:
	_prune_ghost_wrench_turrets()
	return _ghost_wrench_turrets.size()


func _prune_ghost_wrench_turrets() -> void:
	var alive: Array = []
	for ref in _ghost_wrench_turrets:
		if not (ref is WeakRef):
			continue
		var turret = ref.get_ref()
		if (
			not is_instance_valid(turret)
			or not turret.is_inside_tree()
			or turret.is_queued_for_deletion()
		):
			continue
		if ("dead" in turret and turret.dead) or ("_pending_die" in turret and turret._pending_die):
			continue
		if (
			not turret.has_method("get_ghost_wrench_owner_node")
			or turret.get_ghost_wrench_owner_node() != self
		):
			continue
		alive.append(ref)
	_ghost_wrench_turrets = alive


# ══════════════════════════════════════════ Cumulative kills ══════════════════════════════════════════ #
func on_ghost_wrench_turret_killed_enemy(thing_killed: Node) -> void:
	if not is_instance_valid(thing_killed):
		return
	_enemies_killed_this_wave_count += 1
	for effect in effects:
		if effect is GainStatEveryKilledEnemiesEffect:
			if (
				effect.value > 0
				and effect.stat_hash != Keys.empty_hash
				and _enemies_killed_this_wave_count % effect.value == 0
			):
				RunData.add_stat(effect.stat_hash, effect.stat_nb, player_index)
				emit_signal("tracked_value_updated", effect.stat_nb)
		elif effect is SpawnStructureEveryKilledEnemiesEffect:
			if (
				effect.value > 0
				and effect.structure_effect != null
				and _enemies_killed_this_wave_count % effect.value == 0
			):
				emit_signal(
					"wanted_to_spawn_structure",
					effect.structure_effect,
					thing_killed.global_position
				)
				emit_signal("tracked_value_updated", 1)
