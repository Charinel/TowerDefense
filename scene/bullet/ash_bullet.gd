extends "res://Scripts/bullet.gd"

func _ready() -> void:
	speed = 150
	pierce = 1
	damage = 4
	appliedEffect = effect.SLOW

func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if body.is_in_group("enemies"):
		body.ashSlow()
