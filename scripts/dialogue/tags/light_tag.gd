extends Tag
# same as the darken tag, but for lightening them
# ex: [light mc|asd|char] will lighten both char and mc, since it only checks for contains

class_name LightTag

func matched(tagArgs: String, box: DialogueBox) -> String:
	var charsToDarken = tagArgs.to_lower()
	
	if(charsToDarken.contains("mc")):
		box.darkenStatus["mc"] = DarknessStatus.LIGHTEN
	if(charsToDarken.contains("char")):
		box.darkenStatus["char"] = DarknessStatus.LIGHTEN
	
	return ""

func getPrefix() -> String:
	return "light "
