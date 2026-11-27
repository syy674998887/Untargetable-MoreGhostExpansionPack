tool
extends "res://effects/items/turret_effect.gd"

# 幽魂扳手召唤炮塔所使用的结构（炮塔）效果。
# 这里只负责“标记”这个炮塔来自某一档的幽魂扳手，以及与扳手之间建立关联所需的常量。
# 真正把击杀归属到具体扳手的逻辑在 extensions/turret.gd 与 ghost_wrench.gd 中。

const WRENCH_GROUP = "mgep_ghost_wrenches"
const TIER_META = "mgep_ghost_wrench_tier"
const OWNER_META = "mgep_ghost_wrench_owner"

export(int) var ghost_wrench_tier = 0


static func get_id() -> String:
	return "mgep_ghost_wrench_turret"


func is_ghost_wrench_turret_effect() -> bool:
	return true


func get_ghost_wrench_turret_tier() -> int:
	return ghost_wrench_tier


func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized.ghost_wrench_tier = ghost_wrench_tier
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	ghost_wrench_tier = int(serialized.get("ghost_wrench_tier", 0))
