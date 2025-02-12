extends Control

@onready var dialogueTextNode = $dialoguePanel/text
# the script containing the script with the markup
var dialogueScript = "i like [$name], [$subject] is very [pretty|handsome|beautiful] [expr content]! [nb] but i hate [$object] [expr anger]"
# the script after all the formatting has been applied
var formattedScript = ""

# a dictionary that holds all the variables used in dialogue
var dialogueVariables = {}
# this regex holds the regex to match to any dialogue variable
var varRegex = RegEx.new()

func _ready() -> void:
	# set the formatted script to the dialogue script at the start, things will be subsituted later
	formattedScript = dialogueScript
	
	# compile all the regex expressions
	varRegex.compile("\\[\\$\\w+\\]")
	
	# populate the dialogue variables with things such as pronouns and name
	dialogueVariables["name"] = Identity.playerName
	dialogueVariables["subject"] = Identity.pronounSubjective
	dialogueVariables["object"] = Identity.pronounObjective
	dialogueVariables["determ"] = Identity.pronounDeterminer
	dialogueVariables["posses"] = Identity.pronounPossessive
	dialogueVariables["reflex"] = Identity.pronounReflexive
	
	# match to every variable definition ( [$var] ) in the dialogue 
	for results in varRegex.search_all(dialogueScript):
		# matched is the variable that we have matched with in the dialogue
		# will always contain one string so we can safely get the first string and only use it
		var matched = results.strings[0]
		print(matched)
		print(lookup(matched) + "\n")
		# replace the first occurance of the matched string ( the variable we are subsituting )
		# with the variables value from the dictionary
		formattedScript = formattedScript.replace(matched, lookup(matched))
		

# looks up a variable from the dictionary
# takes in a formated variable ( ex. [$name] ) or unformated variable ( ex. name )
func lookup(variable: String) -> String:
	# removes first two characters ( [$ ) and the last one ( ] ) if they exist
	var strippedVariable = variable.lstrip("[$").rstrip("]")
	# then get the corresponding value from the variables dictionary
	return dialogueVariables[strippedVariable]

func showDialogue() -> void:
	dialogueTextNode.text = formattedScript

func _on_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		showDialogue()
