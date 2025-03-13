extends Node2D  # Use Node2D as the base since we're working in 2D space

@export var main: Node2D  # Reference to the main game node
@export var move_speed = 200  # Movement speed in pixels per second

@onready var animation: AnimationPlayer = $SubViewportContainer/SubViewport/Skeleton_Warrior/AnimationPlayer
@onready var player: Node3D = $SubViewportContainer/SubViewport/Skeleton_Warrior

var move_distance: float = 128  # Distance to move in one step (should match grid size)
var is_moving = false  # Whether the player is currently moving
var target_position = Vector2.ZERO  # Target position for movement (2D)
var score = 0
var current_direction = Vector2.ZERO  # Track the current movement direction
var is_input_pressed = false  # Track if a movement key is currently pressed

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
		current_direction = Vector2.UP
		rotate_move_anim(current_direction)
	elif Input.is_action_pressed("down"):
		current_direction = Vector2.DOWN
		rotate_move_anim(current_direction)
	elif Input.is_action_pressed("left"):
		current_direction = Vector2.LEFT
		rotate_move_anim(current_direction)
	elif Input.is_action_pressed("right"):
		current_direction = Vector2.RIGHT
		rotate_move_anim(current_direction)
	else:
		animation.play("Idle")
		
func rotate_move_anim(direction):
		rotate_player(direction)
		attempt_move(direction)
		animation.play("Running_A")
# Rotate the 3D player model to face the movement direction
func rotate_player(direction: Vector2):
	if direction == Vector2.UP:
		player.rotation.y = deg_to_rad(180)  # Face up
	elif direction == Vector2.DOWN:
		player.rotation.y = deg_to_rad(0)  # Face down
	elif direction == Vector2.LEFT:
		player.rotation.y = deg_to_rad(-90)  # Face left
	elif direction == Vector2.RIGHT:
		player.rotation.y = deg_to_rad(90)  # Face right

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
	position += direction * move_speed * delta  # Move in 2D space

	# Check if the player has reached the target position
	if position.distance_to(target_position) < 5:  # Small threshold
		position = target_position  # Snap to the target position
		is_moving = false  # Stop moving

		# Immediately attempt to move again if the same key is still pressed
		if is_input_pressed:
			rotate_move_anim(current_direction)
		#else:
			#animation.play("Idle")  # Play idle animation when movement stops

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
