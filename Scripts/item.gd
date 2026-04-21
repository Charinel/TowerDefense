extends "res://Scripts/enums.gd"
class_name Item

var direction: Vector2 = Vector2.ZERO
var velocity := Vector2.ZERO
var current_conveyor: Node = null
var blocked
@export var bullet = 5
@export var type : stateOfItem = stateOfItem.NORMAL
@export var speed: float = 16.0      

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("items")
	$FrontSensor.body_entered.connect(_on_front_detected)
	$FrontSensor.body_exited.connect(_on_front_cleared)
	
func _on_front_detected(body):
	if body.is_in_group("items"):
		blocked = true

func _on_front_cleared(body):
	if body.is_in_group("items"):
		blocked = false

func set_direction(dir: Vector2):
	direction = dir.normalized()
	
func set_movement_from_conveyor(dir: Vector2, conveyor: Node):
	if current_conveyor == conveyor:
		return
	current_conveyor = conveyor
	var sensor_offset = dir.normalized() * 10
	$FrontSensor.position = sensor_offset
	velocity = dir.normalized() * speed

func stop_movement_from_conveyor(conveyor: Node):
	if current_conveyor == conveyor:
		velocity = Vector2.ZERO
		current_conveyor = null

func _physics_process(delta):
	if current_conveyor:
		var axis = current_conveyor.direction
		var perp_axis = Vector2(-axis.y, axis.x)
		
		var target_pos = current_conveyor.global_position
		var offset = (global_position - target_pos).dot(perp_axis)
		global_position -= perp_axis * offset
	
	if not blocked:
		global_position += velocity * delta
