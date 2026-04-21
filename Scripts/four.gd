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
			item_scene = load("res://scene/item/fireItem.tscn")
		stateOfItem.FIRE:
			item_scene = load("res://scene/item/asheItem.tscn")
		stateOfItem.ASH:
			item_scene = load("res://scene/item/destroyItem.tscn")
		stateOfItem.FREEZE:
			item_scene = load("res://scene/item.tscn")
		stateOfItem.DEEPFREEZE:
			item.type = stateOfItem.FREEZE
		stateOfItem.DRIED:
			#Fire Pierce
			pass
		stateOfItem.ULTRADRY:
			item_scene = load("res://scene/item/destroyItem.tscn")
	startProduction()
