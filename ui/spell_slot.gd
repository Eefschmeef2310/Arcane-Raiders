extends TextureRect
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.



func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	#Runs per frame
	pass

func change_prompt(tex: Texture2D):
	$Prompt.texture = tex
	
func hide_prompt():
	$Prompt.hide()

func show_prompt():
	$Prompt.show()
