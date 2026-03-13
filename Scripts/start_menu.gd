extends Node2D
const GAME = preload("res://scene/level.tscn")

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var menuContainer: BoxContainer = $Control/MenuContainer
@onready var settings: Control = $Control/Settings
@onready var backgorund_music_slider: HSlider = settings.get_child(0).get_child(1)
@onready var optionsContainer: VBoxContainer = settings.get_child(0)


var totalSong = 0
var musicDirectory : DirAccess = DirAccess.open("res://Ressources/Music")
var settingArray : Array = []
const BACKGROUNDVOLUME = 0

func _ready() -> void:
	fillPlaylist()
	settings.parent = self
	settingArray = settings.loadSettings()
	background_music.volume_linear = settingArray[BACKGROUNDVOLUME]
	var rondomNumber :int = randi() % totalSong
	background_music.play() #TO DO add randomiser
	
func fillPlaylist() -> void:
	if musicDirectory:
		var songFilePath : PackedStringArray = musicDirectory.get_files()
		totalSong = songFilePath.size()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(GAME)

func _on_options_pressed() -> void:
	menuContainer.hide()
	settings.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
