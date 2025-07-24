extends Node2D

var listOfPower := []
var enemies_scene: PackedScene = load("res://scene/enemies.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, 5001, 50):
		listOfPower.append(i)

func getPowerLevel(roundNumber) -> int:
	return listOfPower[roundNumber]


func start(roundNumber) -> int:
	var powerLevel = getPowerLevel(roundNumber)
	var timerDelay = randf_range(0.0, 1.0)
	$Timer.wait_time = timerDelay
	return powerLevel * (4 * timerDelay) # c'est pour changer la difficulté selon la vitesse de spawn



#func _on_timer_timeout() -> void:
	#var enemies = enemies_scene.instantiate()
	#enemies.name = "enemies"
	#$Enemies.add_child(enemies)
	#enemies.position = enemy_tiles.map_to_local(Vector2(windowXAxis/(amountOfPixelInATile * 2),0))
	#enemies.target = $TrucADefendre
