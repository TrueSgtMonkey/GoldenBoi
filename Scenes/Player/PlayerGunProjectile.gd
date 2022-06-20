extends KinematicBody

export (int) var damage = 5
export (float) var speed = 15.0

var dir := Vector3()
var velocity := Vector3()

func _ready():
	global_transform.basis = Globals.cameraRef.global_transform.basis
	dir = -global_transform.basis.z
	velocity = dir.normalized() * speed
	
func _physics_process(delta):
	var col = move_and_collide(velocity * delta)
	if col:
		if col.collider.has_method("damage"):
			col.collider.damage(damage)
		queue_free()
