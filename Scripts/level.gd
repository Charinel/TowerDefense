extends Node2D

var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
@onready var tileMapNormalTiles: TileMapLayer = $Map/NormalTiles
@onready var enemy_tiles: TileMapLayer = $Map/EnemyTiles
@onready var core: TileMapLayer = $TrucADefendre/Core
@onready var build_mode: TileMapLayer = $Map/BuildMode

var amountOfPixelInATile = 16
var buildModeOn = false

var windowXAxis
var windowYAxis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windowXAxis = get_viewport().get_visible_rect().size[0]
	windowYAxis = get_viewport().get_visible_rect().size[1]

	$SpawnDelay.start()
	for x in range(0,windowXAxis/amountOfPixelInATile,1):
		for y in range(0,windowYAxis/amountOfPixelInATile,1):
			tileMapNormalTiles.set_cell(Vector2(x,y),0,Vector2(0,0))
			build_mode.set_cell(Vector2(x,y),0,Vector2(5,16))
	build_mode.visible = false

	core.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),windowYAxis/amountOfPixelInATile),0,Vector2(2,18))
	$TrucADefendre.position = Vector2(windowXAxis/2 + 8,windowYAxis)
	
	for y in range(0,windowYAxis/amountOfPixelInATile,1):		
		enemy_tiles.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),y),0,Vector2(4,2))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.as_text_keycode() == "B":
			if event.is_pressed():
				if buildModeOn :
					build_mode.visible = false
					buildModeOn = false
				else :
					build_mode.visible = true
					buildModeOn = true
					
	if buildModeOn :
		if event is InputEventMouse:
			if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
				
				build_mode.set_cell(build_mode.local_to_map(build_mode.get_local_mouse_position()),0,Vector2(6,16))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_delay_timeout() -> void:
	var enemies = enemies_scene.instantiate()
	enemies.name = "enemies"
	$Enemies.add_child(enemies)
	enemies.position = enemy_tiles.map_to_local(Vector2(windowXAxis/(amountOfPixelInATile * 2),0))
	enemies.target = $TrucADefendre
	
