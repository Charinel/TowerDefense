extends Node2D

var enemies_scene: PackedScene = load("res://scene/enemies.tscn")
var turret_scene: PackedScene = load("res://scene/turret.tscn")
var farmer_scene: PackedScene = load("res://scene/farmer.tscn")
var river_scene: PackedScene = load("res://scene/river.tscn")
var furnace_scene: PackedScene = preload("res://scene/four.tscn")

var riverGhost_scene: PackedScene = load("res://scene/river_ghost.tscn")
var farmerGhost_scene: PackedScene = load("res://scene/farmer_ghost.tscn")
var turretGhost_scene: PackedScene = load("res://scene/turret_ghost.tscn")
var factoryGhost_scene: PackedScene = load("res://scene/factory_ghost.tscn")

@onready var tileMapNormalTiles: TileMapLayer = $Map/NormalTiles
@onready var enemy_tiles: TileMapLayer = $Map/EnemyTiles
@onready var totalFlesh: Label = $CanvasLayer/UI/TotalFlesh
@onready var UIbuild_mode: Control = $"CanvasLayer/UI/Build mode"
@onready var turretButton: Button = $"CanvasLayer/UI/Build mode/Turret"
@onready var conveyorBeltButton: Button = $"CanvasLayer/UI/Build mode/ConveyorBelt"
@onready var mineButton: Button = $"CanvasLayer/UI/Build mode/Mine"
@onready var pathButton: Button = $"CanvasLayer/UI/Build mode/Path"
@onready var start_roundButton: Button = $"CanvasLayer/UI/Build mode/Start Round"
@onready var sellButton: Button = $"CanvasLayer/UI/Build mode/Sell"
@onready var factoryButton: Button = $"CanvasLayer/UI/Build mode/Factory"

@onready var building: TileMapLayer = $Map/Building
@onready var roundSystem: Node2D = $RoundSystem
@onready var gracePeriodTimer: Timer = $"CanvasLayer/UI/Build mode/Start Round/GracePeriod"
@onready var storyDialogue: Node2D = $CanvasLayer/UI/StoryDialogue
@onready var pause_menu: Node = $CanvasLayer/PauseMenu


var amountOfPixelInATile = 16
var fade_duration = 1.0

var windowXAxis = 1920
var windowYAxis = 1000

var money = 10000000000

var pathCost = 5
var pathInflation = 1.2
var refundInflation = .66

var currentGhost

@export var noise_texture: NoiseTexture2D
var noise: Noise
var normalTileAtlas = Vector2(0,0)
var enemyTileAtlas = Vector2(4,2) 
var ironPatchAtlas = Vector2i(10,2)

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
			KEY_ESCAPE:
				if pause_menu.timer.is_stopped():
					pause_menu.showMenu()
				
	if event is InputEventMouse:
		if (event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT):
			clearSelection()
		if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
			#turret option selected
			if turretButton.button_pressed :
				var turret = turret_scene.instantiate()
				turret.position = setCenterOfCell(building.get_local_mouse_position())
				if checkIfThereIsPlace(turret.position) and checkMoney(turret.get_cost()):
					$Turrets.add_child(turret)
				else :
					turret.free()
			#mine option selected
			elif mineButton.button_pressed :
				if tileMapNormalTiles.get_cell_atlas_coords(building.local_to_map(building.get_local_mouse_position())) == ironPatchAtlas:
					var mine = farmer_scene.instantiate()
					mine.position = setCenterOfCell(building.get_local_mouse_position())
					if checkIfThereIsPlace(mine.position) and checkMoney(mine.get_cost()):
						mine.rotation = currentGhost.rotation
						$Mines.add_child(mine)
					else :
						mine.free()
			#Conveyor option selected
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
			#path option selected
			elif pathButton.button_pressed :
				var posOfClick = setCenterOfCell(building.get_local_mouse_position())
				if checkIfThereIsPlace(posOfClick) and checkMoney(pathCost):
					enemy_tiles.set_cell(Vector2(posOfClick.x/amountOfPixelInATile,posOfClick.y/amountOfPixelInATile),0,verifSurrounding(posOfClick))
					var tempPathCost = roundi(pathCost * pathInflation)
					if tempPathCost < 250 :
						pathCost = tempPathCost
					else :
						pathCost = 250
					updateNeighbourCell(posOfClick)
			
			elif sellButton.button_pressed :
				sellBuilding(setCenterOfCell(building.get_local_mouse_position()))
				
			elif factoryButton.button_pressed :
				var factory = furnace_scene.instantiate()
				factory.position = setCenterOfCell(building.get_local_mouse_position())
				if checkIfThereIsPlace(factory.position) and checkMoney(factory.get_cost()):
					$Factories.add_child(factory)
				else :
					factory.free()
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
		
	if Input.is_action_pressed("spawnEnnemy"):
		spawn()
		var event = InputEventAction.new()
		event.action = "spawnEnnemy"
		event.pressed = false
		Input.parse_input_event(event)
		
	if $Enemies.get_child_count() == 0 and $"CanvasLayer/UI/Build mode/Start Round/GracePeriod".is_stopped():
		start_roundButton.disabled = false
		pathButton.disabled = false
		sellButton.disabled = false
		for x in $Mines.get_child_count():
			if $Mines.get_child(x).name != "FarmerGhost":
				$Mines.get_child(x).startProduction()

