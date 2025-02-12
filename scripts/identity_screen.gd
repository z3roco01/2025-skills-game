extends Control

@onready var nameInput = $nameInput
@onready var descriptorsSelect = $descriptersSelect
@onready var subjectiveInput = $subjectiveInput
@onready var objectiveInput = $objectiveInput
@onready var determinerInput = $determinerInput
@onready var possessiveInput = $possessiveInput
@onready var reflexiveInput = $reflexiveInput

func _on_save_button_pressed() -> void:
	# TODO: add proper whitespace detection for every string
	# DOUBLE TODO: MAKE UN GARBAGE
	if(!(nameInput.text == "") and !(nameInput.text == " ")):
		Identity.playerName = nameInput.text
	Identity.descriptors = descriptorsSelect.selected
	Identity.pronounSubjective = subjectiveInput.text
	Identity.pronounObjective  = objectiveInput.text
	Identity.pronounDeterminer = determinerInput.text
	Identity.pronounPossessive = possessiveInput.text
	Identity.pronounReflexive = reflexiveInput.text
	Identity.saveToConfig(Prefs._prefs, Prefs._PREFS_PATH)
	print(Identity)
