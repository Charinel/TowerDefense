extends Node2D
const GAME = preload("res://scene/level.tscn")

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var menuContainer: BoxContainer = $Control/MenuContainer
@onready var optionsContainer: VBoxContainer = $Control/OptionsContainer
@onready var backgorund_music_slider: HSlider = $Control/OptionsContainer/BackgorundMusicSlider

var totalSong = 0
var musicDirectory : DirAccess = DirAccess.open("res://Ressources/Music")
var settingsFile = "res://Settings.txt" 
var settingsContent :String

var settingArray : PackedStringArray = []
const BACKGROUNDMUSIC = 0

func _ready() -> void:
	fillPlaylist()
	loadSettings()
	var rondomNumber :int = randi() % totalSong
	backgorund_music_slider.value = background_music.volume_linear
	background_music.play() #TO DO add randomiser
	
func fillPlaylist() -> void:
	if musicDirectory:
		var songFilePath : PackedStringArray = musicDirectory.get_files()
		totalSong = songFilePath.size()

func loadSettings() -> void:
	if FileAccess.file_exists(settingsFile):
		var file = FileAccess.open(settingsFile, FileAccess.READ)
		settingsContent = file.get_as_text()
		settingArray = settingsContent.split(";",true,0)
		background_music.volume_linear = settingArray[BACKGROUNDMUSIC].to_float()
		file.close()
	else:
		print("Error: File not found")
		
func saveSettings() -> void:
	if FileAccess.file_exists(settingsFile):
		settingsContent = ""
		var file = FileAccess.open(settingsFile, FileAccess.WRITE)
		print(settingArray.size())
		for x in settingArray.size() - 1:
			var temp = str(settingArray[x]) + ";"
			print(settingArray[x])
			print(temp)
			settingsContent += temp
		file.store_string(settingsContent)
		file.close()
	else:
		print("Error: File not found")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(GAME)


func _on_options_pressed() -> void:
	menuContainer.hide()
	optionsContainer.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_backgorund_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed :
		background_music.volume_linear = backgorund_music_slider.value
		print("Slider update")
		print(str(background_music.volume_linear))
		settingArray[BACKGROUNDMUSIC] = str(background_music.volume_linear)
		saveSettings()

func _on_back_pressed() -> void:
	menuContainer.show()
	optionsContainer.hide()
