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
const NAME_KEY = "name"
const DESCRIPTORS_KEY = "descriptors"
const PRONOUN_SUBJ_KEY = "pronounSubjective"
const PRONOUN_OBJ_KEY  = "pronounObjective"
const PRONOUN_DETRM_KEY = "pronounDeterminer"
const PRONOUN_POSS_KEY = "pronounPossessive"
const PRONOUN_REFL_KEY  = "pronounReflexive"

# saves this identity object to a passed ConfigFile
func saveToConfig(config: ConfigFile, path: String) -> void:
	config.set_value(_CONFIG_SECTION, NAME_KEY, playerName)
	config.set_value(_CONFIG_SECTION, DESCRIPTORS_KEY, descriptors)
	config.set_value(_CONFIG_SECTION, PRONOUN_SUBJ_KEY, pronounSubjective)
	config.set_value(_CONFIG_SECTION, PRONOUN_OBJ_KEY,  pronounObjective)
	config.set_value(_CONFIG_SECTION, PRONOUN_DETRM_KEY, pronounDeterminer)
	config.set_value(_CONFIG_SECTION, PRONOUN_POSS_KEY, pronounPossessive)
	config.set_value(_CONFIG_SECTION, PRONOUN_REFL_KEY, pronounReflexive)
	
	config.save(path)

# loads the values from a ConfigFile
func loadFromConfig(config: ConfigFile) -> void:
	playerName = config.get_value(_CONFIG_SECTION, NAME_KEY)
	descriptors = config.get_value(_CONFIG_SECTION, DESCRIPTORS_KEY)
	pronounSubjective = config.get_value(_CONFIG_SECTION, PRONOUN_SUBJ_KEY)
	pronounObjective  = config.get_value(_CONFIG_SECTION, PRONOUN_OBJ_KEY)
	pronounDeterminer = config.get_value(_CONFIG_SECTION, PRONOUN_DETRM_KEY)
	pronounPossessive = config.get_value(_CONFIG_SECTION, PRONOUN_POSS_KEY)
	pronounReflexive = config.get_value(_CONFIG_SECTION, PRONOUN_REFL_KEY)

# used to check if "is" or "are" will be used for the player, returns true if "is" will be used, false otherwise
func usesIs() -> bool:
	if(pronounSubjective == "they"): return false
	return true

# override the to string function, used mostley for testing
func _to_string() -> String:
	return playerName + " " + str(descriptors) + " " + pronounSubjective + " " + pronounObjective + " " + pronounDeterminer + " " + pronounPossessive + " " + pronounReflexive
