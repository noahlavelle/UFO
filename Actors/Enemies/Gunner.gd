extends KinematicBody2D

export var acceleration = 0.5
export var friction = 0.5
export var speed = 450
export var xp = 10
export var spawnWeight = 40
export var level = 1

var particleExplode = false

onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var Bullet = preload('res://Actors/Bullets/Bullet.tscn')
onready var enemies = get_tree().get_root().get_node('World/Objects/Enemies')
onready var particles = get_tree().get_root().get_node('World/Objects/Particles')
onready var sceneManager = get_tree().get_root().get_node('World/SceneManager')
onready var camera = get_tree().get_root().get_node('World/Camera2D')

var velocity = Vector2.ZERO
var pushVector = Vector2.ZERO
var isEnemy = true
var hits = 1

enum {
	ATTACK,
	IDLE,
}

var state = ATTACK

func _process(delta):
	match state:
		ATTACK:
			if player != null:
				look_at(player.global_position)
				var direction = global_position.direction_to(player.global_position)
				velocity = direction * speed
				if position.distance_to(player.global_position) < 600:
					var move_vector = position.direction_to(player.global_position) * Vector2(-1, -1)
					velocity = move_vector * speed
				var shootChance = stepify(randf() * 100, 0.1)
				if shootChance == 0.1:
					if position.distance_to(player.global_position) > 600 and position.distance_to(player.global_position) < 900:
						var bullet =  Bullet.instance()
						bullet.connect("explode", self, "explode")
						get_tree().get_root().get_node('World/Objects/Bullets').add_child(bullet)
						bullet.transform = $BulletSpawn.global_transform
						bullet.speed = 400
						bullet.get_node('Line2D').default_color = '#ff3131'
						sceneManager.shoot_low = true
			else:
				state = IDLE
				velocity = Vector2.ZERO
	velocity += pushVector * 125 * Vector2(-1, -1)
	var collision = move_and_collide(velocity * delta)
	if collision != null and collision.collider.name == 'Player':
		sceneManager.killAll()
		sceneManager.deathHandling()
		player.queue_free()

func _on_Area2D_area_entered(area):
	pushVector = global_position.direction_to(area.global_position)

func explode(body):
	if body == player:
		sceneManager.killAll()
		sceneManager.deathHandling()
		sceneManager.killBody(player)
	else:
		sceneManager.explode = true
