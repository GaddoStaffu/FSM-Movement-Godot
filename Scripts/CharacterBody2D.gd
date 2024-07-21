extends CharacterBody2D


const SPEED = 160
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $AnimatedSprite2D2
var current_state = STATE.IDLE
var is_jumping = false


enum STATE {
	IDLE,
	RUNNING,
	ATTACKING,
	FALLING,
	JUMPING
}

func _ready():
	pass



func _physics_process(delta):
	player_movement_controller(delta)
	match current_state:
		STATE.IDLE:
			if is_jumping !=true:
				animation_player.play("idle_anim")
				velocity.x = 0
				print("idle")
		STATE.RUNNING:
			var movement = Input.get_axis("left","right")
			if movement != 0:
				velocity.x = movement * SPEED
		STATE.JUMPING:
			if is_on_floor():
				velocity.y =  JUMP_VELOCITY
		STATE.FALLING:
			is_jumping=false
			print("FALLING")
	move_and_slide()
	print(current_state)
	print($"..".scale.x)








func player_movement_controller(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	#MOVEMENT INPUT
	var player_direction = Input.get_axis("left", "right")
	if player_direction != 0 :
		current_state = STATE.RUNNING
	if player_direction > 0:
		$"..".scale.x = 1
	elif player_direction < 0:
		$"..".scale.x = -1
	if Input.is_action_pressed("up"):
		current_state = STATE.JUMPING
		is_jumping = true
	if velocity.y > 0 and !is_on_floor():
		current_state = STATE.FALLING
	if player_direction == 0 and is_jumping == false:
		current_state = STATE.IDLE
		


