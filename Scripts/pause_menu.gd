extends Node
@onready var pause_menu: Control = $PauseMenu
@onready var timer: Timer = $PauseMenu/Timer

var isHidden :bool = true

func _input(event: InputEvent) -> void:
	if !isHidden:
		if event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_ESCAPE: quitMenu()

func showMenu() -> void:
	get_tree().paused = true
	pause_menu.show()
	isHidden = false

func quitMenu() -> void:
	pause_menu.hide()
	isHidden = true
	get_tree().paused = false
	timer.start()

func _on_resume_pressed() -> void:
	quitMenu()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
