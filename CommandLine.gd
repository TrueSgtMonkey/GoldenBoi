extends Control

enum Commands {ITEM, ENEMY, TRIGGER, NOCLIP, FLY}

export (String) var enemyDir = "res://Scenes/Enemies/"
export (String) var itemDir = "res://Scenes/Items/"
export (String) var triggerDir = "res://Scenes/Trigger/"
export (float) var clearTime = 3.0

var lineEditRef : LineEdit = null
var isHeldDown := false

func _ready():
	lineEditRef = $CenterContainer/LineEdit
	$ClearTimer.wait_time = clearTime
	$ClearTimer.connect("timeout", self, "clearText")

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
	var command : String
	var value : String
	
	if firstSpace == -1:
		command = text
	else:
		command = text.substr(0, firstSpace)
		value = text.substr(firstSpace+1)
		value = value.lstrip(" ")
	
	if runCommand(command, value) == "":
		return
		
	clearText()

#enum Commands {ITEM, ENEMY, NOCLIP, FLY}
func runCommand(command : String, value : String):
	match command.to_lower():
		"item":
			spawnEntity(value, itemDir)
		"enemy":
			spawnEntity(value, enemyDir)
		"trigger":
			spawnEntity(value, triggerDir)
		"noclip":
			noclip()
		"fly":
			fly()
		_:
			badMessage("Cannot parse " + command + "!")
			command = ""
	return command

func badMessage(text : String, time : float = clearTime):
	lineEditRef.text = text
	$ClearTimer.start(time)
	
func clearText():
	lineEditRef.text = ""

func spawnEntity(value : String, path : String):
	var directory := Directory.new()
	var file := File.new()
	if !directory.dir_exists(path):
		badMessage(path + " does not exist!")
		return
		
	if !file.file_exists(path + value + ".tscn"):
		badMessage(value + ".tscn" + " cannot be found!")
		return
		
	var entity = load(path + value + ".tscn").instance()
	get_tree().current_scene.add_child(entity)
	entity.global_transform.origin = Globals.playerRef.global_transform.origin
	
func noclip():
	Globals.playerRef.noclip()
	
func fly():
	Globals.playerRef.fly()
