extends Control

@onready var nameInput = $VBoxContainer/nameInput
@onready var descriptorsSelect = $VBoxContainer/descriptersSelect
@onready var subjectiveInput = $VBoxContainer/subjectiveInput
@onready var objectiveInput = $VBoxContainer/objectiveInput
@onready var determinerInput = $VBoxContainer/determinerInput
@onready var possessiveInput = $VBoxContainer/possessiveInput
@onready var reflexiveInput = $VBoxContainer/reflexiveInput

func _on_save_button_pressed() -> void:
	# TODO: add proper whitespace detection for every string
	# DOUBLE TODO: MAKE UN GARBAGE
	# TODO: DONT REASSIGN WHEN EMPTY
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
	queue_free()
