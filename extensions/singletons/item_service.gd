extends "res://singletons/item_service.gd"

func _get(property):
	if property == "elites":
		return []
	return null
