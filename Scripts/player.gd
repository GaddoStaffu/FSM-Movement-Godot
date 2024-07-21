extends CharacterBody2D


@export var RUNNING = 160
@export var DASHING = 230
@export var SLIDING = 170
@export var JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $Node2D/AnimatedSprite2D2
var current_state = STATE.IDLE
var is_jumping = false
@onready var character_flip = $Node2D
var is_attacking = false
var is_crouching = false
var is_dashing = false
var is_sliding = false
var attack_num = 0

enum STATE {
	IDLE,
	RUNNING,
	ATTACKING1,
	ATTACKING2,
	FALLING,
	JUMPING,
	CROUCH,
	DASHING,
	SLIDING,
	DASHATTACK
}

func _ready():
	pass



func _physics_process(delta):
	player_movement_controller(delta)
	match current_state:
		STATE.IDLE:
			if is_jumping == false and is_crouching == false :
				animation_player.play("idle_anim")
				velocity.x = 0
		STATE.RUNNING:
			var movement = Input.get_axis("left","right")
			animation_player.play("run_anim")
			if movement != 0 and is_dashing == false:
				velocity.x = movement * RUNNING
		STATE.DASHING:
			var movement = Input.get_axis("left","right")
			if movement != 0:
				velocity.x = movement * DASHING
				animation_player.play("dash_anim")
				is_dashing = true
				if Input.is_action_just_pressed("attack") and is_dashing == true:
					is_dashing = true
					current_state = STATE.DASHATTACK
		STATE.JUMPING:
			if is_on_floor() and is_sliding != true:
				velocity.y =  JUMP_VELOCITY
				animation_player.play("jump_anim")
		STATE.FALLING:
			is_jumping=false
			animation_player.play("fall_anim")
		STATE.ATTACKING1:
			velocity.x = 0
			is_attacking = true
			animation_player.play("attack_anim")
		STATE.ATTACKING2:
			animation_player.play("attack2_anim")
		STATE.CROUCH:
			velocity.x = 0
			is_crouching = true
			animation_player.play("crouch_anim")
		STATE.SLIDING:
			is_sliding = true
			var movement = Input.get_axis("left","right")
			if movement != 0 and is_on_floor():
				animation_player.play("slide_anim")
				velocity.x = movement * SLIDING
		STATE.DASHATTACK:
			animation_player.play("dashattack_anim")
			velocity.x = 0

	move_and_slide()
	print(current_state)








func player_movement_controller(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	#MOVEMENT INPUT
	var player_direction = Input.get_axis("left", "right")
	if player_direction != 0 and is_attacking != true and is_crouching == false and is_dashing == false and (is_on_floor() and is_sliding == false):
		current_state = STATE.RUNNING
	if player_direction > 0 and is_attacking != true and is_crouching == false and is_sliding == false:
		character_flip.scale.x = 1
	elif player_direction < 0 and is_attacking != true and is_crouching == false and is_sliding == false:
		character_flip.scale.x = -1
	if Input.is_action_pressed("up") and is_attacking != true and is_crouching == false and is_sliding == false:
		current_state = STATE.JUMPING
		is_jumping = true
	if velocity.y > 0 and !is_on_floor() and is_attacking != true and is_crouching == false and is_sliding == false:
		current_state = STATE.FALLING
	if player_direction == 0 and is_jumping == false and is_attacking == false and is_sliding == false and current_state == STATE.ATTACKING1:
		current_state = STATE.IDLE
	if Input.is_action_just_pressed("attack") and is_attacking != true and is_on_floor() and is_crouching == false and is_dashing == false and is_sliding == false:
		current_state = STATE.ATTACKING1
	if Input.is_action_just_pressed("down") and is_sliding == false and is_on_floor():
		current_state = STATE.CROUCH
	if Input.is_action_pressed("slide"):
		current_state = STATE.SLIDING
	if Input.is_action_just_pressed("dash") and is_on_floor():
		current_state = STATE.DASHING





func _on_animated_sprite_2d_2_animation_finished():
	is_attacking = false
	current_state = STATE.IDLE
	is_crouching = false
	if is_dashing == true:
		$Node2D/dash_timer.start()
	is_sliding = false




func _on_timer_timeout():
	is_dashing = false
	print("DASH FINISH")




