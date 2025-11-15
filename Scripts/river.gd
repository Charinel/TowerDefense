extends "res://Scripts/placable.gd"

class_name River

@export var direction: Vector2 = Vector2.DOWN

func _init():
	cost = 1
func _ready():
	set_deferred("monitoring", true)
	if $Area2D:
		$Area2D.body_entered.connect(_on_item_entered)
		$Area2D.body_exited.connect(_on_item_exited)
	else:
		print("Erreur : Area2D non trouvé dans " + str(self))
		

func _on_item_entered(body):
	if body.is_in_group("items") and body.has_method("set_movement_from_conveyor"):
		body.set_movement_from_conveyor(direction, self)

func _on_item_exited(body):
	if body.is_in_group("items") and body.has_method("stop_movement_from_conveyor"):
			body.stop_movement_from_conveyor(self)

func setConveyorDirection(ghost) -> void:
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = ghost.get_child(0).region_rect

func _on_belt_detected(area: Area2D) -> void:
	await get_tree().process_frame
	var ghost = area.get_parent()
	ghost.lastConveyor = self
	ghost.changeOrientation()

func _on_belt_detector_left(area: Area2D) -> void:
	var ghost = area.get_parent()
	ghost.setDefaultSprite()
	ghost.lastConveyor = null
