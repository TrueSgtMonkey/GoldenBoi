extends Spatial

const Enemy = preload("res://Scenes/Enemies/Enemy.tscn")

func _ready():
	$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	var enemy = Enemy.instance()
	get_tree().current_scene.add_child(enemy)
	enemy.global_transform.origin = global_transform.origin
