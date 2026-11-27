extends "res://weapons/ranged/ranged_weapon.gd"

# ══════════════════════════════════════════ Variables ══════════════════════════════════════════ #
var _mgep_kill_count_scaling: Dictionary = {}

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func on_killed_something(_thing_killed: Node, hitbox: Hitbox) -> void:
	.on_killed_something(_thing_killed, hitbox)
	WeaponService.mg_gain_stat_when_killed_scaling_single(
		effects,
		_mgep_kill_count_scaling,
		_parent,
		player_index
	)
