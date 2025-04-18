extends Node

# this class holds all the information about a dialogue box
# such as the text to display and the expression to set

class_name DialogueBox

# singal that will be connected in the main dialogue instance, will show our text
signal showBox(tbox: DialogueBox)
# signal that will lookup a variable then put its value in the first element of the passed array
signal lookupVar(varName: String, returnArray: Array)

# holds an instance of all the tags for comparing
static var TAG_TYPES: Array[Tag] = [
	VarTag.new(),
	VarRepTag.create("expressionId", "expr "), # expression tag [expr lance_ecstatic]
	VarRepTag.create("mcExpression", "mcexpr "), # mc expression tag [mcexpr mc_happy]
	DecTag.new(),
	VarRepTag.create("nameText", "name"), # name tag [name MC]
	DarkTag.new(),
	LightTag.new(),
	OverylayTag.new(),
	VarRepTag.create("bgId", "bg "), # background tag [bg parlour]
	VarRepTag.create("cgId", "cg "), # cg tag [cg lance_kiss]
	VarRepTag.create("sfxId", "sfx "), # sound effect tag [sfx punch]
	]

# the color the overlay will be set to for this box
var overlayColor = Color(0, 0, 0, 0)
# the text that well be shown in the text box
var dialogueText: String
# the expression that will be set at the start of the box
var expressionId: String
var mcExpression: String
# regex that matched to each tag
var tagRegex = RegEx.new()
# the name being shown
var nameText = ""
# determins if characters will be darkened, lightened or unchanged
# key for mc is "mc" key for the other character is "char"
var darkenStatus : Dictionary
# the bg that will be shown when this box is
var bgId: String
# if set, is the cg that will be shown
var cgId: String
# sound effect that will play on the start of this box
var sfxId: String

# create the regex and format the text
func _init() -> void:
	# compile the regex for matching tags
	# need to match everything but right bracket since godot implementation is broken
	tagRegex.compile("\\[[^\\]]+\\]")
	
	# set the darken status of all characters to unchanged
	darkenStatus["mc"] = DarknessStatus.UNCHANGED
	darkenStatus["char"] = DarknessStatus.UNCHANGED

# formats the dialogue text by replacing and parsing tags
func formatText() -> void:
	# match every tag in the text ( [] )
	for result in tagRegex.search_all(dialogueText):
		# gets the string that we matched to, does still have the brackets that need to be stripped
		var matched = result.get_string()
		# strip the brackets from the matched string
		matched = matched.lstrip("[").rstrip("]")
		
		# what the tag will be replaced with in the original script
		var tagReplacement = ""
		
		# loop over every tag type and check if it matches
		for tagType in TAG_TYPES:
			# if it does match, run its logic and get the replacement
			# then break from the loop
			if(tagType.doesMatch(matched)):
				tagReplacement = tagType.matched(tagType.stripPrefix(matched), self)
		
		replaceTag(matched, tagReplacement)

# returns matched without the tag
func withoutTag(matched: String, tag: String) -> String:
	return matched.trim_prefix(tag)

# replaced the passed tag with the passed string in the original dialogue
func replaceTag(tag: String, newStr: String) -> void:
	dialogueText = dialogueText.replace("[" + tag + "]", newStr)

# finds the value of a dialogue variable
func getVar(varName: String) -> String:
	var returnedVal = [""]
	# emit a signal to the dialogue instance that looks up the variable and puts it in the passed array
	# need to remove the $ first
	lookupVar.emit(varName, returnedVal)
	
	return returnedVal[0]

# shows this dialogue box by setting the shown text to its text and setting the expression
func show() -> void:
	showBox.emit(self)
