extends Node

class_name Tag

# run to check if this tag matches the current tag
# will be passed the tag without the square brackets
func doesMatch(tag: String) -> bool:
	return tag.begins_with(getPrefix())

# called when we make a match ( a perfect match, you could say )
# and will do any logic on the box's data that is required
# is passed the tag with the tag prefix removed
# returns what it will be replaced with
# this does have access to all of the boxes properties, methods and signals
func matched(_tagArgs: String, _box: DialogueBox) -> String:
	return ""

# used to match the tag and to remove it automatically
func getPrefix() -> String:
	return ""


# takes the whole tag ( minus [] ) and removes the prefix from it
# then passed to matched
func stripPrefix(tag: String) -> String:
	return tag.trim_prefix(getPrefix())
