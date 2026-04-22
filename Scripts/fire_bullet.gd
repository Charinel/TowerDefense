extends "res://Scripts/bullet.gd"

func _ready() -> void:
	speed = 200
	pierce = 2
	damage = 10
	appliedEffect = effect.BURN

func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if body.is_in_group("enemies"):
		body.setOnFire()
