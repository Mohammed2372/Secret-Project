extends CharacterBody2D

@export_category("main variables")
@export var main_script: Node2D
@export var tilemap: TileMapLayer  # Assign your TileMap node in the Godot editor
@export var player: CharacterBody2D
@export_category("ai variables")
@export var move_speed = 200  # Pixels per second
var move_distance: float = 128  # Distance to move in one step (should match grid size)

@onready var animation: AnimationPlayer = $SubViewportContainer2/SubViewport/Skeleton_Mage/AnimationPlayer
@onready var ai: Node3D = $SubViewportContainer2/SubViewport/Skeleton_Mage

var is_moving = false
var target_position = Vector2.ZERO
var directions = []
var current_direction_index = 0
var score = 0
var current_maze = []

func _ready():
	#print("AI script waiting for main script to finish...")
	# Wait until main script is ready
	while not main_script.is_ready:
		await get_tree().process_frame  # Wait for the next frame
	
	#print("AI script running after main script.")
	if tilemap:
		# Get tile size from the TileMap
		var tile_size = tilemap.tile_set.tile_size
		#print("Tile Size: ", tile_size)
		
		# Calculate move_distance based on tile size and scale
		move_distance = tile_size.x * tilemap.scale.x
		player.move_distance = move_distance
		#print("Move Distance: ", move_distance)
		
		## Set the AI's position to the center of the first grid cell
		#var grid_center = Vector2(
			#move_distance / 2,  # Center of the first cell horizontally
			#move_distance / 2   # Center of the first cell vertically
		#)
		
		# set ai and player position in the grids
		#position = grid_center
		#position.y -= 30
		#player.position = grid_center
		#player.position.y -= 30
		
		#print("Start Position: ", position)
	
	target_position = position
	
	#print("current level: " ,Global.level)
	# call the level function to call the global script
	if Global.level == 1:
		current_maze = Global.MAZE1.duplicate(true) # make copy of the maze to avoid modefying on the orignal
		level_1(current_maze)
	elif Global.level == 2:
		current_maze = Global.MAZE2.duplicate(true)
		level_2(current_maze)
	elif Global.level == 3:
		current_maze = Global.MAZE3.duplicate(true)
		level_3(current_maze)
	
	## animation
	#animation.play("Idle")

func _process(delta):
	if is_moving:
		move_toward_target(delta)
	elif directions.size() > 0 and current_direction_index < directions.size():
		attempt_move(directions[current_direction_index])
	
	## handle score
	if score >= Global.max_score:
		main_script.round_end = true

func level_1(maze):
	var x = 0
	var y = 0
	var full_path = Level1Algo.algo(maze, x, y)
	
	#print("Full path: ", full_path)
	
	directions = Level1Algo.path_to_directions(full_path)
	#print("Directions: ", directions)
	print(" length: ", len(directions))
	set_directions(convert_directions_to_vectors(directions))
	
func level_2(maze):
	directions = Level3Algo.get_ai_directions(maze)
	print("directions: ", directions)
	print(" length: ", len(directions))
	set_directions(convert_directions_to_vectors(directions))

func level_3(maze):
	var start_x = 0
	var start_y = 0
	var full_path = Level2Algo.algo(maze, start_x, start_y)
	#print("Full path: ", full_path)
	directions = Level2Algo.path_to_directions(full_path)
	#print("Directions: ", directions)
	print(" length: ", len(directions))
	set_directions(convert_directions_to_vectors(directions))

# Convert direction names to movement vectors
func convert_directions_to_vectors(direction_names):
	var direction_map = {
		"Up": Vector2(0, -1),
		"Down": Vector2(0, 1),
		"Left": Vector2(-1, 0),
		"Right": Vector2(1, 0)
	}
	var direction_vectors = []
	for dir in direction_names:
		if dir in direction_map:
			direction_vectors.append(direction_map[dir])
	return direction_vectors

# Attempt to move in a specific direction
func attempt_move(direction):
	if not is_moving:  # Only move if not already moving
		var new_target = position + direction * move_distance
		if is_position_valid(new_target):  # Check if the target position is valid
			target_position = new_target
			is_moving = true
			current_direction_index += 1  # Move to the next direction in the list
			## animation
			animation.play("Running_C")
			rotate_toward_direction(direction)
	
# Move toward the target position
func move_toward_target(_delta):
	var direction = (target_position - position).normalized()
	velocity = direction * move_speed
	
	# Move the AI using move_and_slide
	move_and_slide()
	
	# Check if the AI has reached the target position
	if position.distance_to(target_position) < 5:  # Small threshold
		position = target_position  # Snap to the target position
		is_moving = false  # Stop moving
		velocity = Vector2.ZERO  # Reset velocity
		## animation
		#animation.play("Idle")

# Rotate the AI toward the movement direction
func rotate_toward_direction(direction: Vector2):
	if direction == Vector2.UP:
		ai.rotation.y = deg_to_rad(180)  # Facing up
	elif direction == Vector2.DOWN:
		ai.rotation.y = deg_to_rad(0)  # Facing down
	elif direction == Vector2.LEFT:
		ai.rotation.y = deg_to_rad(-90)  # Facing left
	elif direction == Vector2.RIGHT:
		ai.rotation.y = deg_to_rad(90)  # Facing right

# Check if a position is valid (e.g., not blocked by walls or obstacles)
func is_position_valid(pos):
	# Create a PhysicsRayQueryParameters2D object
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(
		self.position,  # Start position
		pos,  # End position
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

func _on_area_2d_area_entered(body):
	if body.is_in_group("coin"):
		score += Global.COIN_VALUE
		#Global.ai_score += 1
		#print("AI score: ", score)
		body.queue_free()
	if body.is_in_group("key"):
		score += Global.KEY_VALUE
		#Global.ai_score += 10
		#print("AI score: ", score)
		body.queue_free()
