extends Usine
@onready var craftingTime: Timer = $Timer

func _on_area_of_itself_area_entered(area: Area2D) -> void:
	if canAcceptItem :
		setTypeOfItem(area.get_parent())
		area.get_parent().queue_free()
	else : holdItem = area.get_parent()
	
func setTypeOfItem(item)-> void:

	match item.type:
		stateOfItem.NORMAL:
			item_scene = load("res://scene/item/fireItem.tscn")
			item.type = stateOfItem.FIRE
		stateOfItem.FIRE:
			item_scene = load("res://scene/item/asheItem.tscn")
			item.type = stateOfItem.ASH
		stateOfItem.ASH:
			item.type = stateOfItem.DESTROY
		stateOfItem.FREEZE:
			item.type = stateOfItem.NORMAL
		stateOfItem.DEEPFREEZE:
			item.type = stateOfItem.FREEZE
		stateOfItem.DRIED:
			#Fire Pierce
			pass
		stateOfItem.ULTRADRY:
			item.type = stateOfItem.DESTROY
	item.queue_free()
	startProduction()
