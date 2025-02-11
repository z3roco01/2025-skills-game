extends Node
# an autoloaded script that handles saving and access of preferences

# the file which holds the preferences
var _prefs = ConfigFile.new()

# the path that the preferences will be saved at 
const _PREFS_PATH = "user://prefs.cfg"

func _init() -> void:
	var prefsErr = _prefs.load(_PREFS_PATH)
	
	if prefsErr == OK:
		# if the prefs file exists and is readable, load all preferences
		Identity.loadFromConfig(_prefs)
	else:
		# there is a problem with the config, most likely need to create the file
		# create a prefs file with the default values
		Identity.saveToConfig(_prefs, _PREFS_PATH)
	
	print(Identity)
