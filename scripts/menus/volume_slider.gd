extends Range

@export var busName : String

func _value_changed(new_value: float) -> void:
	var idx = AudioServer.get_bus_index(busName)
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
