extends Button

# the name of the action that will be set
@export var actionName : String
var gettingInput = false

func _ready() -> void:
	setText()

func _pressed() -> void:
	gettingInput = true
	text = "Waiting..."

func _input(event: InputEvent) -> void:
	if(gettingInput && not(event is InputEventMouseMotion)):
		InputMap.action_erase_events(actionName)
		InputMap.action_add_event(actionName, event)
		gettingInput = false
		setText()

func setText() -> void:
	# set the text to the name of the first event for the action
	# will only support one event per action
	text = InputMap.action_get_events(actionName)[0].as_text()
