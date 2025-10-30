extends Node2D

var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
var turret_scene: PackedScene = load("res://scene/turret.tscn")
var farmer_scene: PackedScene = load("res://scene/farmer.tscn")
var river_scene: PackedScene = load("res://scene/river.tscn")
var riverGhost_scene: PackedScene = load("res://scene/river_ghost.tscn")
var farmerGhost_scene: PackedScene = load("res://scene/farmer_ghost.tscn")
var turretGhost_scene: PackedScene = load("res://scene/turret_ghost.tscn")
var round: PackedScene = load("res://scene/round_system.tscn")
@onready var tileMapNormalTiles: TileMapLayer = $Map/NormalTiles
@onready var enemy_tiles: TileMapLayer = $Map/EnemyTiles
@onready var totalFlesh: Label = $CanvasLayer/UI/TotalFlesh
@onready var UIbuild_mode: Control = $"CanvasLayer/UI/Build mode"
@onready var turretButton: Button = $"CanvasLayer/UI/Build mode/Turret"
@onready var conveyorBeltButton: Button = $"CanvasLayer/UI/Build mode/ConveyorBelt"
@onready var mineButton: Button = $"CanvasLayer/UI/Build mode/Mine"
@onready var building: TileMapLayer = $Map/Building
@onready var roundSystem: Node2D = $RoundSystem


var amountOfPixelInATile = 16

var windowXAxis = 1920
var windowYAxis = 1000

var money = 10000000000

var currentGhost

@export var noise_texture: NoiseTexture2D
var noise: Noise
var normalTileAtlas = Vector2(0,0)
var enemyTileAtlas = Vector2(4,2) 
var ironPatchAtlas = Vector2i(10,2)

var currentRound = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pour get la size de l'écran je hard code pour l'instant
	#windowXAxis = get_viewport().get_visible_rect().size[0]
	#windowYAxis = get_viewport().get_visible_rect().size[1]
	generateMap()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				if currentGhost != null:
					currentGhost.rotation += deg_to_rad(90)
					currentGhost.direction = Vector2.DOWN.rotated(currentGhost.rotation).round()
					if currentGhost.lastConveyor != null :
						currentGhost.changeOrientation()
				
	if event is InputEventMouse:
		if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
			if turretButton.button_pressed :
				var turret = turret_scene.instantiate()
				turret.position = setCenterOfCell(building.get_local_mouse_position())
				if checkIfThereIsPlace(turret.position) and checkMoney(turret.get_cost()):
					$Turrets.add_child(turret)
				else :
					turret.free()
			elif mineButton.button_pressed :
				if tileMapNormalTiles.get_cell_atlas_coords(building.local_to_map(building.get_local_mouse_position())) == ironPatchAtlas:
					var mine = farmer_scene.instantiate()
					mine.position = setCenterOfCell(building.get_local_mouse_position())
					if checkIfThereIsPlace(mine.position) and checkMoney(mine.get_cost()):
						mine.rotation = currentGhost.rotation
						$Mines.add_child(mine)
					else :
						mine.free()
			elif conveyorBeltButton.button_pressed :
				var conveyor = river_scene.instantiate()
				conveyor.position = setCenterOfCell(building.get_local_mouse_position())
				if checkIfThereIsPlace(conveyor.position) and checkMoney(conveyor.get_cost()):
					conveyor.rotation = currentGhost.rotation
					await get_tree().process_frame
					$ConveyorBelts.add_child(conveyor)
					conveyor.direction = currentGhost.direction
					conveyor.setConveyorDirection(currentGhost)
					currentGhost.setDefaultSprite()
				else :
					conveyor.free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	totalFlesh.text = str(money)
	if Input.is_action_pressed("addFlesh"):
		var rng = RandomNumberGenerator.new()
		money += rng.randi_range(0,3)
		
		var event = InputEventAction.new()
		event.action = "addFlesh"
		event.pressed = false
		Input.parse_input_event(event)
		
	if currentGhost != null:
		var mouse_pos = get_global_mouse_position()	
		var snapped_pos = mouse_pos.snapped(setCenterOfCell(building.get_local_mouse_position()))
		currentGhost.global_position = snapped_pos

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
	return pos

func checkIfThereIsPlace(pos: Vector2)-> bool:
	if pos.y >= windowYAxis :
		return false
	for x in $Turrets.get_child_count():
		if $Turrets.get_child(x).position == pos and $Turrets.get_child(x).name != "TurretGhost":
			return false
	for x in $ConveyorBelts.get_child_count():
		if $ConveyorBelts.get_child(x).position == pos and $ConveyorBelts.get_child(x).name != "RiverGhost":
			return false
	for x in $Mines.get_child_count():
		if $Mines.get_child(x).position == pos and $Mines.get_child(x).name != "FarmerGhost":
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
	
	for y in range(0,windowYAxis/amountOfPixelInATile,1):		
		enemy_tiles.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),y),0,enemyTileAtlas)
		
	$TrucADefendre.position = setCenterOfCell(Vector2(windowXAxis/2,windowYAxis - amountOfPixelInATile))

func checkMoney(costOfObj) -> bool:
	if money >= costOfObj:
		money -= costOfObj
		return true
	else:
		return false

func _on_turret_pressed() -> void:
	turretButton.button_pressed = true
	conveyorBeltButton.button_pressed = false
	mineButton.button_pressed = false
	changeGhost(currentGhost, turretGhost_scene)
	$Turrets.add_child(currentGhost)

func _on_conveyor_belt_pressed() -> void:
	turretButton.button_pressed = false
	conveyorBeltButton.button_pressed = true
	mineButton.button_pressed = false
	changeGhost(currentGhost, riverGhost_scene)
	$ConveyorBelts.add_child(currentGhost)

func _on_mine_pressed() -> void:
	turretButton.button_pressed = false
	conveyorBeltButton.button_pressed = false
	mineButton.button_pressed = true
	changeGhost(currentGhost, farmerGhost_scene)
	$Mines.add_child(currentGhost)

func changeGhost(ghost,scene) -> void:
	currentGhost = scene.instantiate()
	currentGhost.position = setCenterOfCell(building.get_local_mouse_position())
	
	if ghost != null:
		ghost.queue_free()
		ghost = null

func _on_start_round_pressed() -> void:
	round.start(currentRound + 1)
