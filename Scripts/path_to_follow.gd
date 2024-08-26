extends PathFollow2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_ratio == 1:
		print("remove 1 hp to core")
		#TO DO trigger event qui va kill l'ennemy et son path
