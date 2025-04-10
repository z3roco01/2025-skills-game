extends Control

# the scene to show when this one is done
@export var nextScene: PackedScene
# dictionary of expressions for this character
# you cant type hint on export, but this will have string keys and CompressedTexture2D values
@export var expressions = {}
# the expression that the character will start on 
@export var defaultExpression: String
@export var mcDefaultExpression: String

# holds all the bgs, similar to expressions
@export var backgrounds = {}
@export var startingBg: String

# the node that holds the dialogue text 
@onready var dialogueTextNode = $dialoguePanel/text
# the node holding the name of the speaking character
@onready var nameTextNode = $dialoguePanel/nameText
# gets the node that holds the characters image
@onready var characterTexture = $characterTexture
@onready var mcTexture = $mcTexture
@onready var background = $background
@onready var cgTexture = $cgTexture
@onready var sfxPlayer = $sfxPlayer
@onready var nextCharTimer = $nextCharTimer
@onready var boopSoundPlayer = $boopPlayer
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
# very similar to the backgrounds dict, but for cgs
@export var cgs : Dictionary
# much like other dictionaries
@export var sounds : Dictionary
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

# handles the boop sound effect playing
var random = RandomNumberGenerator.new()
var shouldPlayBoops = true # tracks whenboops should play
const MIN_PITCH_SCALE = 3.4 # max and min of the boops pitch
const MAX_PITCH_SCALE = 3.7

func _ready() -> void:
	if(!music.is_empty()):
		MusicPlayer.playMusic(music)
	
	setBg(startingBg)
	
	# set the characters expression to the default
	characterTexture.texture = expressions[defaultExpression]
	
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
	
func mcChangeExpression(expressionId: String) -> void:
	mcTexture.texture = expressions[expressionId]

# if passed in "mc" for the char it will set the mcs darkness, and same for "char" for the other character
# if darkness is DARKEN modulate will be set to darkenColor and if LIGTHEN will be set to lightenColor
func darkenCharacter(char: String, darkness: DialogueBox.DARKEN_STATUS) -> void:
	var darknessColor : Color
	# set the color that the darkness is ( or return if unchanged )
	if(darkness == DialogueBox.DARKEN_STATUS.UNCHANGED):
		return
	elif(darkness == DialogueBox.DARKEN_STATUS.DARKEN):
		darknessColor = darkenColor
	elif(darkness == DialogueBox.DARKEN_STATUS.LIGHTEN):
		darknessColor = lightenColor
	
	# then set the proper textures modulate value
	if(char == "mc"):
		mcTexture.modulate = darknessColor
	elif(char == "char"):
		characterTexture.modulate = darknessColor

# called by a dialogue box, will show its text and expression
func showBox(box: DialogueBox) -> void:
	dialogueTextNode.text = ""
	textToShow = box.dialogueText
	
	var lookupReturn : Array[String]
	if(!box.nameText.is_empty()): # only set name when it is being changed
		nameTextNode.text = box.nameText
	if(box.nameText == "mc"): # replace mc with the players name
		nameTextNode.text = getVar("name")
	
	curTextIdx = 0
	
	darkenCharacter("mc", box.darkenStatus["mc"])
	darkenCharacter("char", box.darkenStatus["char"])
	
	if(!box.expressionId.is_empty()):
		changeExpression(box.expressionId)
	
	if(!box.mcExpression.is_empty()):
		mcChangeExpression(box.mcExpression)
	
	setOverlay(box.overlayColor)
	
	if(!box.bgId.is_empty()):
		setBg(box.bgId)
	
	if(!box.cgId.is_empty()):
		setCg(box.cgId)
	else:
		clearCg()
	
	if(!box.sfxId.is_empty()):
		sfxPlayer.stop()
		sfxPlayer.stream = sounds[box.sfxId]
		sfxPlayer.play()
	nextCharTimer.start()

# fades between the past cg and this cg
func setCg(id: String) -> void:
	cgTexture.texture = cgs[id]

# empty the cg texture
func clearCg() -> void:
	cgTexture.texture = null

# sets the overlasy with a fade
func setOverlay(color: Color) -> void:
	if(color == overlay.color): return
	
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color", color, 0.25)

# sets the background to the background with the supplied id
func setBg(bgId: String) -> void:
	background.texture = backgrounds[bgId]

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
				shouldPlayBoops = true # yes boops
			else:
				playNextScene()
		else: # comptely show all text
			dialogueTextNode.text = textToShow
			shouldPlayBoops = false # no more boops >:(

# shows the next scene and kills this one
func playNextScene() -> void:
	var instance = nextScene.instantiate()
	add_sibling(instance)
	queue_free()

# this class holds all the information about a dialogue box
# such as the text to display and the expression to set
class DialogueBox:
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
		darkenStatus["mc"] = DARKEN_STATUS.UNCHANGED
		darkenStatus["char"] = DARKEN_STATUS.UNCHANGED
	
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
					darkenStatus["mc"] = DARKEN_STATUS.DARKEN
				if(charsToDarken.contains("char")):
					darkenStatus["char"] = DARKEN_STATUS.DARKEN
			elif(matched.begins_with("light ")): # will contain the characters to lighten this box
				# get it as lowercase so case doesnt matter
				var charsToDarken = withoutTag(matched, "lighten ").to_lower()
				
				if(charsToDarken.contains("mc")):
					darkenStatus["mc"] = DARKEN_STATUS.LIGHTEN
				if(charsToDarken.contains("char")):
					darkenStatus["char"] = DARKEN_STATUS.LIGHTEN
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
	
	enum DARKEN_STATUS { DARKEN, LIGHTEN, UNCHANGED}

# means we are ready to show the next character
func _on_next_char_timer_timeout() -> void:
	if(!textToShow.is_empty() and dialogueTextNode.text != textToShow and curTextIdx < textToShow.length()):
		dialogueTextNode.text += textToShow[curTextIdx]
		curTextIdx += 1
	if(curTextIdx < textToShow.length()):
		nextCharTimer.start()
	if(shouldPlayBoops): # check if boop allowed
			# randomise boop sound pitch
			boopSoundPlayer.pitch_scale = random.randf_range(MIN_PITCH_SCALE, MAX_PITCH_SCALE)
			# play boop
			boopSoundPlayer.play()

class QuestionBox extends DialogueBox:
	pass
