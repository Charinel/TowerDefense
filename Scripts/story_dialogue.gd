extends Node2D

@onready var textArea: TextureRect = $Dialogue/TextArea
@onready var speaker: TextureRect = $Dialogue/ImageOfSpeaking
@onready var text: Label = $Dialogue/Label

var mainImage = Image.load_from_file("res://Ressources/capy.jpg")
var mainTexture = ImageTexture.create_from_image(mainImage)

var militaryImage = Image.load_from_file("res://Ressources/capyTank.png")
var militaryTexture = ImageTexture.create_from_image(militaryImage)

var orderInArray = 0
var dictionaire = {
	#utiliser json file à la place
	"greeting": ["mon nom est vidange","j'aime les tortues","mon nom est poil","je veux du steak"],
	"words" : ["je suis gay","pas moi"]
}
var personagesTexture = {
	"greeting": [mainTexture,mainTexture,militaryTexture,militaryTexture],
	"words" : [mainTexture,militaryTexture]
}

#● Stringlanguage [default: ""]set_language(value) setterget_language() getter
# à utiliser dans un futur pour avoir des languages différent
#Language code used for line-breaking and text shaping algorithms, if left empty current locale is used instead.

func _ready() -> void:
	dialog1()

func showText() -> void:
	textArea.show()
	speaker.show()
	text.show()
	
func hideText() -> void:
	textArea.hide()
	speaker.hide()
	text.hide()

func dialog1() -> void:
	showText()
	text.text = dictionaire["greeting"][orderInArray]
	speaker.texture = personagesTexture["greeting"][orderInArray]

func nextText(diag) -> void:
	orderInArray += 1
	if dictionaire[diag].size() > orderInArray:
		text.text = dictionaire[diag][orderInArray]
		speaker.texture = personagesTexture[diag][orderInArray]
	else :
		hideText()
