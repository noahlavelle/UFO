extends Node

var explodeBig = false
var shoot = false
var shoot_low = false
var explode = false
var ending = false

signal input

onready var death = get_tree().get_root().get_node('World/Canvas/DeathScreen')
onready var ui = get_tree().get_root().get_node('World/Canvas/UI')
onready var deathParticles = preload('../Particles/DeathParticles.tscn')
onready var explodeParticles = preload('../Particles/ExplosionParticles.tscn')
onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var camera = get_tree().get_root().get_node('World/Camera2D')
onready var enemies = get_tree().get_root().get_node('World/Objects/Enemies')
onready var rng = RandomNumberGenerator.new()

#Enemies
onready var Rammer = preload("res://Actors/Enemies/Rammer.tscn")
onready var Gunner = preload("res://Actors/Enemies/Gunner.tscn")
onready var Tank = preload("res://Actors/Enemies/Tank.tscn")
onready var enemiesArray = [
	Rammer, Gunner, Tank
]

func _ready():
	spawn()

var audioPlayer = null

func _process(_delta):
	if explode:
		explode = false
		playSound("res://Assets/Sounds/explode.ogg", 10)
	if explodeBig:
		explodeBig = false
		playSound("res://Assets/Sounds/explode_big.ogg", 10)
	if shoot:
		shoot = false
		playSound("res://Assets/Sounds/laser.ogg", 15)
	if shoot_low:
		shoot_low = false
		playSound("res://Assets/Sounds/laser_low.ogg", 15)
	

func _input(ev):
	if ev is InputEventMouseButton:
		emit_signal("input")


func playSound(path, volume):
		audioPlayer = AudioStreamPlayer.new()
		add_child(audioPlayer)
		audioPlayer.stream = load(path)
		audioPlayer.volume_db -= volume
		audioPlayer.play()

func deathHandling():
	ending = true
	yield(get_tree().create_timer(1.5), "timeout")
	$Tween.interpolate_property(death, "modulate", 
	  Color(1, 1, 1, -1), Color(1, 1, 1, 1), 1, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Tween.interpolate_property(ui, "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	yield(self, "input")
	$Tween.interpolate_property(death, "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	var _scene = get_tree().reload_current_scene()

func spawn():
	if player != null and not ending:
		for i in get_viewport().size.x / 16:
			for j in get_viewport().size.y / 16:
				var distance = Vector2(16 * i, 16 * j).distance_to(player.global_position)
				if distance > 1000 and distance < 1300:
					var spawnRate = 100 / player.xpLevels[player.level][1]
					var chance = stepify(rng.randf_range(0, spawnRate), 0.1)
					if chance == 1:
						for e in enemiesArray:
							trySpawn(e, i, j)
	if not ending:
		yield(get_tree().create_timer(3), "timeout")
		spawn()

func trySpawn(e, i, j):
	var enemyChance = round(randf() * 100)
	var enemy = e.instance()
	if enemyChance <= enemy.spawnWeight:
		get_tree().get_root().get_node('World/Objects/Enemies').add_child(enemy)
		enemy.position = Vector2(16 * i, 16 * j)
		if enemy.level > player.level:
			enemy.queue_free()
	else:
		enemy.queue_free()
		trySpawn(e, i, j)

func killAll():
	camera.shake(1, 100, 30)
	explodeBig = true
	var deathParticle = deathParticles.instance()
	get_tree().get_root().get_node('World/Objects/Particles').add_child(deathParticle)
	deathParticle.position = player.global_position
	deathParticle.emitting = true
	for i in enemies.get_children():
		deathParticle = deathParticles.instance()
		get_tree().get_root().get_node('World/Objects/Particles').add_child(deathParticle)
		deathParticle.position = i.global_position
		deathParticle.emitting = true
		killBody(i)

func killBody(body):
	if body != null:
		if body.particleExplode:
			camera.shake(1, 100, 30)
			explodeBig = true
			var explodeParticle = explodeParticles.instance()
			get_tree().get_root().get_node('World/Objects/Particles').add_child(explodeParticle)
			explodeParticle.position = body.global_position
			explodeParticle.emitting = true
		body.set_process(false)
		body.get_node('Collider').call_deferred("disabled", true)
		if body.isEnemy:
			body.get_node('RepulsionArea/AreaCollider').call_deferred("disabled", true)
			body.position = Vector2(-100, -100)
		body.visible = false
		yield(get_tree().create_timer(3), "timeout")
		if body != null:
			body.queue_free()
	
