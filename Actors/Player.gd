extends KinematicBody2D

onready var BULLET = preload("./Bullets/Bullet.tscn")
onready var LASER = preload("./Bullets/Laser.tscn")
onready var GRENADE = preload("./Bullets/Grenade.tscn")
onready var lvlUpParticles = preload('res://Particles/LevelUpParticles.tscn')

export var inGame = true

var isEnemy = false
var isOnCooldownSec = true
var particleExplode = true
var canNuke = false

var hits = 1

var lvlLabel
var sceneManager
var camera
var bulletTimer
var bulletCooldownSec = 0
var xpBar
var xpPercentage = 0
var xp = 0
var level = 0
onready var xpLevels = [
	[50.0, 1, BULLET, null, 1.5],
	[150.0, 0.7, BULLET, null, 0.9],
	[350.0, 0.6, LASER, GRENADE, 0.7],
	[750.0, 1, LASER, GRENADE, 0.5],
	[1500.0, 1],
	[3500.0, 1],
	[7500.0, 1],
	[1000.0, 1],
	[15000.0, 1],
	[20000.0, 1],
]
onready var xpNeeded = xpLevels[level][0]

func _ready():
	OS.window_fullscreen = true
	BG.texture.noise.seed = randf()
	if inGame:
		sceneManager = get_tree().get_root().get_node('World/SceneManager')
		camera = get_tree().get_root().get_node('World/Camera2D')
		bulletTimer = get_tree().get_root().get_node('World/Objects/Player/BulletTimer')
		xpBar = get_tree().get_root().get_node('World/Canvas/UI/EmptyXPBar/XPBar')
		lvlLabel = get_tree().get_root().get_node('World/Canvas/UI/EmptyXPBar/Label')

var velocity = Vector2.ZERO;
export var acceleration = 0.01
export var friction = 0.006
export var speed = 650
export var bulletCooldown = 1.5
var isOnCooldown = false

func _process(_delta):
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		if !isOnCooldown:
			isOnCooldown = true
			shoot()
	if Input.is_action_just_pressed("secondary_fire"):
		if !isOnCooldownSec and xpLevels[level][3] != null:
			isOnCooldownSec = true
			shootSec()
	checkXP()
	var input_velocity = Vector2(
		Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	input_velocity = input_velocity.normalized() * speed

	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

func shoot():
	if bulletTimer != null:
		$LIn.playback_speed = 1 / bulletCooldown
		$LIn.play("LeftIn")
		sceneManager.shoot = true
		var bullet = xpLevels[level][2].instance()
		bullet.connect("explode", self, "explode")
		get_tree().get_root().get_node('World/Objects/Bullets').add_child(bullet)
		bullet.transform = $BulletSpawn.global_transform
		yield(get_tree().create_timer(bulletCooldown), "timeout")
		isOnCooldown = false

func shootSec():
	if bulletTimer != null:
		sceneManager.shoot = true
		var bullet = xpLevels[level][3].instance()
		bulletCooldownSec = bullet.cooldown
		bullet.connect("explode", self, "explode")
		get_tree().get_root().get_node('World/Objects/Bullets').add_child(bullet)
		bullet.transform = $BulletSpawn.global_transform
		yield(get_tree().create_timer(bulletCooldownSec), "timeout")
		isOnCooldownSec = false

func explode(_body):
	camera.shake(0.3, 50, 15)
	sceneManager.explode = true

func checkXP():
	if xpBar != null:
		xpPercentage = (xp / xpNeeded)
		xpBar.rect_size.x = 768 * xpPercentage
		if xp >= xpNeeded:
			levelUp()

func levelUp():
	var lvlUpParticle = lvlUpParticles.instance()
	get_tree().get_root().get_node('World/Objects/Particles').add_child(lvlUpParticle)
	lvlUpParticle.position = position
	lvlUpParticle.emitting = true
	mapParticles(lvlUpParticle)
	level += 1
	if xpLevels[level][3] != null:
		isOnCooldownSec = false
		$BulletTimer/FullR.rect_size.x = 40
		$BulletTimer/FullR.color = '#96ff0000'
	else:
		$BulletTimer/FullR.rect_size.x = 0
	lvlLabel.text = 'LVL: ' + str(level + 1)
	xp -= xpNeeded
	xpNeeded = xpLevels[level][0]
	xpBar.rect_size.x = 0
	xpPercentage = 0
	sceneManager.killAll()
	var scaleVector = camera.zoom + Vector2(0.2, 0.2)
	scaleVector.x = clamp(scaleVector.x, 0, 1.6)
	scaleVector.y = clamp(scaleVector.y, 0, 2.37)
	$Tween.interpolate_property(camera, "zoom",
		camera.zoom, scaleVector, 0.1,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	$Tween.interpolate_property(self, "scale",
		scale, scaleVector, 0.01,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	bulletCooldown = xpLevels[level][4]
	for b in get_tree().get_root().get_node('World/Objects/Bullets').get_children():
		b.queue_free()

func mapParticles(particle):
	if not particle == null:
		particle.position = global_position
		yield(get_tree().create_timer(0.001), "timeout")
		mapParticles(particle)
