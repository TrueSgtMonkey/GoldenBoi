extends KinematicBody

const GRAVITY := 30.0
const MAX_MOVE_CHANCE = 4
const SUCCESS_MOVE_CHANCE = 1
const NEAR_ZERO = 0.01

enum ActionStates {IDLE, CHASE}
var actionState : int = ActionStates.IDLE
enum MoveStates {STILL, WALKING, RUNNING}
var moveState : int = MoveStates.STILL

export (float) var speed = 2.0
export (float, 0.0, 10.0) var chaseMultiplier = 1.75
export (int) var damage = 1
export (int) var health = 100

#variables
var velocity := Vector3()
var delta := 0.0
var currDir := Vector3()
var isFacingPlayer := false

func _ready():
	$IdleTimer.connect("timeout", self, "idleMove")
	$IdleTimer.start()
	$CheckPlayerTimer.connect("timeout", self, "checkIfFacingPlayer")
	$CheckPlayerTimer.start()

func _physics_process(delta):
	self.delta = delta
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y -= GRAVITY * delta
	
	checkPlayer()
	chasePlayer()
	
	move_and_slide(velocity, Vector3.UP, true)
	
	var slides : int = get_slide_count()
	var stealingFromPlayer := false
	for slide in slides:
		var col : KinematicCollision = get_slide_collision(slide)
		if col.collider && col.collider.is_in_group("Player"):
			stealingFromPlayer = true
			col.collider.damage(int(damage * delta))
		
func idleMove():
	if actionState == ActionStates.IDLE:
		var dir := Vector3(float((randi() % 3) - 1), 0, float((randi() % 3) - 1)).normalized()
		var moveChance : int = randi() % MAX_MOVE_CHANCE
		velocity.x = 0
		velocity.z = 0
		
		if moveChance >= SUCCESS_MOVE_CHANCE:
			moveState = MoveStates.WALKING
			velocity += dir * speed
		else:
			moveState = MoveStates.STILL
		if abs(dir.x) >= NEAR_ZERO || abs(dir.z) >= NEAR_ZERO:
			setRotationFromVelocity(dir)
			currDir = dir
		
func damage(damage : int):
	if is_on_floor():
		health -= damage
	else:
		health -= damage * 4
	velocity *= -1.0
	velocity.y = speed * 4.0
	
	if health < 0:
		disableAll()
		
func disableAll():
	set_physics_process(false)
	set_process(false)
	$CollisionShape.disabled = true
	visible = false
	$IdleTimer.stop()
	$CheckPlayerTimer.stop()
	$RayCast.enabled = false
		
func checkIfFacingPlayer():
	var AP = Globals.playerRef.global_transform.origin - global_transform.origin
	if facingPlayer(AP) > 0:
		isFacingPlayer = true
	else:
		isFacingPlayer = false
		
func checkPlayer():
	if is_instance_valid(Globals.playerRef):
		$RayCast.cast_to = Globals.playerRef.global_transform.origin
		if $RayCast.is_colliding():
			if isFacingPlayer:
				actionState = ActionStates.CHASE
				moveState = MoveStates.RUNNING
		else:
			actionState = ActionStates.IDLE
			moveState = MoveStates.STILL
		
func chasePlayer():
	if is_instance_valid(Globals.playerRef):
		match actionState:
			ActionStates.IDLE:
				pass
			ActionStates.CHASE:
				var dir : Vector3 = (Globals.playerRef.global_transform.origin - global_transform.origin).normalized()
				
				velocity.x = 0
				velocity.z = 0
				
				velocity += dir * speed * chaseMultiplier
				setRotationFromVelocity(dir)
			

func setRotationFromVelocity(vel : Vector3):
	look_at(transform.origin - vel, Vector3.UP)

func getVelocity():
	return velocity
	
func facingPlayer(vec : Vector3):
	var temp : Vector3 = vec.normalized()
	return temp.dot(currDir)
