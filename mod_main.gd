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
		"player_explosion.gd",
		# EFFECTS: gain_stat_when_killed_single_scaling
		"player_run_data.gd",
		"utils.gd",
		"weapon_service.gd",
		"entity_spawner.gd",
		"melee_weapon.gd",
		"ranged_weapon.gd"
	]

	for path in extensions:
		var extension_path = ext_dir + path
		ModLoaderMod.install_script_extension(extension_path)
