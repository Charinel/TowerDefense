extends "res://Scripts/placable.gd"
class_name Usine

@export var item_scene: PackedScene = load("res://scene/item.tscn")
@export var spawn_interval = 3  # Temps pour effectuer le craft
@export var spawn_direction = Vector2.DOWN  # Direction de départ de l'item

var typeOfFactory : factoryType
var capacity = 10

func _init():
	cost = 20

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

func _on_timer_timeout():
	var overlapping = $Area2D.get_overlapping_bodies()
		
	for body in overlapping: #Vérification si des items sont présent dans le output
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

func processItem() -> void :
	pass