func spawn() -> void:
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
	
	for y in range(0,windowYAxis/amountOfPixelInATile,1):		
		enemy_tiles.set_cell(Vector2(windowXAxis/(amountOfPixelInATile * 2),y),0,enemyTileAtlas)
		
	$TrucADefendre.position = setCenterOfCell(Vector2(windowXAxis/2,windowYAxis - amountOfPixelInATile))

func checkMoney(costOfObj) -> bool:
	if money >= costOfObj:
		money -= costOfObj
		return true
	else:
		return false
func setButtonOff() -> void:
	turretButton.button_pressed = false
	conveyorBeltButton.button_pressed = false
	mineButton.button_pressed = false
	pathButton.button_pressed = false
	sellButton.button_pressed = false
	factoryButton.button_pressed = false

func _on_turret_pressed() -> void:
	setButtonOff()
	turretButton.button_pressed = true
	changeGhost(currentGhost, turretGhost_scene)
	$Turrets.add_child(currentGhost)

func _on_conveyor_belt_pressed() -> void:
	setButtonOff()
	conveyorBeltButton.button_pressed = true
	changeGhost(currentGhost, riverGhost_scene)
	$ConveyorBelts.add_child(currentGhost)

func _on_mine_pressed() -> void:
	setButtonOff()
	mineButton.button_pressed = true
	changeGhost(currentGhost, farmerGhost_scene)
	$Mines.add_child(currentGhost)
	
func _on_path_pressed() -> void:
	setButtonOff()
	pathButton.button_pressed = true
	clearGhost()

func changeGhost(ghost,scene) -> void:
	currentGhost = scene.instantiate()
	currentGhost.position = setCenterOfCell(building.get_local_mouse_position())
	
	if ghost != null:
		ghost.queue_free()
		ghost = null
		
func clearGhost() -> void:
	if currentGhost != null:
		currentGhost.free()
	
func _on_start_round_pressed() -> void:
	roundSystem.nextRound()
	start_roundButton.disabled = true
	gracePeriodTimer.start()
	pathButton.disabled = true
	sellButton.disabled = true
	for x in $Mines.get_child_count():
			if $Mines.get_child(x).name != "FarmerGhost":
				$Mines.get_child(x).startProduction()

func verifSurrounding(posOfClick) -> Vector2:
	var droite = false
	var gauche = false
	var haut = false
	var bas = false
	var pathToSend = Vector2(4,2) 
	
	#vérif a dorite
	if enemy_tiles.get_cell_tile_data(Vector2((posOfClick.x + amountOfPixelInATile)/amountOfPixelInATile,(posOfClick.y)/amountOfPixelInATile)) != null:
		droite = true
		pathToSend = Vector2(5,1) 
		
	#Vérif a gauche
	if enemy_tiles.get_cell_tile_data(Vector2((posOfClick.x - amountOfPixelInATile)/amountOfPixelInATile,(posOfClick.y)/amountOfPixelInATile)) != null:
		gauche = true
		if droite :
			pathToSend = Vector2(6,0) 
		else :
			pathToSend = Vector2(7,1) 

	#Vérif en bas
	if enemy_tiles.get_cell_tile_data(Vector2((posOfClick.x)/amountOfPixelInATile,(posOfClick.y + amountOfPixelInATile)/amountOfPixelInATile)) != null:
		bas = true
		if gauche :
			pathToSend = Vector2(7,1) 
			
		if droite :
			pathToSend = Vector2(5,1)
			if gauche :
				pathToSend = Vector2(6,1) 

	#Vérif en haut
	if enemy_tiles.get_cell_tile_data(Vector2((posOfClick.x)/amountOfPixelInATile,(posOfClick.y - amountOfPixelInATile)/amountOfPixelInATile)) != null:
		haut = true
		if gauche :
			pathToSend = Vector2(7,3) 
			if bas :
				pathToSend = Vector2(7,2)
				
		if droite :
			pathToSend = Vector2(5,3) 
			if gauche :
				pathToSend = Vector2(6,3) 
				if bas :
					pathToSend = Vector2(6,2) 
					return pathToSend
			if bas :
				pathToSend = Vector2(5,2) 
				return pathToSend
	
	return pathToSend

