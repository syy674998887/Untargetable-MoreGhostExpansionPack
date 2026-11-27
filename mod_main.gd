extends Node

const MOD_NAME = "Untargetable-MoreGhostExpansionPack"
const MOD_DIR = "Untargetable-MoreGhostExpansionPack/"

var dir: String = ""
var ext_dir: String = ""

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
func _init():
	dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR
	ext_dir = dir + "extensions/"

	# Add extensions
	install_script_extensions()

# ══════════════════════════════════════════ Custom ══════════════════════════════════════════ #
func install_script_extensions() -> void:
	var extensions: Array = [
		"turret.gd",
		# WEAPONS: ghost_wrench[ 1/2 ]

		"player_explosion.gd",
		# WEAPONS: ghost_wrench[ 2/2 ]

		"player_run_data.gd",
		# EFFECTS

		"utils.gd",
		# EFFECTS

		"weapon_service.gd",
		# EFFECTS: gain_stat_when_killed_single_scaling[ 1/4 ]

		"entity_spawner.gd",
		# EFFECTS: gain_stat_when_killed_single_scaling[ 2/4 ]

		"melee_weapon.gd",
		# EFFECTS: gain_stat_when_killed_single_scaling[ 3/4 ]

		"ranged_weapon.gd",
		# EFFECTS: gain_stat_when_killed_single_scaling[ 4/4 ]
	]

	for path in extensions:
		var extension_path = ext_dir + path
		ModLoaderMod.install_script_extension(extension_path)
