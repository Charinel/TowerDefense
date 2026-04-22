extends CharacterBody2D

var movementSpeed = 100
var baseMS = movementSpeed
@export var target: Node2D = null
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var collision
@onready var hp = $HealthBar.max_value
var powerCost = 10
@onready var negative_effect: Timer = $NegativeEffect
@onready var dmg_tick: Timer = $NegativeEffect/dmgTick
var effect = Effect.effect.NOEFFECT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("setSeek")
	$HealthBar.value = hp
	
func setSeek() -> void:
	await get_tree().physics_frame
	if target:
		navigation_agent_2d.target_position = target.global_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var currentPosition = global_position
	var nextPosition = navigation_agent_2d.get_next_path_position()
	velocity = currentPosition.direction_to(nextPosition) * movementSpeed
	collision = move_and_collide(velocity * delta)
	
	if !negative_effect.is_stopped() and dmg_tick.is_stopped() and effect == Effect.effect.BURN:
		hp -= hp * .1
		
	if !negative_effect.is_stopped() and effect == Effect.effect.SLOW:
		movementSpeed = baseMS * .8

func hit(damage, receivedEffect) -> void:
	hp -= damage
	effect = receivedEffect
		
	if hp <= 0 :
		var event = InputEventAction.new()
		event.action = "addFlesh"
		event.pressed = true
		Input.parse_input_event(event)
		queue_free()

func setOnFire()-> void:
	negative_effect.wait_time = 3
	negative_effect.stop()
	negative_effect.start()

func ashSlow() -> void:
	negative_effect.wait_time = 2
	negative_effect.stop()
	negative_effect.start()


func _on_negative_effect_timeout() -> void:
	movementSpeed = baseMS
