extends Control


# dictionary of expressions for this character
# you cant type hint on export, but this will have string keys and CompressedTexture2D values
@export var expressions = {}
# the expression that the character will start on 
@export var defaultExpression: String
@export var mcDefaultExpression: String
# the different background that can be used 
@export var backgrounds = {}
@export var startingBackground : String

# the node that holds the dialogue text 
@onready var dialogueTextNode = $dialoguePanel/text
# the node holding the name of the speaking character
@onready var nameTextNode = $dialoguePanel/nameText
# gets the node that holds the characters image
@onready var characterTexture = $characterTexture
@onready var mcTexture = $mcTexture
@onready var nextCharTimer = $nextCharTimer
@onready var background = $background
# used for things like black screen
@onready var overlay = $overlay
# the color that modulate will be set to when darkening
@export var darkenColor = Color(0.56, 0.56, 0.56)
# the color that module will be set to when lightening
@export var lightenColor = Color(1, 1, 1)
# the script containing the script with the markup
@export var dialogueScript = "[name LANCE] i like [$name], [$subject] [$is] very [dec pretty|handsome|beautiful] [expr content]! [nb] peeeee[nb][name BALLS] but i hate [$object] [expr anger]"
# if there is music to play it can be set
@export var music : String
# a dictionary that holds all the variables used in dialogue
var dialogueVariables = {}
# an array which holds all the dialogue boxes, in the order they play in
# add dummy dialogue box so it will be typed h
var dialogueBoxes = []
# keeps track of how many dialogue boxes we have
var dialogueBoxCount = 0
# the current dialogue box we are showing
var curDialogueBox = 1
# text to show, needed so we can have the typing effect
var textToShow = ""
# how far we are into showing out text
var curTextIdx = 0

func _ready() -> void:
	if(!music.is_empty()):
		MusicPlayer.playMusic(music)
	# set the characters expression to the default
	characterTexture.texture = expressions[defaultExpression]
	mcTexture.texture = expressions[mcDefaultExpression]
	background.texture = backgrounds[startingBackground]
	
	# populate the dialogue variables with things such as pronouns and name
	dialogueVariables["name"] = Identity.playerName
	dialogueVariables["subject"] = Identity.pronounSubjective
	dialogueVariables["object"] = Identity.pronounObjective
	dialogueVariables["determ"] = Identity.pronounDeterminer
	dialogueVariables["posses"] = Identity.pronounPossessive
	dialogueVariables["reflex"] = Identity.pronounReflexive
	if(Identity.usesIs()): # if is should be used set the is variable to "is"
		dialogueVariables["is"] = "is"
	else: # else means are should be used so set the is variable to "are"
		dialogueVariables["is"] = "are"
	
	# set the characters to the lighten color ( default state )
	# incase a color differant than white was set
	characterTexture.modulate = lightenColor
	mcTexture.modulate = lightenColor
	
	# splits the text by the new box tag into every indivdual boxes tet
	var boxTexts = dialogueScript.split("[nb]", false)
	
	# create a dialogue box for each box text
	for boxText in boxTexts:
		# create the new dialogue box
		var newDialogueBox = DialogueBox.new()
		# connect the two signals to the dialogue instance
		newDialogueBox.lookupVar.connect(lookupVar)
		newDialogueBox.showBox.connect(showBox)
		# set the text to the split text
		newDialogueBox.dialogueText = boxText
		# set the default expression to the default expression for this instance
		newDialogueBox.defaultExpression = defaultExpression
		# format the text for this box
		newDialogueBox.formatText()
		
		# make space for the new dialogue box
		dialogueBoxes.resize(dialogueBoxCount+1)
		# add the new dialogue box to the array
		dialogueBoxes[dialogueBoxCount] = newDialogueBox
		# then increment the count
		dialogueBoxCount += 1
	
	# show the first dialogue box
	dialogueBoxes[0].show()

func changeExpression(expressionId: String) -> void:
	# first strip the "expr " off of the passed string to get the raw expression id
	# then pass that into the expression bank to get the expression texture then set the shown texture to it
	characterTexture.texture = expressions[expressionId]

# if passed in "mc" for the char it will set the mcs darkness, and same for "char" for the other character
# if darkness is DARKEN modulate will be set to darkenColor and if LIGTHEN will be set to lightenColor
func darkenCharacter(char: String, darkness: DialogueBox.DARKEN_STAUTS) -> void:
	var darknessColor : Color
	# set the color that the darkness is ( or return if unchanged )
	if(darkness == DialogueBox.DARKEN_STAUTS.UNCHANGED):
		return
	elif(darkness == DialogueBox.DARKEN_STAUTS.DARKEN):
		darknessColor = darkenColor
	elif(darkness == DialogueBox.DARKEN_STAUTS.LIGHTEN):
		darknessColor = lightenColor
	
	# then set the proper textures modulate value
	if(char == "mc"):
		mcTexture.modulate = darknessColor
	elif(char == "char"):
		characterTexture.modulate = darknessColor

# called by a dialogue box, will show its text and expression
func showBox(text: String, expressionId: String, nameText: String, darknessDict: Dictionary, overlayColor: Color, bgId: String) -> void:
	dialogueTextNode.text = ""
	textToShow = text
	
	var lookupReturn : Array[String]
	if(!nameText.is_empty()): # only set name when it is being changed
		nameTextNode.text = nameText
	if(nameText == "mc"): # replace mc with the players name
		nameTextNode.text = getVar("name")
	
	curTextIdx = 0
	darkenCharacter("mc", darknessDict["mc"])
	darkenCharacter("char", darknessDict["char"])
	changeExpression(expressionId)
	changeOverlay(overlayColor)
	if(!bgId.is_empty()):
		background.texture = backgrounds[bgId]
	nextCharTimer.start()

