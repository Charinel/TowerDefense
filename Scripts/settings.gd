extends Control
@onready var backgorund_music_slider: HSlider = $OptionsContainer/BackgorundMusicSlider
@onready var back: Button = $OptionsContainer/Back

var settingsFile = "res://Settings.txt" 
var settingsContent :String

var settingArray : PackedStringArray = [] # tableau qui contient la lecture du fichier
const BACKGROUNDMUSIC = 0
var parent

func saveSettings() -> void:
	if FileAccess.file_exists(settingsFile):
		settingsContent = ""
		var file = FileAccess.open(settingsFile, FileAccess.WRITE)
		print(settingArray.size())
		for x in settingArray.size() - 1:
			var temp = str(settingArray[x]) + ";"
			settingsContent += temp
		file.store_string(settingsContent)
		file.close()
	else:
		print("Error: File not found")
		
func loadSettings() -> Array:
	var arrayOfSettings : Array = [] # tableau que l'on rempli des datas que l'on retourne au caller
	if FileAccess.file_exists(settingsFile):
		var file = FileAccess.open(settingsFile, FileAccess.READ)
		settingsContent = file.get_as_text()
		settingArray = settingsContent.split(";",true,0) 
		arrayOfSettings.append(settingArray[BACKGROUNDMUSIC].to_float())
		backgorund_music_slider.value = settingArray[BACKGROUNDMUSIC].to_float()
		file.close()
	else:
		print("Error: File not found")
	
	return arrayOfSettings
		
func _on_backgorund_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed :
		parent.background_music.volume_linear = backgorund_music_slider.value
		settingArray[BACKGROUNDMUSIC] = str(backgorund_music_slider.value)
		saveSettings()

func _on_back_pressed() -> void:
	parent.menuContainer.show()
	self.hide()
