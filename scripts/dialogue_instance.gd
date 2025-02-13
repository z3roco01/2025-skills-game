extends Control

# dictionary of expressions for this character
# you cant type hint on export, but this will have string keys and CompressedTexture2D values
@export var expressions = {}
# the expression that the character will start on 
@export var defaultExpression: String

# the node that holds the dialogue text 
@onready var dialogueTextNode = $dialoguePanel/text
# gets the node that holds the characters image
@onready var characterTexture = $characterTexture

# the script containing the script with the markup
var dialogueScript = "i like [$name], [$subject] [$is] very [dec pretty|handsome|beautiful] [expr content]! [nb] but i hate [$object] [expr anger]"
# the script after all the formatting has been applied
var formattedScript = ""
# a dictionary that holds all the variables used in dialogue
var dialogueVariables = {}
# this is the regex that will match to all tags
var tagRegex = RegEx.new()
# an array which holds all the dialogue boxes, in the order they play in
var dialogueBoxes: Array[DialogueBox]

func _ready() -> void:
	# set the characters expression to the default
	characterTexture.texture = expressions[defaultExpression]
	
	# set the formatted script to the dialogue script at the start, things will be subsituted later
	formattedScript = dialogueScript
	
	# compile the regex for matching tags
	# need to match everything but right bracket since godot implementation is broken
	tagRegex.compile("\\[[^\\]]+\\]")
	
	# populate the dialogue variables with things such as pronouns and name
	dialogueVariables["name"] = Identity.playerName
	dialogueVariables["subject"] = Identity.pronounSubjective
	dialogueVariables["object"] = Identity.pronounObjective
	dialogueVariables["determ"] = Identity.pronounDeterminer
	dialogueVariables["posses"] = Identity.pronounPossessive
	dialogueVariables["reflex"] = Identity.pronounReflexive
	if(Identity.usesIs()):
		dialogueVariables["is"] = "is"
	else:
		dialogueVariables["is"] = "are"

# replaces the passed variable with the value from the dictionary, replaces in the formatted dialogue variable
func varReplace(varName: String) -> void:
	# replaces the first instance of the variable with its value in the dictionary
	# strips the $ before lookup since its not in the dictionary
	formattedScript = formattedScript.replace("[" + varName + "]", dialogueVariables[varName.lstrip("$")])

func changeExpression(expressionId: String) -> void:
	# first strip the "expr " off of the passed string to get the raw expression id
	# then pass that into the expression bank to get the expression texture then set the shown texture to it
	characterTexture.texture = expressions[expressionId]

func showDialogue() -> void:
	dialogueTextNode.text = formattedScript

func _on_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		showDialogue()

# this class holds all the information about a dialogue box
# such as the text to display and the expression to set
class DialogueBox:
	# singal that will be connected in the main dialogue instance, will show our text
	signal showBox(text: String, expressionId: String)
	# signal that will lookup a variable then put its value in the first element of the passed array
	signal lookupVar(varName: String, returnArray: Array[String])
	
	# the text that well be shown in the text box
	var dialogueText: String
	# the expression that will be set at the start of the box
	var expressionId: String
	# regex that matched to each tag
	var tagRegex = RegEx.new()
	# the default expression that it will default to
	var defaultExpression: String
	
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
			var matched = result.strings[0]
			print(matched)
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
			elif(matched.begins_with("nb")): # if the tag beings with "nb" then it is a defines the start of a new dialogue box
				pass
				# dont reset current expression at the end since we want the character to keep their epxression
	
	# replaces the passed variable with the value from the dictionary, replaces in the dialogue texture
	func varReplace(varName: String) -> void:
		var returnedVal = []
		# emit a signal to the dialogue instance that looks up the variable and puts it in the passed array
		# need to remove the $ first
		emit_signal("lookupVar", varName.lstrip("$"), returnedVal)
		
		dialogueText = dialogueText.replace("[" + varName + "]", returnedVal[0])
	
	# shows this dialogue box by setting the shown text to its text and setting the expression
	func show() -> void:
		emit_signal("showBox", dialogueText, expressionId)
