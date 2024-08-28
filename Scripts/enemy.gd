extends CharacterBody2D

var movementSpeed = 100
@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var collision
@onready var hp = $HealthBar.max_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("setSeek")
	$HealthBar.value = hp
	
func setSeek() -> void:
	await get_tree().physics_frame
	if target:
		navigation_agent_2d.target_position = target.global_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		var event = InputEventAction.new()
		event.action = "removeHealth"
		event.pressed = true
		Input.parse_input_event(event)
		
		self.queue_free()
		
	var currentPosition = global_position
	var nextPosition = navigation_agent_2d.get_next_path_position()
	velocity = currentPosition.direction_to(nextPosition) * movementSpeed
	collision = move_and_collide(velocity * delta)
