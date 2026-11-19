extends Node

const MOD_NAME = "Brotato-MoreGhostWeaponsFixed"
var mod_dir: String


func _init():
	mod_dir = ModLoaderMod.get_unpacked_dir().plus_file(MOD_NAME)
	var extensions = mod_dir.plus_file("extensions")
	ModLoaderMod.install_script_extension(extensions.plus_file("singletons/run_data.gd"))
	ModLoaderMod.install_script_extension(extensions.plus_file("singletons/item_service.gd"))
	ModLoaderMod.install_script_extension(extensions.plus_file("main.gd"))
	_install_translations_from_csv(mod_dir.plus_file("translations/flotato_translation.csv"))


func _install_translations_from_csv(csv_path: String) -> void:
	var file := File.new()
	if file.open(csv_path, File.READ) != OK:
		ModLoaderLog.error("Failed to open translation CSV: %s" % csv_path, MOD_NAME)
		return

	var lines := file.get_as_text().split("\n", false)
	file.close()
	if lines.empty():
		return

	var header := lines[0].strip_edges().split(",")
	var translations := []
	for col in range(1, header.size()):
		var translation := Translation.new()
		translation.locale = header[col]
		translations.append(translation)

	for i in range(1, lines.size()):
		var row := lines[i].strip_edges().split(",")
		for col in range(1, min(row.size(), header.size())):
			translations[col - 1].add_message(row[0], row[col])

	for translation in translations:
		TranslationServer.add_translation(translation)


func _ready() -> void:
	var content = load(mod_dir.plus_file("content_data/content_data.tres"))
	var base_weapons = ItemService.base_game_item_set.weapons
	for weapon in content.weapons:
		if base_weapons.has(weapon):
			continue
		weapon._generate_hashes()
		for effect in weapon.effects:
			if effect != null and effect.has_method("_generate_hashes"):
				effect._generate_hashes()
		base_weapons.append(weapon)
	ItemService.invalidate_weapons_cache()

	for i in content.weapons_characters.size():
		for character in content.weapons_characters[i]:
			if not character.starting_weapons.has(content.weapons[i]):
				character.starting_weapons.append(content.weapons[i])

	var turret_effect = load(mod_dir.plus_file("content/effects/turret_gain_stat_every_killed_enemies_effect.gd"))
	if not ItemService.effects.has(turret_effect):
		ItemService.effects.append(turret_effect)
