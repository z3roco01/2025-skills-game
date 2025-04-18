extends Tag
# handles the darkening of the sprites, takes in any text and if it contains mc it will darken mc
# if it contains "char" it will darken char, can do both in the same box
# ex: [dark mcIsfhauhFchar] will darken both char and mc, since it only checks for contains

class_name DarkTag

func matched(tagArgs: String, box: DialogueBox) -> String:
	var charsToDarken = tagArgs.to_lower()
	
	if(charsToDarken.contains("mc")):
		box.darkenStatus["mc"] = DarknessStatus.DARKEN
	if(charsToDarken.contains("char")):
		box.darkenStatus["char"] = DarknessStatus.DARKEN
	
	return ""

func getPrefix() -> String:
	return "dark "
