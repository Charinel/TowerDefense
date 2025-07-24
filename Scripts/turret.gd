extends "res://Scripts/placable.gd"

var bullet: PackedScene = load("res://scene/bullet.tscn")

var target: Node2D = null
@onready var reload_time: Timer = $RayCast2D/reloadTime
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var sprite_2d: Sprite2D = $Sprite2D
var newTarget = null
var counter = 0
var itemType = ""

const maxBullet = 20
var remaningBullet = 10 #on start avec un certain nombre pour pas être bs vu que sa coute dequoi la build

func _init():
	cost = 10
	
func _ready() -> void:
	target = call_deferred("findTarget")
	
func _physics_process(delta: float) -> void:
	if target != null:
		var angleToTarget = global_position.direction_to(target.global_position).angle() - (PI/2)
		ray_cast_2d.global_rotation = angleToTarget
		if ray_cast_2d.get_collider() != null :
			if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().get_class().contains("CharacterBody2D"):
				#sprite_2d.rotaion = angleToTarget
				if reload_time.is_stopped() and remaningBullet > 0:
					fire()
		target = null
	else :
		target = findTarget()
	

func fire():
	var createdBullet = bullet.instantiate()
	self.add_child(createdBullet)
	createdBullet.global_position = global_position
	createdBullet.rotation = ray_cast_2d.global_rotation + PI/2
	
	remaningBullet -= 1
	reload_time.start()

func findTarget() -> Node2D:
	var maxEnemies = get_tree().get_nodes_in_group("enemies").size()
	counter = 0
	
	if target == null:
		if get_tree().has_group("enemies") :
				while not ray_cast_2d.is_colliding() and counter < maxEnemies:
					newTarget = get_tree().get_nodes_in_group("enemies")[counter]
					var angleToTarget = global_position.direction_to(newTarget.global_position).angle() - (PI/2)
					ray_cast_2d.global_rotation = angleToTarget
					ray_cast_2d.force_raycast_update()
					counter += 1
					
	if is_instance_valid(newTarget):
		return newTarget
	return null


func _on_area_entered(area: Area2D) -> void:
	var temp = area.get_parent()
	if temp.type != itemType:
		remaningBullet = temp.bullet
		itemType = temp.type
	else :
		var tempBullet = remaningBullet + temp.bullet
		while tempBullet > maxBullet:
			await get_tree().process_frame
			tempBullet = remaningBullet
			tempBullet += temp.bullet
			if tempBullet == maxBullet:
				tempBullet = remaningBullet
		remaningBullet = maxBullet
	temp.free()
