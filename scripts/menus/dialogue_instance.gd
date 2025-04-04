extends Control


# dictionary of expressions for this character
# you cant type hint on export, but this will have string keys and CompressedTexture2D values
@export var expressions = {}
# the expression that the character will start on 
@export var defaultExpression: String

# the node that holds the dialogue text 
@onready var dialogueTextNode = $dialoguePanel/text
# the node holding the name of the speaking character
@onready var nameTextNode = $dialoguePanel/nameText
# gets the node that holds the characters image
@onready var characterTexture = $characterTexture
@onready var nextCharTimer = $nextCharTimer

# the script containing the script with the markup
#@export var dialogueScript = "[name LANCE] i like [$name], [$subject] [$is] very [dec pretty|handsome|beautiful] [expr content]! [nb] peeeee[nb][name BALLS] but i hate [$object] [expr anger]"
@export var dialogueScript = "[question fartface[$name]|poopy{deez|nuts}]"
# a dictionary that holds all the variables used in dialogue
var dialogueVariables = {}
# an array which holds all the dialogue boxes, in the order they play in
# add dummy dialogue box so it will be typed h
var dialogueBoxes = []
# keeps track of how many dialogue boxes we have
var dialogueBoxCount = 0
# the current dialogue box we are showing
var curDialogueBox = 0
# text to show, needed so we can have the typing effect
var textToShow = ""
# how far we are into showing out text
var curTextIdx = 0

func _ready() -> void:
	# set the characters expression to the default
	characterTexture.texture = expressions[defaultExpression]
	
	print(dialogueScript)
	print(expressions)
	print(defaultExpression)
	
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

# called by a dialogue box, will show its text and expression
func showBox(text: String, expressionId: String, nameText: String) -> void:
	dialogueTextNode.text = ""
	textToShow = text
	if(!nameText.is_empty()): # only set name when it is being changed
		nameTextNode.text = nameText
	curTextIdx = 0
	changeExpression(expressionId)
	nextCharTimer.start()

# called by a dialogue box, will get the variables value then put it in the array
func lookupVar(varName: String, returnArray: Array) -> void:
	returnArray[0] = dialogueVariables[varName]

func _on_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton and !event.is_pressed()): # on mouse button release
		print("Fart")
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
	signal showBox(text: String, expressionId: String, nameText: String)
	# signal that will lookup a variable then put its value in the first element of the passed array
	signal lookupVar(varName: String, returnArray: Array)
	
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
	
	# create the regex and format the text
	func _init() -> void:
		# compile the regex for matching tags
		# need to match everything but right bracket since godot implementation is broken
		tagRegex.compile("\\[[^\\]]+\\]")
	
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
			
			# now find which type of tag it is
			# if it starts with a $ then its a varaible tag
			if(matched.begins_with("$")):
				# pass the variable name with the $ over to varReplace which handles the rest
				varReplace(matched)
			elif(matched.begins_with("expr ")): # if this tag beings with "expr " then it is an expression change
				# set the expression id to the tag minus the "expr " at the start
				expressionId = matched.lstrip("expr ")
				# then remove the tag by replacing it with nothing
				dialogueText = dialogueText.replace("[" + matched + "]", "")
			elif(matched.begins_with("dec ")): # if the tag begins with "dec " then its a decider
				# strip the tag type off of the left, then split by | up to 3 options
				var choices = matched.lstrip("dec ").split("|", true, 3)
				# choose the one that lines up with the players descriptor choice
				var choice = choices[Identity.descriptors]
				# then replace the instance of this tag with the decided string
				dialogueText = dialogueText.replace("[" + matched + "]", choice)
			elif(matched.begins_with("name ")): # when this tag appears, set the name for this box
				# strip off the formatting and set the name
				nameText = matched.lstrip("name")
				# remove the tag from the dialogue
				dialogueText = dialogueText.replace("[" + matched + "]", "")
			elif(matched.begins_with("question ")): # WE ARE DOING A QUESTION, BIG THINGS COMING
				#q1|q2|q3[a1|a2|a3]
				# strip off the question  first so that the lenght and index is right
				var striped = matched.lstrip("question ")
				# strip off the answers and split the questions into an array of 3
				var quests = striped.substr(0, striped.length()-striped.find("{")).split("|", true, 3)
				# strip off questions and split anwsers into an array
				var ans = striped.substr(striped.find("{")+1).rstrip("}").split("|", true, 3)
				var questBoxes = []
				
				for quest in quests:
					var box = DialogueBox.new()
					box.dialogueText = quest
					box.formatText()
					questBoxes.append(box)
				for fart in questBoxes:
					print(fart.dialogueText)
	
	# replaces the passed variable with the value from the dictionary, replaces in the dialogue texture
	func varReplace(varName: String) -> void:
		var returnedVal = [""]
		# emit a signal to the dialogue instance that looks up the variable and puts it in the passed array
		# need to remove the $ first
		lookupVar.emit(varName.lstrip("$"), returnedVal)
		
		dialogueText = dialogueText.replace("[" + varName + "]", returnedVal[0])
	
	# shows this dialogue box by setting the shown text to its text and setting the expression
	func show() -> void:
		showBox.emit(dialogueText, expressionId, nameText)

# means we are ready to show the next character
func _on_next_char_timer_timeout() -> void:
	if(!textToShow.is_empty() and dialogueTextNode.text != textToShow and curTextIdx < textToShow.length()):
		dialogueTextNode.text += textToShow[curTextIdx]
		curTextIdx += 1
	if(curTextIdx < textToShow.length()):
		nextCharTimer.start()

class QuestionBox extends DialogueBox:
	pass
