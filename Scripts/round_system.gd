extends Node2D

var listOfPower := []
var powerLvl = 0
var totalPowerLvl = 0
var roundNumber = 0 
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#la liste est utile pour le normal mode par contre en story mode les rounds vont être preset
	for i in range(0, 5001, 50):
		listOfPower.append(i)

func getPowerLevel(roundNumber) -> int:
	return listOfPower[roundNumber]

func start() -> void:
	powerLvl = getPowerLevel(roundNumber)
	var timerDelay = randf_range(0.0, 1.0)
	$Timer.wait_time = timerDelay
	timer.start()
	totalPowerLvl = powerLvl * (4 * timerDelay) # c'est pour changer la difficulté selon la vitesse de spawn

func setRound(x) -> void:
	roundNumber = x

func nextRound() -> int:
	if timer.is_stopped() :
		roundNumber += 1
		start()
	return roundNumber

func _on_timer_timeout() -> void:
	if totalPowerLvl > 0 :
		#va faire des case pour les différents ennemy et chacun va changer la valeur de power a retirer
		var event = InputEventAction.new()
		event.action = "spawnEnnemy"
		event.pressed = true
		Input.parse_input_event(event)
		totalPowerLvl -= 10
		timer.start()
