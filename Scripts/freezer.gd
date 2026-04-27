extends Usine

@onready var craftingTime: Timer = $Timer

func _ready() -> void:
	spawn_interval = 2
	
func _on_area_of_itself_area_entered(area: Area2D) -> void:
	if canAcceptItem :
		setTypeOfItem(area.get_parent())
		area.get_parent().queue_free()
	else : holdItem = area.get_parent()

func setTypeOfItem(item)-> void:

	match item.type:
		stateOfItem.NORMAL:
			item_scene = load("res://scene/item/freezeItem.tscn")
		stateOfItem.FIRE:
			item_scene = load("res://scene/item/item.tscn")
		stateOfItem.ASH:
			item_scene = load("res://scene/item/fireItem.tscn")
		stateOfItem.FREEZE:
			item_scene = load("res://scene/item/deepFreezeItem.tscn")
		stateOfItem.DEEPFREEZE:
			item_scene = load("res://scene/item/destroyItem.tscn")
		stateOfItem.DRIED:
			item_scene = load("res://scene/item/driedItem.tscn")
		stateOfItem.ULTRADRY:
			item_scene = load("res://scene/item/destroyItem.tscn")
	startProduction()
