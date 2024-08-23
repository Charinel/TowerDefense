extends Node2D

var normalTiles_scene: PackedScene = load("res://scene/normal_tiles.tscn")
var ironTiles_scene: PackedScene = load("res://scene/iron_tiles.tscn")
var enemyTiles_scene: PackedScene = load("res://scene/EnemyPath.tscn")
var trucADefendre_scene: PackedScene = load("res://scene/truc_a_defendre.tscn")
var enemies_scene: PackedScene = load("res://scene/enemies.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpawnDelay.start()
	for x in range(8,get_viewport().get_visible_rect().size[0],16):
		for y in range(8,get_viewport().get_visible_rect().size[1],16):
			#remplis la grid de tile ordinaire avec le noise on va add les autres tiles
			var normalTiles = normalTiles_scene.instantiate()
			$NormalTiles.add_child(normalTiles)
			#on fait +8 en xy pour avoir le centre
			normalTiles.position = Vector2(x,y)
			
	var trucADefendre = trucADefendre_scene.instantiate()
	$TrucADefendre.add_child(trucADefendre)
	trucADefendre.position = Vector2(536,920)
	
	for y in range(8,get_viewport().get_visible_rect().size[1],16):
		var enemyTiles = enemyTiles_scene.instantiate()
		$EnemyTiles.add_child(enemyTiles)
		enemyTiles.position = Vector2(536,y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_spawn_delay_timeout() -> void:
	var enemies = enemies_scene.instantiate()
	$Enemies.add_child(enemies)
	print("spawned at:")
	enemies.position = Vector2($EnemyTiles.get_child(0).position)
