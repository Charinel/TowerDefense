extends Node2D

var target: Node2D = null
@onready var reload_time: Timer = $RayCast2D/reloadTime
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	target = call_deferred("findTarget")
	
func _physics_process(delta: float) -> void:
	if target != null:
		var angleToTarget = global_position.direction_to(target.global_position).angle()
		ray_cast_2d.global_rotation = angleToTarget
		
		if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().is_in_group("enemies"):
			print("sa marche ?")
			sprite_2d.rotaion = angleToTarget
			if reload_time.is_stopped():
				fire()
	else :
		target = findTarget()

func fire():
	print("fired")
	ray_cast_2d.enabled = false
	
	reload_time.start()

func findTarget() -> Node2D:
	var newTarget = null
	
	if get_tree().has_group("enemies") :
		newTarget = get_tree().get_nodes_in_group("enemies")[0]
	
	return newTarget


func _on_reload_time_timeout() -> void:
	ray_cast_2d.enabled = true
