extends LineEdit

# what identity part will this change
@export var type: IDENTITY_TYPES

# used for the editor to make it better
enum IDENTITY_TYPES { NAME, PRN_SUBJ, PRN_OBJ, PRN_DETRM, PRN_POSS, PRN_REFL }
const TYPE_KEY_MAP = {
	IDENTITY_TYPES.NAME:      Identity.NAME_KEY,
	IDENTITY_TYPES.PRN_SUBJ:  Identity.PRONOUN_SUBJ_KEY,
	IDENTITY_TYPES.PRN_OBJ:   Identity.PRONOUN_OBJ_KEY,
	IDENTITY_TYPES.PRN_DETRM: Identity.PRONOUN_DETRM_KEY,
	IDENTITY_TYPES.PRN_POSS:  Identity.PRONOUN_POSS_KEY,
	IDENTITY_TYPES.PRN_REFL:  Identity.PRONOUN_REFL_KEY,
}

func _ready() -> void:
	text_changed.connect(textChanged)
	text = Identity.playerName

func textChanged(newText: String) -> void:
	pass

func _exit_tree() -> void:
	Identity.playerName = text
	Identity.saveToConfig(Prefs._prefs, Prefs._PREFS_PATH)
