extends Node2D

var path_follow_2d: PathFollow2D
var path2d: Path2D
var remote_transform_2d: RemoteTransform2D
var movementSpeed = 100
var id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path_follow_2d = path2d.get_child(id)
	remote_transform_2d = path_follow_2d.get_child(0)
	remote_transform_2d.remote_path = self.get_path()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path_follow_2d.progress += delta * movementSpeed
	pass
