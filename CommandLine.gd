extends Control

var isHeldDown := false

enum Commands {ENEMY, ITEM, TRIGGER, NOCLIP, FLY}

export (String) var enemyDir = "res://Scenes/Enemies/"
export (String) var itemDir = "res://Scenes/Items/"
export (String) var triggerDir = "res://Scenes/Trigger/"

var lineEditRef : LineEdit = null

func _ready():
	lineEditRef = $CenterContainer/LineEdit

func _input(event):
	if event.is_action_pressed("COMMAND_LINE") && !isHeldDown:
		visible = !visible
		isHeldDown = true
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			lineEditRef.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_released("COMMAND_LINE") && isHeldDown:
		isHeldDown = false

func _on_LineEdit_text_entered(text : String):
	text = text.lstrip(" ").rstrip(" ")
	var firstSpace : int = text.find(" ")
	var nextSpace : int = 0
	var command : String
	var value : String
	
	if firstSpace == -1:
		command = text
	else:
		command = text.substr(0, firstSpace)
		value = text.substr(firstSpace+1)
		value = value.lstrip(" ")
	
	runCommand(command, value)
	
func runCommand(command : String, value : String):
	pass

func spawnEntity(value : String, path : String):
	var directory := Directory.new()
	var file := File.new()
	if !directory.dir_exists(path):
		lineEditRef.text = path + " does not exist!"
		return
		
	if !file.file_exists(path + value + ".tscn"):
		lineEditRef.text = value + ".tscn" + " cannot be found!"
		
	var entity = load(path + value + ".tscn").instance()
	get_tree().current_scene.add_child(entity)
	entity.global_transform.origin = Globals.playerRef.global_transform.origin
	
	lineEditRef.text = ""
	
func noclip():
	Globals.playerRef.noclip()
	
func fly():
	Globals.playerRef.fly()

