extends Area

var playerRef : KinematicBody = null
var disabled := false

func _ready():
	playerRef = Globals.playerRef

func _process(delta):
	rotate_y(delta)
	

func _on_PistolPickup_body_entered(body):
	if !disabled && body.is_in_group("Player"):
		Events.emit_signal("pistolGrabbed")
		visible = false
		disabled = true
		set_process(false)

func _on_PistolPickup_body_exited(body):
	pass # Replace with function body.
