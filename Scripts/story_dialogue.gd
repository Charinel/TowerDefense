extends Node2D

@onready var textArea: TextureRect = $Dialogue/TextArea
@onready var speaker: TextureRect = $Dialogue/ImageOfSpeaking
@onready var text: Label = $Dialogue/Label

var mainImage = Image.load_from_file("res://Ressources/capy.jpg")
var mainTexture = ImageTexture.create_from_image(mainImage)

var militaryImage = Image.load_from_file("res://Ressources/capyTank.png")
var militaryTexture = ImageTexture.create_from_image(militaryImage)

var orderInArray = 0
var currentDiag = ""
var dictionaire = {
	#On lit le fichier coms.json pour remplir les données nécessaire
}
var personagesTexture = {
	"greeting": [mainTexture,mainTexture,militaryTexture,militaryTexture],
	"words" : [mainTexture,militaryTexture]
}

var json_file_path = "res://data/coms.json" #hard code pour l'instant mais on va load selon la langue selectionné

func loadJson() -> void:
	if FileAccess.file_exists(json_file_path):
		var file = FileAccess.open(json_file_path, FileAccess.READ)
		parse_json(file.get_as_text())
		file.close()
	else:
		print("Error: File not found")

func parse_json(json_string):
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		dictionaire = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_PAUSABLE va le changer quand le menu pause pop
	loadJson()
	hideText()

func showText() -> void:
	get_tree().paused = true
	textArea.show()
	speaker.show()
	text.show()
	
func hideText() -> void:
	get_tree().paused = false
	textArea.hide()
	speaker.hide()
	text.hide()
	currentDiag = ""

func dialog1() -> void:
	showText()
	currentDiag = "greeting"
	text.text = dictionaire[currentDiag][orderInArray]
	speaker.texture = personagesTexture[currentDiag][orderInArray]

func nextText(diag) -> void:
	orderInArray += 1
	if dictionaire[diag].size() > orderInArray:
		text.text = dictionaire[diag][orderInArray]
		speaker.texture = personagesTexture[diag][orderInArray]
	else :
		orderInArray = 0
		hideText()
		
func prevText(diag) -> void:
	orderInArray -= 1
	if dictionaire[diag].size() > orderInArray and orderInArray >= 0:
		text.text = dictionaire[diag][orderInArray]
		speaker.texture = personagesTexture[diag][orderInArray]
	else :
		orderInArray = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT) and textArea.visible:
			nextText(currentDiag)
		if (event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT) and textArea.visible:
			prevText(currentDiag)
