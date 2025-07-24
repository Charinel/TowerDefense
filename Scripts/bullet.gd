extends Area2D

const RIGHT = Vector2.RIGHT
@export var speed = 200
var pierce = 2
@export var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var movement = RIGHT.rotated(rotation) * speed * delta
	global_position += movement

func destroy():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		pierce -= 1
		if body.has_method("hit"):
			body.hit(damage)
		
		if pierce == 0:
			destroy()
