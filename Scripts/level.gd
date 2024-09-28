extends Node2D


var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
var turret_scene: PackedScene = load("res://scene/turret.tscn")
@onready var tileMapNormalTiles: TileMapLayer = $Map/NormalTiles
@onready var enemy_tiles: TileMapLayer = $Map/EnemyTiles
@onready var core: TileMapLayer = $TrucADefendre/Core
@onready var build_mode: TileMapLayer = $Map/BuildMode
@onready var totalFlesh: Label = $CanvasLayer/UI/TotalFlesh
@onready var UIbuild_mode: Control = $"CanvasLayer/UI/Build mode"
@onready var turretButton: Button = $"CanvasLayer/UI/Build mode/Turret"
@onready var conveyorBeltButton: Button = $"CanvasLayer/UI/Build mode/ConveyorBelt"
@onready var mineButton: Button = $"CanvasLayer/UI/Build mode/Mine"


var amountOfPixelInATile = 16
var buildModeOn = false

var windowXAxis
var windowYAxis

var flesh = 0

@export var noise_texture: NoiseTexture2D
var noise: Noise
var normalTileAtlas = Vector2(0,0)
var buildModeTileAtlas = Vector2(5,16)
var enemyTileAtlas = Vector2(4,2) 
var ironPatchAtlas = Vector2(10,2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windowXAxis = get_viewport().get_visible_rect().size[0]
	windowYAxis = get_viewport().get_visible_rect().size[1]
	generateMap()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.as_text_keycode() == "B":
			if event.is_pressed():
				if buildModeOn :
					build_mode.visible = false
					UIbuild_mode.visible = false
					buildModeOn = false
				else :
					build_mode.visible = true
					UIbuild_mode.visible = true
					buildModeOn = true
					
	if buildModeOn :
		if event is InputEventMouse:
			if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
				if turretButton.pressed :
					var turret = turret_scene.instantiate()
					turret.position = setCenterOfCell(build_mode.get_local_mouse_position())
					if checkIfThereIsPlace(turret.position):
						$Turrets.add_child(turret)
				elif mineButton.pressed :
					#mettre le code de la mine ici
					var turret = turret_scene.instantiate()
					turret.position = setCenterOfCell(build_mode.get_local_mouse_position())
					if checkIfThereIsPlace(turret.position):
						$Turrets.add_child(turret)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("addFlesh"):
		var rng = RandomNumberGenerator.new()
		flesh += rng.randi_range(0,3)

		totalFlesh.text = str(flesh)
		var event = InputEventAction.new()
		event.action = "addFlesh"
		event.pressed = false
		Input.parse_input_event(event)

func _on_spawn_delay_timeout() -> void:
	var enemies = enemies_scene.instantiate()
	enemies.name = "enemies"
	$Enemies.add_child(enemies)
	enemies.position = enemy_tiles.map_to_local(Vector2(windowXAxis/(amountOfPixelInATile * 2),0))
	enemies.target = $TrucADefendre

func setCenterOfCell(pos: Vector2) -> Vector2:
	var temp = pos.x/amountOfPixelInATile
	pos.x = floor(temp) * amountOfPixelInATile + (amountOfPixelInATile/2)
	temp = pos.y/amountOfPixelInATile
	pos.y = floor(temp) * amountOfPixelInATile + (amountOfPixelInATile/2)
	print(pos)
	return pos

func checkIfThereIsPlace(pos: Vector2)-> bool:
	for x in $Turrets.get_child_count():
		if $Turrets.get_child(x).position == pos :
			return false
	return true

func generateMap()-> void: #generate the map with a noise map
	noise = noise_texture.noise
	noise.seed = randi()
	
	$SpawnDelay.start()
	for x in range(0,windowXAxis/amountOfPixelInATile,1):
		for y in range(0,windowYAxis/amountOfPixelInATile,1):
			var noiseVal: float = noise.get_noise_2d(x,y)
			if noiseVal >= 0.4: #changer les values selon plus ou mois de iron patch
				tileMapNormalTiles.set_cell(Vector2(x,y),0,ironPatchAtlas)
			if noiseVal < 0.4:
				tileMapNormalTiles.set_cell(Vector2(x,y),0,normalTileAtlas)
			#tileMapNormalTiles.set_cell(Vector2(x,y),0,normalTileAtlas)
			build_mode.set_cell(Vector2(x,y),0,buildModeTileAtlas)
	build_mode.visible = false
	
	core.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),windowYAxis/amountOfPixelInATile),0,Vector2(2,18))
	$TrucADefendre.position = Vector2(windowXAxis/2 + amountOfPixelInATile/2,windowYAxis)
	
	for y in range(0,windowYAxis/amountOfPixelInATile,1):		
		enemy_tiles.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),y),0,enemyTileAtlas)
