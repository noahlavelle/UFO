extends Area2D

onready var deathParticles = preload('res://Particles/DeathParticles.tscn')
onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var sceneManager =  get_tree().get_root().get_node('World/SceneManager')

signal explode

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	queue_free()

func _process(_delta):
	transform = player.get_node('BulletSpawn').global_transform

func _on_Bullet_body_entered(body):
	body.hits -= 8
	var deathParticle = deathParticles.instance()
	get_tree().get_root().get_node('World/Objects/Particles').add_child(deathParticle)
	deathParticle.position = body.position
	deathParticle.emitting = true
	emit_signal("explode", body)
	if body.hits <= 0:
		player.xp += body.xp
		sceneManager.killBody(body)
