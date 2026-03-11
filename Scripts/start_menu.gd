extends Node2D
const GAME = preload("res://scene/level.tscn")

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var menuContainer: BoxContainer = $Control/MenuContainer
@onready var optionsContainer: VBoxContainer = $Control/OptionsContainer
@onready var backgorund_music_slider: HSlider = $Control/OptionsContainer/BackgorundMusicSlider

var totalSong = 0
var musicDirectory : DirAccess = DirAccess.open("res://Ressources/Music")

func _ready() -> void:
	fillPlaylist()
	var rondomNumber :int = randi() % totalSong
	backgorund_music_slider.value = background_music.volume_linear
	background_music.play() #TO DO add randomiser
	
func fillPlaylist() -> void:
	if musicDirectory:
		print(totalSong)
		var songFilePath : PackedStringArray = musicDirectory.get_files()
		totalSong = songFilePath.size()
		print(totalSong)
	pass


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


func _on_back_pressed() -> void:
	menuContainer.show()
	optionsContainer.hide()
