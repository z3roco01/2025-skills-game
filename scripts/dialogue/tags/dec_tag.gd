extends Tag
# picks between 3 options based on if the player has chosen fem, masc or andro
# first is feminine, second is masculine, third is androgenous
# ex [dec fem|masc|andro]

class_name DecTag

func matched(tagArgs: String, box: DialogueBox) -> String:
	var choices = tagArgs.split("|", true, 3)
	# choose the one that lines up with the players descriptor choice
	var choice = choices[Identity.descriptors]
	# then replace the tag with the chosen string
	return choice

func getPrefix() -> String:
	return "dec "
