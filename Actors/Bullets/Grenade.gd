extends Area2D

onready var deathParticles = preload('res://Particles/DeathParticles.tscn')
onready var explodeParticles = preload('res://Particles/ExplosionParticles.tscn')
onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var sceneManager = get_tree().get_root().get_node('World/SceneManager')
onready var camera = get_tree().get_root().get_node('World/Camera2D')

var cooldown = 10.0

var target = []

var speed = Vector2(500, 500)

signal explode

func _process(delta):
	if speed > Vector2.ZERO:
		speed -= Vector2(1, 1)
	position += transform.x * speed * delta
	if Input.is_action_just_pressed("detonate"):
		queue_free()
		sceneManager.explodeBig = true
		camera.shake(1, 100, 30)
		explodeParticles = explodeParticles.instance()
		get_tree().get_root().get_node('World/Objects/Particles').add_child(explodeParticles)
		player.get_node('RIn').playback_speed = 1 / cooldown
		player.get_node('RIn').play("RightIn")
		explodeParticles.position = position
		explodeParticles.emitting = true
		for i in target:
			i.hits -= 100
			var deathParticle = deathParticles.instance()
			get_tree().get_root().get_node('World/Objects/Particles').add_child(deathParticle)
			deathParticle.position = i.position
			deathParticle.emitting = true
			emit_signal("explode", i)
			if i.hits <= 0:
				player.xp += i.xp
				sceneManager.killBody(i)

func _on_Area2D_body_entered(body):
	if body != player:
		target.push_front(body)


func _on_Area2D_body_exited(body):
	target.erase(body)
