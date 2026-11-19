class_name TurretGainStatEveryKilledEnemiesEffect
extends NullEffect

export(String) var stat = ""
export(int) var stat_nb = 1
var stat_hash: int = Keys.empty_hash


func _init() -> void:
	effect_sign = Sign.NEGATIVE


func _generate_hashes() -> void:
	._generate_hashes()
	stat_hash = Keys.generate_hash(stat)


static func get_id() -> String:
	return "effect_turret_gain_stat_every_killed_enemies"


func get_sign(_from_sign: int, _from_value: int) -> int:
	return Sign.NEGATIVE


func get_args(_player_index: int) -> Array:
	return [str(stat_nb), tr(stat.to_upper()), str(value)]


func get_text(player_index: int, colored: bool = true) -> String:
	var key_text = key.to_upper() if text_key.length() == 0 else text_key.to_upper()
	var args = get_args(player_index)
	return Text.text(key_text, args, [Sign.POSITIVE, Sign.POSITIVE, Sign.POSITIVE] if colored else [])


func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized.stat = stat
	serialized.stat_nb = stat_nb
	return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	stat = serialized.stat
	stat_hash = Keys.generate_hash(stat)
	stat_nb = serialized.stat_nb as int
