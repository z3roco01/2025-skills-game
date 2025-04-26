extends Node

const _VOLUME_CONFIG_SECT = "volume"
const _VOLUME_MASTER_KEY = "master"
const _VOLUME_MUSIC_KEY = "music"
const _VOLUME_SFX_KEY = "sfx"

const _GAMEPLAY_CONFIG_SECT = "gameplay"
const _TEXT_SPEED_KEY = "text_speed"

# holds callables to set the vars, so we can do things easy
var busVolDict = {
	"Master": setMasterVol,
	"music": setMusicVol,
	"sfx": setSfxVol
}

var masterVolume = 0.0
var musicVolume = 0.0
var sfxVolume = 0.0
var textSpeed = 1.0

func loadFromConfig(config: ConfigFile) -> void:
	masterVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_MASTER_KEY, "Master")
	musicVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_MUSIC_KEY, "music")
	sfxVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_SFX_KEY, "sfx")
	textSpeed = config.get_value(_GAMEPLAY_CONFIG_SECT, _TEXT_SPEED_KEY)

func saveToConfig(config: ConfigFile, path: String) -> void:
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_MASTER_KEY, masterVolume)
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_MUSIC_KEY, musicVolume)
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_SFX_KEY, sfxVolume)
	config.set_value(_GAMEPLAY_CONFIG_SECT, _TEXT_SPEED_KEY, textSpeed)
	
	config.save(path)

func setMasterVol(value: float) -> void:
	masterVolume = value

func setMusicVol(value: float) -> void:
	musicVolume = value

func setSfxVol(value: float) -> void:
	sfxVolume = value

func loadVolume(config: ConfigFile, section: String, key: String, bus: String) -> float:
	var value = config.get_value(section, key)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(value))
	return value
