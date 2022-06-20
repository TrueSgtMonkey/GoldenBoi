extends Area

export (int) var gold = 5000

var disabled := false
var time := 0.0

func _process(delta):
	time += delta
	$MeshInstance.rotate_y(delta)
	$MeshInstance.transform.origin.y = sin(time * 2.0) * 0.25
	$CollisionShape.transform.origin.y = sin(time * 2.0) * 0.25

func _on_Gold_body_entered(body):
	if !disabled && body.is_in_group("Player"):
		body.damage(-gold)
		setDisabled(true)
		$RespawnTimer.start()

func _on_Gold_body_exited(body):
	pass # Replace with function body.

func setDisabled(disabled : bool):
	visible = !disabled
	self.disabled = disabled
	set_process(!disabled)

func _on_RespawnTimer_timeout():
	setDisabled(false)
