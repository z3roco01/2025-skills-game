extends Range

@export var busName : String
var idx

func _ready() -> void:
	# get idx of the bus target
	idx =AudioServer.get_bus_index(busName)
	# get current value of volume and set slider to that value
	value = db_to_linear(AudioServer.get_bus_volume_db(idx))

func _value_changed(new_value: float) -> void:
	# set new volume
	AudioServer.set_bus_volume_db(idx, linear_to_db(value))
