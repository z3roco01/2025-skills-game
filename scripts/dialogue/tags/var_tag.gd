extends Tag
# the tag that handles replacable variables such as name and pronouns
# ex: [$name] will get the name

class_name VarTag

func matched(varName: String, box: DialogueBox) -> String:
	return box.getVar(varName)

func getPrefix() -> String:
	return "$"