func _on_sell_pressed() -> void:
	setButtonOff()
	sellButton.button_pressed = true
	clearGhost()
	

func sellBuilding(pos) -> void:
	if pos.y >= windowYAxis :
		return 
		
	for x in $Turrets.get_child_count():
		var turret = $Turrets.get_child(x)
		if turret.position == pos :
			refund(turret)
			turret.free()
			return
			
	for x in $ConveyorBelts.get_child_count():
		var belt = $ConveyorBelts.get_child(x)
		if belt.position == pos :
			refund(belt)
			belt.free()
			return
			
	for x in $Mines.get_child_count():
		var mine = $Mines.get_child(x)
		if mine.position == pos :
			refund(mine)
			mine.free()
			return
			
	for x in $Factories.get_child_count():
		var factory = $Factories.get_child(x)
		if factory.position == pos :
			refund(factory)
			factory.free()
			return
			
	if enemy_tiles.get_cell_atlas_coords(building.local_to_map(pos)) != Vector2i(-1, -1):
		enemy_tiles.erase_cell(building.local_to_map(pos))
		refundPath()

func updateNeighbourCell(pos) -> void:
	#vérif dorite
	if enemy_tiles.get_cell_tile_data(Vector2((pos.x + amountOfPixelInATile)/amountOfPixelInATile,(pos.y)/amountOfPixelInATile)) != null:
		enemy_tiles.set_cell(Vector2((pos.x + amountOfPixelInATile)/amountOfPixelInATile, pos.y/amountOfPixelInATile),0,verifSurrounding(Vector2(pos.x + amountOfPixelInATile,pos.y)))
	#Vérif a gauche
	if enemy_tiles.get_cell_tile_data(Vector2((pos.x - amountOfPixelInATile)/amountOfPixelInATile,(pos.y)/amountOfPixelInATile)) != null:
		enemy_tiles.set_cell(Vector2((pos.x - amountOfPixelInATile)/amountOfPixelInATile, pos.y/amountOfPixelInATile),0,verifSurrounding(Vector2(pos.x - amountOfPixelInATile,pos.y)))
	#Vérif en bas
	if enemy_tiles.get_cell_tile_data(Vector2((pos.x)/amountOfPixelInATile,(pos.y + amountOfPixelInATile)/amountOfPixelInATile)) != null:
		enemy_tiles.set_cell(Vector2(pos.x/amountOfPixelInATile, (pos.y + amountOfPixelInATile)/amountOfPixelInATile),0,verifSurrounding(Vector2(pos.x,pos.y + amountOfPixelInATile)))
	#Vérif en haut
	if enemy_tiles.get_cell_tile_data(Vector2((pos.x)/amountOfPixelInATile,(pos.y - amountOfPixelInATile)/amountOfPixelInATile)) != null:
		enemy_tiles.set_cell(Vector2(pos.x/amountOfPixelInATile, (pos.y - amountOfPixelInATile)/amountOfPixelInATile),0,verifSurrounding(Vector2(pos.x,pos.y - amountOfPixelInATile)))

func refund(obj) -> void:
	var tempCost = obj.get_cost()
	#L'idée c'est de faire perdre du cash pour éviter de spend n'importe comment
	money += roundi(tempCost * refundInflation)

func refundPath() -> void:
	money += roundi(pathCost * refundInflation)
	pathCost = roundi(pathCost / pathInflation)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var event = InputEventAction.new()
	event.action = "removeHealth"
	event.pressed = true
	Input.parse_input_event(event)
	body.queue_free()
	
func clearSelection() -> void:
	clearGhost()
	turretButton.button_pressed = false
	turretButton.release_focus()
	mineButton.button_pressed = false
	mineButton.release_focus()
	conveyorBeltButton.button_pressed = false
	conveyorBeltButton.release_focus()
	pathButton.button_pressed = false
	pathButton.release_focus()
	sellButton.button_pressed = false
	sellButton.release_focus()
	turretButton.button_pressed = false
	turretButton.release_focus()

func _on_test_feature_pressed() -> void:
	storyDialogue.dialog1()

func _on_factory_pressed() -> void:
	setButtonOff()
	factoryButton.button_pressed = true
	changeGhost(currentGhost, factoryGhost_scene)
	$Factories.add_child(currentGhost)
