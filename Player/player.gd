extends CharacterBody2D


enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	
}
var last_press_time: int = 0
const DOUBLE_PRESS_TIME: int = 300

const SPEED = 110.0
const JUMP_VELOCITY = -300.0


@onready var anim = get_node("AnimatedSprite2D")
@onready var animPlayer = $AnimationPlayer#
@onready var lightOcc = $LightOccluder2D

var health = 100
var pCount = 0
var maxCount = 2
var gold = 0
var state = MOVE
var runSpeed = 1
var combo = false
var attackCoolDown = false

				

func _physics_process(delta: float) -> void:
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
	# Add the gravity.
	if not is_on_floor():
		lightOcc.visible = false
		velocity += get_gravity() * delta
	else:
		lightOcc.visible = true
		pCount = 0	
		
	
		#if velocity.y == -400 and Input.is_action_pressed("ui_accept"):
			#velocity.y = JUMP_VELOCITY - 250
			#anim.play('double')
		#else:
			#velocity.y = JUMP_VELOCITY
			#anim.play('jump')
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	
	if health <= 0:
		health = 0
		animPlayer.play("dead")
		await animPlayer.animation_finished 
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")
		
	move_and_slide()
	
func move_state():
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED * runSpeed
		if velocity.y == 0:
			if runSpeed == 1:
				animPlayer.play('walk')
			else:
				animPlayer.play('run')
				
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play('idle')
		
	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false
	if Input.is_action_pressed('cRun'):
		runSpeed = 2
	else:
		runSpeed = 1
	if velocity.y > 0:
		animPlayer.play('fall')
	
	if Input.is_action_pressed("block"):
		state = BLOCK
	
	if Input.is_action_just_pressed("attack") and attackCoolDown == false:
		state = ATTACK
		
	if Input.is_action_just_pressed("jump"): # Usually the Spacebar
		# 3. Check if the player is on the floor OR hasn't used up all jumps yet
		if is_on_floor() or pCount < maxCount:
			
			velocity.y = JUMP_VELOCITY
			animPlayer.play('jump')
			pCount += 1
			
			
			if pCount == 2:
				animPlayer.play('doubleJump')
				velocity.y = JUMP_VELOCITY + 200
	
				
func block_state ():
	velocity.x = 0
	animPlayer.play("shield")
	if Input.is_action_just_released('block'):
		state = MOVE
func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("attack_1")
	await animPlayer.animation_finished
	attackFreze()
	state = MOVE

func attack2_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animPlayer.play("attack_2")
	await animPlayer.animation_finished
	state = MOVE

func attack3_state():
	animPlayer.play("attack_3")
	await animPlayer.animation_finished
	state = MOVE
	
func combo1 ():
	combo = true
	await animPlayer.animation_finished
	combo = false

func attackFreze():
	attackCoolDown = true
	await get_tree().create_timer(0.7).timeout
	attackCoolDown= false
