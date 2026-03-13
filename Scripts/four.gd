extends Usine

func _on_area_of_itself_area_entered(area: Area2D) -> void:
	var newItemEntered = area.get_parent()

	match newItemEntered.type:
		stateOfItem.NORMAL:
			newItemEntered.type = stateOfItem.FIRE
		stateOfItem.FIRE:
			newItemEntered.type = stateOfItem.ASH
		stateOfItem.ASH:
			#deltete the item
			pass
		stateOfItem.FREEZE:
			newItemEntered.type = stateOfItem.NORMAL
		stateOfItem.DEEPFREEZE:
			newItemEntered.type = stateOfItem.FREEZE
		stateOfItem.DRIED:
			#Fire Pierce
			pass
		stateOfItem.ULTRADRY:
			#Met le delais pareil mais rien ne change
			pass
