extends Node2D

const FRAME_SIZE = Vector2(16, 16)
var region_pos = Vector2(2,1)
@export var direction: Vector2 = Vector2.DOWN      
var lastConveyor: River

func _ready():
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(region_pos * FRAME_SIZE, FRAME_SIZE)
	
func setDefaultSprite() -> void :
	region_pos = Vector2(2,1)
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(region_pos * FRAME_SIZE, FRAME_SIZE)
	
func changeOrientation() -> void :
	var ghostDirection = Vector2.DOWN.rotated(rotation).round()
	var directionOfPlaced = lastConveyor.direction
	
	match ghostDirection:
		Vector2(1, 0):   # Ghost droite
			match directionOfPlaced:
				Vector2(0, 1):   # bas vers la droite
					region_pos = Vector2(3, 0)
				Vector2(0, -1):  # haut vers la droite
					region_pos = Vector2(2, 0)
		Vector2(0, 1):   # Ghost bas
			match directionOfPlaced:
				Vector2(-1, 0):   # gauche vers le bas
					region_pos = Vector2(3, 0)
				Vector2(1, 0):  # droite vers le bas
					region_pos = Vector2(2, 0)
		Vector2(-1, 0):  # Ghost gauche
			match directionOfPlaced:
				Vector2(0, 1):   # bas vers la gauche
					region_pos = Vector2(2, 0)
				Vector2(0, -1):  # haut vers la gauche
					region_pos = Vector2(3, 0)
		Vector2(0, -1):  # Ghost haut
			match directionOfPlaced:
				Vector2(-1, 0):   # gauche vers le haut
					region_pos = Vector2(2, 0)
				Vector2(1, 0):  # droite vers le haut
					region_pos = Vector2(3, 0)
		_:
			print("Direction inconnue :", directionOfPlaced)
			
	$Sprite2D.region_enabled = true
	$Sprite2D.region_rect = Rect2(region_pos * FRAME_SIZE, FRAME_SIZE)
