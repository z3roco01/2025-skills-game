extends HSlider

func _value_changed(new_value: float) -> void:
	Settings.scrollSpeedMul = value
