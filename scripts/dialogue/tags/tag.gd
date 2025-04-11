extends Node

class_name Tag

# run to check if this tag matches the current tag
# will be passed the tag without the square brackets
func doesMatch(tag: String) -> bool:
	return false

# called when we make a match ( a perfect match, you could say )
# and will do any logic on the box's data that is required
# is passed the tag with the tag still remaining
# returns what it will be replaced with
# you do have access to all of the boxes properties, methods and signals
func matched(tag: String, box: DialogueBox) -> String:
	return ""
