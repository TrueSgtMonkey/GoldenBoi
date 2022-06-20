extends Node

signal playerRefSet(ref)

var playerRef : KinematicBody = null setget setPlayerRef, getPlayerRef
var cameraRef : Camera = null setget setCameraRef, getCameraRef

func _ready():
	randomize()

func setPlayerRef(player : KinematicBody):
	if player.is_in_group("Player"):
		playerRef = player
		emit_signal("playerRefSet", player)
		
func getPlayerRef():
	return playerRef
	
func setCameraRef(camera : Camera):
	cameraRef = camera
	
func getCameraRef():
	return cameraRef

func _input(event):
	if event.is_action_pressed("QUIT_GAME"):
		get_tree().quit()
