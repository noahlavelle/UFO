extends KinematicBody2D

export var acceleration = 0.5
export var friction = 0.5
export var speed = 450
export var xp = 10
export var spawnWeight = 60
export var level = 0

var hits = 1

var particleExplode = false

onready var player = get_tree().get_root().get_node('World/Objects/Player')
onready var enemies = get_tree().get_root().get_node('World/Objects/Enemies')
onready var particles = get_tree().get_root().get_node('World/Objects/Particles')
onready var sceneManager = get_tree().get_root().get_node('World/SceneManager')
onready var camera = get_tree().get_root().get_node('World/Camera2D')

var velocity = Vector2.ZERO
var pushVector = Vector2.ZERO
var isEnemy = true

enum {
	ATTACK,
	IDLE
}

var state = ATTACK

func _process(delta):
	match state:
		ATTACK:
			if player != null:
				look_at(player.global_position)
				var direction = global_position.direction_to(player.global_position)
				velocity = direction * speed
			else:
				state = IDLE
				velocity = Vector2.ZERO
	velocity += pushVector * 175 * Vector2(-1, -1)
	var collision = move_and_collide(velocity * delta)
	if collision != null and collision.collider.name == 'Player':
		sceneManager.killAll()
		sceneManager.deathHandling()
		sceneManager.killBody(player)
		set_process(false)

func _on_Area2D_area_entered(area):
	pushVector = global_position.direction_to(area.global_position)
