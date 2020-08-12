extends Control

func _ready():
	$Tween.interpolate_property($Menu, "modulate", 
	  Color(1, 1, 1, -1), Color(1, 1, 1, 1), 1, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_NewGame_pressed():
	$Menu/CenterRow/Buttons/NewGame.disabled = true
	$Tween.interpolate_property($Menu, "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(1), "timeout")
	var _scene = get_tree().change_scene("res://Scenes/World.tscn")


