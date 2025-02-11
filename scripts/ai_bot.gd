extends CharacterBody2D

# Movement settings
@export var move_speed = 200  # Pixels per second
@export var tilemap: TileMapLayer  # Assign your TileMap node in the Godot editor
var move_distance: float = 128  # Distance to move in one step (should match grid size)

var is_moving = false
var target_position = Vector2.ZERO
var directions = []
var current_direction_index = 0

func _ready():
	if tilemap:
		# Get tile size from the TileMap
		var tile_size = tilemap.tile_set.tile_size
		print("Tile Size: ", tile_size)
		
		# Calculate move_distance based on tile size and scale
		move_distance = tile_size.x * tilemap.scale.x
		print("Move Distance: ", move_distance)
		
		# Set the AI's position to the center of the first grid cell
		var grid_center = Vector2(
			move_distance / 2,  # Center of the first cell horizontally
			move_distance / 2   # Center of the first cell vertically
		)
		position = grid_center
		print("AI Position: ", position)
	
	target_position = position
	
	# Example: Set directions for the AI to follow
	var ai_directions = [
		Vector2(1, 0),  # RIGHT
		Vector2(0, 1),  # DOWN
		Vector2(0, 1),  # DOWN
		Vector2(1, 0),  # RIGHT
		Vector2(1, 0),  # RIGHT
		Vector2(0, 1),  # DOWN
		Vector2(0, 1)   # DOWN
	]
	set_directions(ai_directions)

func _process(delta):
	if is_moving:
		move_toward_target(delta)
	elif directions.size() > 0 and current_direction_index < directions.size():
		attempt_move(directions[current_direction_index])

# Attempt to move in a specific direction
func attempt_move(direction):
	if not is_moving:  # Only move if not already moving
		var new_target = position + direction * move_distance
		if is_position_valid(new_target):  # Check if the target position is valid
			target_position = new_target
			is_moving = true
			current_direction_index += 1  # Move to the next direction in the list

# Move toward the target position
func move_toward_target(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * move_speed

	# Move the AI using move_and_slide
	move_and_slide()

	# Check if the AI has reached the target position
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
		[self]  # Exclude the AI from collision detection
	)

	# Perform the raycast
	var result = space_state.intersect_ray(ray_query)
	return result.is_empty()  # Return true if no collision

# Set the list of directions for the AI to follow
func set_directions(new_directions):
	directions = new_directions
	current_direction_index = 0  # Reset the direction index
