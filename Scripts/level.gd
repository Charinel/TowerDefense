extends Node2D

var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
@onready var tileMapNormalTiles: TileMapLayer = $Map/NormalTiles
@onready var enemy_tiles: TileMapLayer = $Map/EnemyTiles
@onready var core: TileMapLayer = $TrucADefendre/Core

var windowXAxis
var windowYAxis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windowXAxis = get_viewport().get_visible_rect().size[0]
	windowYAxis = get_viewport().get_visible_rect().size[1]

	$SpawnDelay.start()
	for x in range(0,windowXAxis/16,1):
		for y in range(0,windowYAxis/16,1):
			tileMapNormalTiles.set_cell(Vector2(x,y),0,Vector2(0,0))

	core.set_cell(Vector2(windowXAxis/32,windowYAxis/16),0,Vector2(2,18))
	$TrucADefendre.position = Vector2(windowXAxis/2 + 8,windowYAxis)
	
	for y in range(0,windowYAxis/16,1):		
		enemy_tiles.set_cell(Vector2(windowXAxis/32,y),0,Vector2(4,2))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_delay_timeout() -> void:
	var enemies = enemies_scene.instantiate()
	enemies.name = "enemies"
	$Enemies.add_child(enemies)
	enemies.position = enemy_tiles.map_to_local(Vector2(windowXAxis/32,0))
	enemies.target = $TrucADefendre
	
