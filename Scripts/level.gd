extends Node2D

var normalTiles_scene: PackedScene = load("res://scene/normal_tiles.tscn")
var ironTiles_scene: PackedScene = load("res://scene/iron_tiles.tscn")
var enemyTiles_scene: PackedScene = load("res://scene/EnemyPath.tscn")
var trucADefendre_scene: PackedScene = load("res://scene/truc_a_defendre.tscn")
var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
var pathToFollow: PackedScene = load("res://scene/path_to_follow.tscn")
var curve = Curve2D.new()
var enemyId = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var windowXAxis = get_viewport().get_visible_rect().size[0]
	var windowYAxis = get_viewport().get_visible_rect().size[1]

	$SpawnDelay.start()
	for x in range(8,windowXAxis,16):
		for y in range(8,windowYAxis,16):
			#remplis la grid de tile ordinaire avec le noise on va add les autres tiles
			var normalTiles = normalTiles_scene.instantiate()
			$NormalTiles.add_child(normalTiles)
			#on fait +8 en xy pour avoir le centre
			normalTiles.position = Vector2(x,y)
			
	var trucADefendre = trucADefendre_scene.instantiate()
	$TrucADefendre.add_child(trucADefendre)
	trucADefendre.position = Vector2(windowXAxis/2 + 8,windowYAxis - 8)
	
	
	var enemyTiles
	var indexForPath = 0
	
	print(windowYAxis)
	for y in range(8,windowYAxis,16):
		
		enemyTiles = enemyTiles_scene.instantiate()
			
		curve.add_point(Vector2(windowXAxis/2,y),Vector2(0,0),Vector2(0,0),indexForPath)
		$EnemyTiles.add_child(enemyTiles)
		enemyTiles.position = Vector2(windowXAxis/2 + 8,y)
		indexForPath += 1
	$Path2D.curve = curve


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_delay_timeout() -> void:
	var enemies = enemies_scene.instantiate()
	var pathToFollow = pathToFollow.instantiate()
	$Path2D.add_child(pathToFollow)
	enemies.id = enemyId
	enemies.path2d = $Path2D
	$Enemies.add_child(enemies)
	enemies.position = $EnemyTiles.get_child(0).position
	enemyId += 1
