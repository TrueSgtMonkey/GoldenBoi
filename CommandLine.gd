extends Control

enum Commands {ITEM, ENEMY, TRIGGER, NOCLIP, FLY, BIND, UNBIND}

const KEY_BIND_SYMBOLS := {
	"," : KEY_COMMA, "<" : KEY_LESS,
	"." : KEY_PERIOD, ">" : KEY_GREATER,
	"/" : KEY_SLASH, "?" : KEY_QUESTION,
	";" : KEY_SEMICOLON, ":" : KEY_COLON,
	"\'" : KEY_APOSTROPHE, "\"" : KEY_QUOTEDBL,
	"[" : KEY_BRACELEFT, "{" : KEY_BRACELEFT,
	"]" : KEY_BRACERIGHT, "}" : KEY_BRACERIGHT,
	"-" : KEY_MINUS, "_" : KEY_UNDERSCORE,
	"=" : KEY_EQUAL, "+" : KEY_PLUS,
	"\\" : KEY_BACKSLASH, "|" : KEY_BAR
}

export (String) var enemyDir = "res://Scenes/Enemies/"
export (String) var itemDir = "res://Scenes/Items/"
export (String) var triggerDir = "res://Scenes/Trigger/"
export (float) var clearTime = 3.0

export (String) var userKeyBindsPath = "user://"
export (String) var userKeyBindsName = "keybinds"
export (String) var userKeyBindsSectionName = "bound_keys"

var keyBinds := {} # key binds for the current session
var lineEditRef : LineEdit = null
var config = ConfigFile.new()
var isHeldDown := false
var lastKey : int = -1

func loadKeyBinds():
	if config.load(userKeyBindsPath + userKeyBindsName + ".cfg") != OK:
		printerr("Cannot find " + userKeyBindsPath + userKeyBindsName + ".cfg")
		return
	
	if !config.has_section(userKeyBindsSectionName):
		print("Cannot find " + userKeyBindsSectionName)
		return
		
	var sectionKeys : PoolStringArray = config.get_section_keys(userKeyBindsSectionName)
	for key in sectionKeys:
		if key.is_valid_integer():
			keyBinds[int(key)] = config.get_value(userKeyBindsSectionName, key)
		else:
			printerr(key, " is not a valid integer!")

func _ready():
	lineEditRef = $CenterContainer/LineEdit
	$ClearTimer.wait_time = clearTime
	$ClearTimer.connect("timeout", self, "clearText")
	loadKeyBinds()

func _input(event):
	if event.is_action_pressed("COMMAND_LINE") && !isHeldDown:
		visible = !visible
		isHeldDown = true
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			lineEditRef.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		clearText()
	elif event.is_action_released("COMMAND_LINE") && isHeldDown:
		isHeldDown = false
		clearText()
		
	# parsing a command if a key that is bound to a command is pressed
	if event is InputEventKey && lastKey < 0 && !visible:
		if keyBinds.has(event.scancode):
			parseInputText(keyBinds.get(event.scancode))
			lastKey = event.scancode
			
	# making sure a bound key only activates once
	if lastKey >= 0 && !Input.is_key_pressed(lastKey):
		lastKey = -1

func _on_LineEdit_text_entered(text : String):
	parseInputText(text)
		
	clearText()
	
func parseInputText(text : String):
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
	
	if runCommand(command, value, getCommandCode(command)) == "":
		return

func getCommandCode(command : String) -> int:
	match command.to_lower():
		"item":
			return Commands.ITEM
		"enemy":
			return Commands.ENEMY
		"trigger":
			return Commands.TRIGGER
		"noclip":
			return Commands.NOCLIP
		"fly":
			return Commands.FLY
		"bind":
			return Commands.BIND
		"unbind":
			return Commands.UNBIND
		_:
			badMessage("Cannot parse " + command + "!")
			command = ""
	
	return -1

func runCommand(command : String, value : String, commandCode : int) -> String:
	match commandCode:
		Commands.ITEM:
			spawnEntity(value, itemDir)
		Commands.ENEMY:
			spawnEntity(value, enemyDir)
		Commands.TRIGGER:
			spawnEntity(value, triggerDir)
		Commands.NOCLIP:
			noclip()
		Commands.FLY:
			fly()
		Commands.BIND:
			bindCommand(value)
		Commands.UNBIND:
			unbindCommand(value)
		_:
			badMessage("Cannot parse " + command + "!")
			command = ""
	return command
	
func bindCommand(keyToCmd : String):
	var keyToBind : String = keyToCmd.substr(0, 1)
	var scancode : int = OS.find_scancode_from_string(keyToBind)
	
	# symbol key OR incorrect key
	if scancode == 0:
		scancode = getSymbolScancode(keyToBind)
		if scancode == 0:
			badMessage("Cannot bind " + keyToBind + " to " + keyToCmd)
			return
	
	# now we know our scancode is valid
	var firstSpace : String = keyToCmd.substr(1, 1)
	if firstSpace != " ":
		badMessage("bind syntax: bind <key> <arg>")
		return
		
	var arg : String = keyToCmd.substr(2).lstrip(" \"")
	var argSpaceIdx : int = arg.find(" ")
	var command : String = arg.substr(0, argSpaceIdx)
	if getCommandCode(command) == -1:
		badMessage("invalid command entered for key binding")
		return
	
	keyBinds[scancode] = arg
	config.set_value(userKeyBindsSectionName, str(scancode), arg)
	config.save(userKeyBindsPath + userKeyBindsName + ".cfg")
	
func unbindCommand(boundKey : String):
	"""k"""
	if boundKey.length() != 1:
		badMessage("unbind only expects one key!")
		return
		
	var scancode : int = OS.find_scancode_from_string(boundKey)
	if scancode == 0:
		scancode = getSymbolScancode(boundKey)
		
	if scancode == 0:
		badMessage("Invalid key!")
		return
	
	if !keyBinds.has(scancode):
		badMessage("Cannot unbind " + boundKey + " - doesn't exist!")
		return
	
	keyBinds.erase(scancode)
	config.erase_section_key(userKeyBindsSectionName, str(scancode))
	config.save(userKeyBindsPath + userKeyBindsName + ".cfg")

func getSymbolScancode(keyToBind : String) -> int:
	var scancode : int = 0
	if KEY_BIND_SYMBOLS.has(keyToBind):
		scancode = KEY_BIND_SYMBOLS.get(keyToBind)
	
	return scancode

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
