extends Node

const _VOLUME_CONFIG_SECT = "volume"
const _VOLUME_MASTER_KEY = "master"
const _VOLUME_MUSIC_KEY = "music"
const _VOLUME_SFX_KEY = "sfx"
var scrollSpeedMul = 1

# holds callables to set the vars, so we can do things easy
var busVolDict = {
	"Master": setMasterVol,
	"music": setMusicVol,
	"sfx": setSfxVol
}

var masterVolume = 0.0
var musicVolume = 0.0
var sfxVolume = 0.0

func loadFromConfig(config: ConfigFile) -> void:
	masterVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_MASTER_KEY, "Master")
	musicVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_MUSIC_KEY, "music")
	sfxVolume = loadVolume(config, _VOLUME_CONFIG_SECT, _VOLUME_SFX_KEY, "sfx")

func saveToConfig(config: ConfigFile, path: String) -> void:
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_MASTER_KEY, masterVolume)
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_MUSIC_KEY, musicVolume)
	config.set_value(_VOLUME_CONFIG_SECT, _VOLUME_SFX_KEY, sfxVolume)
	
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
