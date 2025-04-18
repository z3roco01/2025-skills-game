extends Tag
# a tag that simply replaces the tag with nothing and sets a variable in the box

class_name VarRepTag

var varName: String
var prefix: String

# varName is the name of the variable in the box
# prefix is the prefix of the tag
static func create(VarName: String, Prefix: String) -> VarRepTag:
	var tag = VarRepTag.new()
	tag.varName = VarName
	tag.prefix = Prefix
	return tag

func matched(tagArgs: String, box: DialogueBox) -> String:
	box.set(varName, tagArgs)
	
	return ""

func getPrefix() -> String:
	return prefix
