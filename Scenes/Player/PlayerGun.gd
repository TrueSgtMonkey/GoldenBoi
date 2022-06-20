extends Spatial

const PlayerGunProjectile = preload("res://Scenes/Player/PlayerGunProjectile.tscn")

var enabled := false

func _ready():
	setEnabled(false)
	Events.connect("pistolGrabbed", self, "pistolGrabbed")

func _input(event):
	if event.is_action_pressed("SHOOT") && enabled && Globals.playerRef.gold > 0:
		var playerGunProjectile = PlayerGunProjectile.instance()
		get_tree().current_scene.add_child(playerGunProjectile)
		playerGunProjectile.global_transform.origin = $PointBuddy.global_transform.origin
		Globals.playerRef.damage(5)
		
func setEnabled(enabled : bool):
	self.enabled = enabled
	if enabled:
		$MeshInstance.visible = true
	else:
		$MeshInstance.visible = false
		
func pistolGrabbed():
	setEnabled(true)
