extends "res://entities/structures/turret/turret.gd"

# 为“幽魂扳手召唤的炮塔”打标签，并把炮塔与其召唤者（幽魂扳手）一一关联起来。
# 关联只使用 meta 标签 + 弱引用，不对 Turret 本体做任何破坏性修改，且兼容其它 mod。
# 击杀归属通过 Turret 的 meta 上的弱引用找到对应扳手，再交给扳手累计。

const GhostWrenchTurretEffect = preload("res://mods-unpacked/Untargetable-MoreGhostExpansionPack/extensions/effects/ghost_wrench_turret_effect.gd")


func set_data(data: Resource) -> void:
	.set_data(data)
	if (
		data != null
		and data.has_method("is_ghost_wrench_turret_effect")
		and data.is_ghost_wrench_turret_effect()
	):
		_bind_ghost_wrench_owner(data.get_ghost_wrench_turret_tier())
	else:
		_clear_ghost_wrench_owner()


# ══════════════════════════════════════════ 归属绑定 ══════════════════════════════════════════ #
func _bind_ghost_wrench_owner(tier: int) -> void:
	_clear_ghost_wrench_owner()
	set_meta(GhostWrenchTurretEffect.TIER_META, tier)
	if not is_inside_tree():
		return
	var wrench = _find_best_ghost_wrench(tier)
	if wrench == null:
		return
	set_meta(GhostWrenchTurretEffect.OWNER_META, weakref(wrench))
	wrench.register_ghost_wrench_turret(self)


func _find_best_ghost_wrench(tier: int) -> Node:
	var selected: Node = null
	var selected_count: int = 0
	for candidate in get_tree().get_nodes_in_group(GhostWrenchTurretEffect.WRENCH_GROUP):
		if (
			not is_instance_valid(candidate)
			or not candidate.is_inside_tree()
			or candidate.is_queued_for_deletion()
		):
			continue
		if (
			not candidate.has_method("get_ghost_wrench_tier")
			or not candidate.has_method("get_ghost_wrench_turret_count")
		):
			continue
		if candidate.player_index != player_index:
			continue
		if candidate.get_ghost_wrench_tier() != tier:
			continue
		var count: int = candidate.get_ghost_wrench_turret_count()
		if selected == null or count < selected_count:
			selected = candidate
			selected_count = count
	return selected


func _clear_ghost_wrench_owner() -> void:
	var wrench = _get_ghost_wrench_owner()
	if wrench != null and wrench.has_method("unregister_ghost_wrench_turret"):
		wrench.unregister_ghost_wrench_turret(self)
	if has_meta(GhostWrenchTurretEffect.OWNER_META):
		remove_meta(GhostWrenchTurretEffect.OWNER_META)
	if has_meta(GhostWrenchTurretEffect.TIER_META):
		remove_meta(GhostWrenchTurretEffect.TIER_META)


# 只读取，不修改 meta（清除动作统一由 _clear_ghost_wrench_owner 负责）。
func _get_ghost_wrench_owner() -> Node:
	if not has_meta(GhostWrenchTurretEffect.OWNER_META):
		return null
	var wrench_ref = get_meta(GhostWrenchTurretEffect.OWNER_META)
	if not (wrench_ref is WeakRef):
		return null
	var wrench = wrench_ref.get_ref()
	if (
		not is_instance_valid(wrench)
		or not wrench.is_inside_tree()
		or wrench.is_queued_for_deletion()
	):
		return null
	return wrench


# 供扳手在清理弱引用时回查：这个炮塔当前是否仍指向我。
func get_ghost_wrench_owner_node() -> Node:
	return _get_ghost_wrench_owner()


# ══════════════════════════════════════════ 击杀归属 ══════════════════════════════════════════ #
func on_ghost_wrench_turret_killed_something(thing_killed: Node, _hitbox = null) -> void:
	var wrench = _get_ghost_wrench_owner()
	if wrench == null or not wrench.has_method("on_ghost_wrench_turret_killed_enemy"):
		return
	wrench.on_ghost_wrench_turret_killed_enemy(thing_killed)


func _spawn_projectile(position: Vector2) -> Node:
	var projectile =._spawn_projectile(position)
	if _get_ghost_wrench_owner() == null:
		return projectile
	if not is_instance_valid(projectile) or not ("_hitbox" in projectile):
		return projectile
	var hitbox = projectile._hitbox
	if hitbox == null or not hitbox.has_signal("killed_something"):
		return projectile
	# 弹丸回池时会断开 killed_something 的全部连接，所以每次发射都要重新接上。
	if not hitbox.is_connected("killed_something", self, "on_ghost_wrench_turret_killed_something"):
		hitbox.connect(
			"killed_something",
			self,
			"on_ghost_wrench_turret_killed_something",
			[hitbox]
		)
	return projectile


# 燃烧致死：燃烧 tick 会以 hitbox == null 调用 from.on_weapon_hit_something。
# take_damage 在 _pending_die 时会返回 [0,0,false]，因此只有“真正致死的那一次”同时满足
# damage_dealt > 0 且 _pending_die == true，可用于防止重复计数。
func on_weapon_hit_something(thing_hit: Node, damage_dealt: int, hitbox: Hitbox) -> void:
	if hitbox != null or damage_dealt <= 0:
		return
	if (
		not is_instance_valid(thing_hit)
		or not ("_pending_die" in thing_hit)
		or not thing_hit._pending_die
	):
		return
	on_ghost_wrench_turret_killed_something(thing_hit)
