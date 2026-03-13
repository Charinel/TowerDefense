extends Node2D
const GAME = preload("res://scene/level.tscn")

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var menuContainer: BoxContainer = $Control/MenuContainer
@onready var settings: Control = $Control/Settings
@onready var backgorund_music_slider: HSlider = settings.get_child(0).get_child(1)
@onready var optionsContainer: VBoxContainer = settings.get_child(0)


var totalSong = 0
var musicDirectory : DirAccess = DirAccess.open("res://Ressources/Music/Menu")
var settingArray : Array = []
var playlist : Array = []
const BACKGROUNDVOLUME = 0

func _ready() -> void:
	background_music.stream = fillPlaylist()
	settings.parent = self
	settingArray = settings.loadSettings()
	background_music.volume_linear = settingArray[BACKGROUNDVOLUME]
	background_music.play()
	
func fillPlaylist():
	if musicDirectory:
		var songFilePath : PackedStringArray = musicDirectory.get_files()
		totalSong = songFilePath.size()
		var randomNumber :int = randi() % totalSong/2#divise par 2 parceque godot ajoute un importe a chaque tune
		for x in range (0,totalSong,2) :
			print(songFilePath[x])
			playlist.append(songFilePath[x])
		return load_mp3(musicDirectory.get_current_dir() + '/' + playlist[randomNumber])

func load_mp3(path):
	var sound
	print(path)
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		sound = AudioStreamMP3.new()
		sound.data = file.get_buffer(file.get_length())
	else:
		print("Error: File not found")
	return sound

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(GAME)

func _on_options_pressed() -> void:
	menuContainer.hide()
	settings.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
