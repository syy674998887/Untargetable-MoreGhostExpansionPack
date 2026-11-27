extends "res://projectiles/player_explosion.gd"

# 幽魂扳手炮塔造成的爆炸：把爆炸的击杀转发给炮塔（再由炮塔找到对应扳手）。
# 原版 player_explosion 只会把击杀转给 Weapon 来源，炮塔不是 Weapon，故需要单独扩展。

const GhostWrenchTurretEffect = preload("res://mods-unpacked/Untargetable-MoreGhostExpansionPack/extensions/effects/ghost_wrench_turret_effect.gd")


func set_from(from: Node) -> void:
	if not is_inside_tree():
		return
	.set_from(from)
	if not is_instance_valid(from):
		return
	if not from.has_meta(GhostWrenchTurretEffect.OWNER_META):
		return
	if not from.has_method("on_ghost_wrench_turret_killed_something"):
		return
	if not is_connected("killed_something", from, "on_ghost_wrench_turret_killed_something"):
		connect("killed_something", from, "on_ghost_wrench_turret_killed_something")
