extends HSlider

func _ready() -> void:
	value = Settings.textSpeed

func _value_changed(new_value: float) -> void:
	Settings.textSpeed = new_value
