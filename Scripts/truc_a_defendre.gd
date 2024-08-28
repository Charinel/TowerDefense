extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hp.value = $Hp.max_value
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("removeHealth"):
		$Hp.value -= 1
		print($Hp.value)
		var event = InputEventAction.new()
		event.action = "removeHealth"
		event.pressed = false
		Input.parse_input_event(event)
