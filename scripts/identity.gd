extends Node
# an autoloaded object which holds the players identity ( name, prns, etc )

# default values, will be used if the player does not customise it or the pref
# file gets corrupted or deleted
var playerName = "MC"
var descriptors = Descriptors.NEUTRAL
var pronounSubjective = "they"
var pronounObjective  = "them"
var pronounDeterminer = "their"
var pronounPossessive = "theirs"
var pronounReflexive  = "themself"

# an enum for the types of descriptors ( compliments, titles, etc ) 
enum Descriptors {FEMININE, MASCULINE, NEUTRAL}

const _CONFIG_SECTION = "identity"
const _NAME_KEY = "name"
const _DESCRIPTORS_KEY = "descriptors"
const _PRONOUN_SUBJECTIVE = "pronounSubjective"
const _PRONOUN_OBJECTIVE  = "pronounObjective"
const _PRONOUN_DETERMINER = "pronounDeterminer"
const _PRONOUN_POSSESSIVE = "pronounPossessive"
const _PRONOUN_REFLEXIVE  = "pronounReflexive"

# saves this identity object to a passed ConfigFile
func saveToConfig(config: ConfigFile, path: String) -> void:
	config.set_value(_CONFIG_SECTION, _NAME_KEY, playerName)
	config.set_value(_CONFIG_SECTION, _DESCRIPTORS_KEY, descriptors)
	config.set_value(_CONFIG_SECTION, _PRONOUN_SUBJECTIVE, pronounSubjective)
	config.set_value(_CONFIG_SECTION, _PRONOUN_OBJECTIVE,  pronounObjective)
	config.set_value(_CONFIG_SECTION, _PRONOUN_DETERMINER, pronounDeterminer)
	config.set_value(_CONFIG_SECTION, _PRONOUN_POSSESSIVE, pronounPossessive)
	config.set_value(_CONFIG_SECTION, _PRONOUN_REFLEXIVE, pronounReflexive)
	
	config.save(path)

# loads the values from a ConfigFile
func loadFromConfig(config: ConfigFile) -> void:
	playerName = config.get_value(_CONFIG_SECTION, _NAME_KEY)
	descriptors = config.get_value(_CONFIG_SECTION, _DESCRIPTORS_KEY)
	pronounSubjective = config.get_value(_CONFIG_SECTION, _PRONOUN_SUBJECTIVE)
	pronounObjective  = config.get_value(_CONFIG_SECTION, _PRONOUN_OBJECTIVE)
	pronounDeterminer = config.get_value(_CONFIG_SECTION, _PRONOUN_DETERMINER)
	pronounPossessive = config.get_value(_CONFIG_SECTION, _PRONOUN_POSSESSIVE)
	pronounReflexive = config.get_value(_CONFIG_SECTION, _PRONOUN_REFLEXIVE)

# used to check if "is" or "are" will be used for the player, returns true if "is" will be used, false otherwise
func usesIs() -> bool:
	if(pronounSubjective == "they"): return false
	return true

# override the to string function, used mostley for testing
func _to_string() -> String:
	return playerName + " " + str(descriptors) + " " + pronounSubjective + " " + pronounObjective + " " + pronounDeterminer + " " + pronounPossessive + " " + pronounReflexive
