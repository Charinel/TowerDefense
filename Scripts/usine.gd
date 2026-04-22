extends "res://Scripts/placable.gd"
class_name Usine

@export var item_scene: PackedScene = load("res://scene/item.tscn")
@export var spawn_interval = 2  # Temps pour effectuer le craft
@export var spawn_direction = Vector2.DOWN  # Direction de départ de l'item

var typeOfFactory : factoryType
var capacity = 10
var item : Item
var holdItem : Item
var canAcceptItem : bool = true

func _init():
	cost = 20
	
func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(_on_timer_timeout)

func setTypeOfItem(item)-> void:
	pass
	
func _on_timer_timeout():
	var overlapping = $Area2D.get_overlapping_bodies()
	
	for body in overlapping: #Vérification si des items sont présent dans le output
		if body.is_in_group("items"):
			holdItem = item
			return
			
	canAcceptItem = true
	
	item = item_scene.instantiate()
	item.position = $Marker2D.global_position
	if item.has_method("set_direction"):
		item.set_direction(spawn_direction)
	get_tree().current_scene.add_child(item)
	if holdItem != null :
		setTypeOfItem(holdItem)
		holdItem.queue_free()

func startProduction() -> void:
	canAcceptItem = false
	$Timer.start()

func stopProduction() -> void:
	$Timer.stop()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if $Timer.is_stopped() and holdItem != null:
		canAcceptItem = true

		var tempItem = item_scene.instantiate()
		tempItem.position = $Marker2D.global_position
		if tempItem.has_method("set_direction"):
			tempItem.set_direction(spawn_direction)
		get_tree().current_scene.add_child(tempItem)
		if holdItem != null :
			setTypeOfItem(holdItem)
			holdItem.queue_free()
