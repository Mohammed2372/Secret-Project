extends CharacterBody2D

@export var main: Node2D
@export var move_speed = 200  # Pixels per second

@onready var sprite = $AnimatedSprite2D

var move_distance: float = 128  # Distance to move in one step (should match grid size)
var is_moving = false  # Whether the player is currently moving
var target_position = Vector2.ZERO  # Target position for movement
var score = 0

# Called when the node enters the scene tree
func _ready():
	target_position = position  # Initialize target position to current position
	# Wait for main to be ready
	while not main.is_ready:
		await get_tree().process_frame  # Wait for the next frame
	
# Called every frame
func _process(delta):
	if is_moving:
		move_toward_target(delta)
	else:
		handle_input()
	
	# Handle score
	if score == Global.max_score:
		main.round_end = true

# Handle player input and play animations
func handle_input():
	if Input.is_action_pressed("up"):
		sprite.play("up")
		attempt_move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		sprite.play("down")
		attempt_move(Vector2.DOWN)
	elif Input.is_action_pressed("left"):
		sprite.play("left")
		attempt_move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		sprite.play("right")
		attempt_move(Vector2.RIGHT)
	else:
		sprite.play("idle")  # If no input, play idle

# Attempt to move in a specific direction
func attempt_move(direction):
	if not is_moving:  # Only move if not already moving
		var new_target = position + direction * move_distance
		if is_position_valid(new_target):  # Check if the target position is valid
			target_position = new_target
			is_moving = true

# Move toward the target position
func move_toward_target(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * move_speed

	# Move the player using move_and_slide
	move_and_slide()

	# Check if the player has reached the target position
	if position.distance_to(target_position) < 5:  # Small threshold
		position = target_position  # Snap to the target position
		is_moving = false  # Stop moving
		velocity = Vector2.ZERO  # Reset velocity
		sprite.play("idle")  # Return to idle when movement stops

# Check if a position is valid (e.g., not blocked by walls or obstacles)
func is_position_valid(position):
	# Create a PhysicsRayQueryParameters2D object
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(
		self.position,  # Start position
		position,  # End position
		0b1,  # Collision mask (adjust as needed)
		[self]  # Exclude the player from collision detection
	)

	# Perform the raycast
	var result = space_state.intersect_ray(ray_query)
	return result.is_empty()  # Return true if no collision

# Collision handling with coins and keys
func _on_area_2d_area_entered(area):
	if area.is_in_group("coin"):
		score += 1
		area.queue_free()
		print("player score: ", score)
	if area.is_in_group("key"):
		score += 10
		print("player score: ", score)
		area.queue_free()
