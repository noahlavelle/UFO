extends Node2D

func _ready():
	get_tree().paused = true
	$SceneManager/Tween.interpolate_property($Objects, "modulate", 
	  Color(1, 1, 1, -1), Color(1, 1, 1, 1), 1.2, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SceneManager/Tween.start()
	$SceneManager/Tween.interpolate_property($Canvas/UI, "modulate", 
	  Color(1, 1, 1, -1), Color(1, 1, 1, 1), 1.2, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SceneManager/Tween.start()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
