extends "res://Scripts/placable.gd"

@export var item_scene: PackedScene = load("res://scene/item.tscn")
@export var spawn_interval = 1  # Temps entre chaque ressource
@export var spawn_direction = Vector2.DOWN  # Direction de départ de l'item

func _init():
	cost = 5

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

func _on_timer_timeout():
	var overlapping = $Area2D.get_overlapping_bodies()
		
	for body in overlapping:
		if body.is_in_group("items"):
			return
			
	var item = item_scene.instantiate()
	item.position = $Marker2D.global_position
	if item.has_method("set_direction"):
		item.set_direction(spawn_direction)
	get_tree().current_scene.add_child(item)

func startProduction() -> void:
	$Timer.start()

func stopProduction() -> void:
	$Timer.stop()