# called to change the overlay color, will also fade it
func changeOverlay(newColor: Color) -> void:
	# dont waste time if theyre equal
	if(newColor == overlay.color): return
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color", newColor, 0.25)

# called by a dialogue box, will get the variables value then put it in the array
# array needed since its a signal and cannot directly return
func lookupVar(varName: String, returnArray: Array) -> void:
	returnArray[0] = getVar(varName)

# gets the dialogue variable passed
func getVar(varName: String) -> String:
	return dialogueVariables[varName]

func _on_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton and !event.is_pressed()): # on mouse button release
		if(textToShow == dialogueTextNode.text): # if the text box is completely shown
			if(curDialogueBox < dialogueBoxCount):
				dialogueBoxes[curDialogueBox].show()
				curDialogueBox += 1
			else:
				queue_free()
		else: # comptely show all text
			dialogueTextNode.text = textToShow

# this class holds all the information about a dialogue box
# such as the text to display and the expression to set
class DialogueBox:
	# singal that will be connected in the main dialogue instance, will show our text
	signal showBox(text: String, expressionId: String, nameText: String, darkenStatus: Dictionary, overlayColor: Color, bgId: String)
	# signal that will lookup a variable then put its value in the first element of the passed array
	signal lookupVar(varName: String, returnArray: Array)
	
	# the color the overlay will be set to for this box
	var overlayColor = Color(0, 0, 0, 0)
	# the text that well be shown in the text box
	var dialogueText: String
	# the expression that will be set at the start of the box
	var expressionId: String
	# regex that matched to each tag
	var tagRegex = RegEx.new()
	# the default expression that it will default to
	var defaultExpression: String
	# the name being shown
	var nameText = ""
	# determins if characters will be darkened, lightened or unchanged
	# key for mc is "mc" key for the other character is "char"
	var darkenStatus : Dictionary
	# the new background, if there is one
	var background = ""
	
	# create the regex and format the text
	func _init() -> void:
		# compile the regex for matching tags
		# need to match everything but right bracket since godot implementation is broken
		tagRegex.compile("\\[[^\\]]+\\]")
		
		# set the darken status of all characters to unchanged
		darkenStatus["mc"] = DARKEN_STAUTS.UNCHANGED
		darkenStatus["char"] = DARKEN_STAUTS.UNCHANGED
	
	# formats the dialogue text by replacing and parsing tags
	func formatText() -> void:
		# start the expression id off at the default incase the expression is not set in this box
		expressionId = defaultExpression
		
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
			elif(matched.begins_with("dec ")): # if the tag begins with "dec " then its a decider
				# strip the tag type off of the left, then split by | up to 3 options
				var choices = withoutTag(matched, "dec ").split("|", true, 3)
				# choose the one that lines up with the players descriptor choice
				var choice = choices[Identity.descriptors]
				# then replace the tag with the chosen string
				tagReplacement = choice
			elif(matched.begins_with("name ")): # when this tag appears, set the name for this box
				# strip off the formatting and set the name
				nameText = withoutTag(matched, "name")
				nameText = nameText.lstrip(" ")
			elif(matched.begins_with("dark ")): # will contain the character to darken this box
				# get it as lowercase so case doesnt matter
				var charsToDarken = withoutTag(matched, "dark ").to_lower()
				
				if(charsToDarken.contains("mc")):
					darkenStatus["mc"] = DARKEN_STAUTS.DARKEN
				if(charsToDarken.contains("char")):
					darkenStatus["char"] = DARKEN_STAUTS.DARKEN
			elif(matched.begins_with("light ")): # will contain the characters to lighten this box
				# get it as lowercase so case doesnt matter
				var charsToDarken = withoutTag(matched, "lighten ").to_lower()
				
				if(charsToDarken.contains("mc")):
					darkenStatus["mc"] = DARKEN_STAUTS.LIGHTEN
				if(charsToDarken.contains("char")):
					darkenStatus["char"] = DARKEN_STAUTS.LIGHTEN
			elif(matched.begins_with("overlay ")): # [overlay #041fcaff]
				overlayColor = Color(withoutTag(matched, "overlay "))
			elif(matched.begins_with("bg ")):
				background = withoutTag(matched, "bg ")
				background = background.lstrip(" ")
			
			replaceTag(matched, tagReplacement)
	
	# returns matched without the tag
	func withoutTag(matched: String, tag: String) -> String:
		return matched.lstrip(tag)
	
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
		showBox.emit(dialogueText, expressionId, nameText, darkenStatus, overlayColor, background)
	
	enum DARKEN_STAUTS { DARKEN, LIGHTEN, UNCHANGED}

# means we are ready to show the next character
func _on_next_char_timer_timeout() -> void:
	if(!textToShow.is_empty() and dialogueTextNode.text != textToShow and curTextIdx < textToShow.length()):
		dialogueTextNode.text += textToShow[curTextIdx]
		curTextIdx += 1
	if(curTextIdx < textToShow.length()):
		nextCharTimer.start()

class QuestionBox extends DialogueBox:
	pass
