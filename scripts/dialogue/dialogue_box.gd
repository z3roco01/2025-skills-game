extends Node

# this class holds all the information about a dialogue box
# such as the text to display and the expression to set

class_name DialogueBox

# singal that will be connected in the main dialogue instance, will show our text
signal showBox(tbox: DialogueBox)
# signal that will lookup a variable then put its value in the first element of the passed array
signal lookupVar(varName: String, returnArray: Array)

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
		
		# now find which type of tag it is
		# if it starts with a $ then its a varaible tag
		if(matched.begins_with("$")):
			# pass the variable name with the $ over to getVar, which will get the value for replacement
			tagReplacement = getVar(matched)
		elif(matched.begins_with("expr ")): # if this tag beings with "expr " then it is an expression change
			# set the expression id to the tag minus the "expr " at the start
			expressionId = withoutTag(matched, "expr ")
		elif(matched.begins_with("mcexpr ")):
			mcExpression = withoutTag(matched, "mcexpr ")
		elif(matched.begins_with("dec ")): # if the tag begins with "dec " then its a decider
			# strip the tag type off of the left, then split by | up to 3 options
			var choices = withoutTag(matched, "dec ").split("|", true, 3)
			# choose the one that lines up with the players descriptor choice
			var choice = choices[Identity.descriptors]
			# then replace the tag with the chosen string
			tagReplacement = choice
		elif(matched.begins_with("name ")): # when this tag appears, set the name for this box
			# strip off the formatting and set the name
			nameText = withoutTag(matched, "name ")
			nameText = nameText.lstrip(" ")
		elif(matched.begins_with("dark ")): # will contain the character to darken this box
			# get it as lowercase so case doesnt matter
			var charsToDarken = withoutTag(matched, "dark ").to_lower()
			
			if(charsToDarken.contains("mc")):
				darkenStatus["mc"] = DarknessStatus.DARKEN
			if(charsToDarken.contains("char")):
				darkenStatus["char"] = DarknessStatus.DARKEN
		elif(matched.begins_with("light ")): # will contain the characters to lighten this box
			# get it as lowercase so case doesnt matter
			var charsToDarken = withoutTag(matched, "lighten ").to_lower()
			
			if(charsToDarken.contains("mc")):
				darkenStatus["mc"] = DarknessStatus.LIGHTEN
			if(charsToDarken.contains("char")):
				darkenStatus["char"] = DarknessStatus.LIGHTEN
		elif(matched.begins_with("overlay ")): # [overlay #041fcaff]
			overlayColor = Color(withoutTag(matched, "overlay "))
		elif(matched.begins_with("bg ")):
			bgId = withoutTag(matched, "bg ")
		elif(matched.begins_with("cg ")): # for cgs, will obscure everything but the dialogue
			cgId = withoutTag(matched, "cg ")
		elif(matched.begins_with("sfx ")): # for sound, will play on the start of box and wont stop till its done
			sfxId = withoutTag(matched, "sfx ")
		
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
	lookupVar.emit(varName.lstrip("$"), returnedVal)
	
	return returnedVal[0]

# shows this dialogue box by setting the shown text to its text and setting the expression
func show() -> void:
	showBox.emit(self)
