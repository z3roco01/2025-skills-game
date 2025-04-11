extends Tag
# the tag that handles replacable variables such as name and pronouns
# ex: [$name] will get the name

class_name VarTag

func doesMatch(tag: String) -> bool:
	return tag.begins_with("$")

func matched(tag: String, box: DialogueBox) -> String:
	return box.getVar(tag)
