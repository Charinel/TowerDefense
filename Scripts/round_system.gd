extends Node2D

var listOfPower := []
var powerLvl = 0
var totalPowerLvl = 0
var roundNumber = 0 
var fade_duration = 1
@onready var timer: Timer = $Timer
@onready var roundNumberLabel: Label = $"Round number/Number"
@onready var roundShowTimer: Timer = $"Round number/RoundShow"

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
	timer.wait_time = timerDelay
	timer.start()
	totalPowerLvl = powerLvl * (4 * timerDelay) # c'est pour changer la difficulté selon la vitesse de spawn
	fade_in()
	roundShowTimer.start()

func setRound(x) -> void:
	roundNumber = x

func nextRound() -> int:
	if timer.is_stopped() :
		roundNumber += 1
		roundNumberLabel.text = "Round # " + str(roundNumber)
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
		
func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(roundNumberLabel, "modulate:a", 1, fade_duration)
	tween.play()
	await tween.finished
	tween.kill()

func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property(roundNumberLabel, "modulate:a", 0, fade_duration)
	tween.play()
	await tween.finished
	tween.kill()

func _on_round_show_timeout() -> void:
	fade_out()
