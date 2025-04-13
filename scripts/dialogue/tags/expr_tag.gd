extends Tag
# the tag that handles switching expressions
# will lookup the supplied expression in the expression dict on show
# ex: [expr lance_ecstatic] would set the expression to lance's ecstatic expression

class_name ExprTag

func doesMatch(tag: String) -> bool:
	return tag.begins_with("expr ")

func matched(tag: String, box: DialogueBox) -> String:
	return box.getVar(tag)
