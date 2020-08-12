extends Area2D

var speed = 1500

onready var deathParticles = preload('res://Particles/DeathParticles.tscn')
onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var sceneManager =  get_tree().get_root().get_node('World/SceneManager')

signal explode

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Bullet_body_entered(body):
	body.hits -= 1
	var deathParticle = deathParticles.instance()
	get_tree().get_root().get_node('World/Objects/Particles').add_child(deathParticle)
	deathParticle.position = body.position
	deathParticle.emitting = true
	emit_signal("explode", body)
	if body.hits == 0:
		player.xp += body.xp
		sceneManager.killBody(body)
		queue_free()
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
