extends CharacterBody2D

var chase = false
var alive = true
var speed = 100
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# If the enemy is dead, stop running all physics code immediately so it stays on the floor
	if not alive:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var player = $"../Player/player"
	var direction = (player.position - self.position).normalized()
	
	if chase == true:
		velocity.x = direction.x * speed
		anim.play("run")
	else:
		velocity.x = 0
		anim.play("idle")
		
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
			
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "player":
		chase = true

func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "player":
		chase = false

func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "player" and alive:
		death()

func _on_death_2_body_entered(body: Node2D) -> void:
	if body.name == "player" and alive:
		body.health -= 40
		death()

func death() -> void:
	alive = false
	velocity = Vector2.ZERO
	
	# Turn off the collision so the player can walk right through the dead body
	$CollisionShape2D.set_deferred("disabled", true)
	
	anim.play("death")
	await anim.animation_finished
	queue_free()
