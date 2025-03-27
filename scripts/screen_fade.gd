extends ColorRect

@export var fadeType : FadeType
@export var duration : float = 1.0

enum FadeType {
	FadeIn,
	FadeOut,
}

func _ready() -> void:
	var fadeEnd = 0
	match fadeType:
		FadeType.FadeIn:
			color.a = 1
		FadeType.FadeOut:
			color.a = 0
			fadeEnd = 1
	get_tree().create_tween().tween_property(self, "color:a", fadeEnd, duration)
