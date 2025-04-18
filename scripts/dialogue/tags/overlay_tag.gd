extends Tag
# sets the overlay colour to the supplied colour
# note, alpha is not required but is supported
# ex: [overlay #A3FC02FF] will set it to the colour #a3FC02FF

class_name OverylayTag

func matched(tagArgs: String, box: DialogueBox) -> String:
	box.overlayColor = Color(tagArgs)
	
	return ""

func getPrefix() -> String:
	return "overlay "
