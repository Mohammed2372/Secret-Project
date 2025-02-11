extends CharacterBody2D

# Movement settings
@export var move_speed = 200  # Pixels per second
@export var move_distance: float = 128  # Distance to move in one step (should match grid size)

var is_moving = false  # Whether the player is currently moving
var target_position = Vector2.ZERO  # Target position for movement

# Called when the node enters the scene tree
func _ready():
	target_position = position  # Initialize target position to current position

# Called every frame
func _process(delta):
	if is_moving:
		move_toward_target(delta)
	else:
		handle_input()

# Handle player input
func handle_input():
	if Input.is_action_just_pressed("ui_up"):
		attempt_move(Vector2.UP)
	elif Input.is_action_just_pressed("ui_down"):
		attempt_move(Vector2.DOWN)
	elif Input.is_action_just_pressed("ui_left"):
		attempt_move(Vector2.LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		attempt_move(Vector2.RIGHT)

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
