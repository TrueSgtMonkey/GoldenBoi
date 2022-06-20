extends Spatial

const Alien = preload("res://Scenes/Enemies/Alien.tscn")

func _ready():
	$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	var enemy = Alien.instance()
	get_tree().current_scene.add_child(enemy)
	enemy.global_transform.origin = global_transform.origin
