extends Node

# Global maze dimensions
const MAZE_WIDTH = 25
const MAZE_HEIGHT = 25

# Directions: [dx, dy]
const DIRECTIONS = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]

# Function to initialize a new maze with walls, open spaces, start, and end points
func initialize_maze() -> Dictionary:
	var maze = []
	var start_point = Vector2.ZERO
	var end_point = Vector2.ZERO
	
	# Initialize maze with walls
	for i in range(MAZE_HEIGHT):
		var row = []
		row.resize(MAZE_WIDTH)
		row.fill('#')
		maze.append(row)
	
	# Create grid of open spaces
	for i in range(1, MAZE_HEIGHT, 2):
		for j in range(1, MAZE_WIDTH, 2):
			maze[i][j] = '.' # Open spaces
	
	# Place start point ('S')
	start_point = Vector2(MAZE_HEIGHT - 1, MAZE_WIDTH - 2)
	maze[start_point.x][start_point.y] = 'S'
	
	# Place end point ('E') randomly
	var valid_end = false
	while not valid_end:
		var random_x = 1 + (randi() % (MAZE_HEIGHT / 2)) * 2
		var random_y = 1 + (randi() % (MAZE_WIDTH / 2)) * 2
		end_point = Vector2(random_x, random_y)
		
		# Ensure no overlap with 'S' and position is open
		if end_point != start_point and maze[end_point.x][end_point.y] == '.':
			maze[end_point.x][end_point.y] = 'E'
			valid_end = true
	
	return {
		"maze": maze,
		"start_point": start_point,
		"end_point": end_point
	}

# Function to check if a cell is within bounds
func is_valid(x: int, y: int) -> bool:
	return x >= 0 and x < MAZE_HEIGHT and y >= 0 and y < MAZE_WIDTH

# Function to perform one iteration of the maze generation algorithm
func iterate(maze: Array, origin: Vector2) -> Vector2:
	# Randomly select a direction
	var direction = DIRECTIONS[randi() % DIRECTIONS.size()]
	var next_x = origin.x + direction.x * 2 # Move two steps to skip walls
	var next_y = origin.y + direction.y * 2

	# Check if the next position is valid and not visited
	if is_valid(next_x, next_y) and maze[next_x][next_y] == '#':
		# Carve a path by removing walls
		maze[origin.x + direction.x][origin.y + direction.y] = '.'
		maze[next_x][next_y] = '.'

		# Update the origin to the new position
		return Vector2(next_x, next_y)
	
	return origin

# Function to generate the maze
func generate_maze(maze: Array) -> Array:
	# Start from the bottom-right corner ('S')
	var origin = Vector2(MAZE_HEIGHT - 1, MAZE_WIDTH - 2)

	# Perform iterations to carve out the maze
	var iterations = MAZE_WIDTH * MAZE_HEIGHT * 10
	for i in range(iterations):
		origin = iterate(maze, origin)
	
	return maze
# Function to print the maze
func print_maze(maze: Array) -> void:
	for row in maze:
		var line = ""
		for cell in row:
			line += str(cell)
		print(line)

func _ready():
	pass
	#randomize() # Seed the random number generator
#
	## Number of mazes to generate
	#const NUM_MAZES = 5
#
	## Generate and print multiple mazes
	#for i in range(1, NUM_MAZES + 1):
		#print("Maze #", i, ":")
		#
		## Initialize maze with start and end points
		#var maze_data = initialize_maze()
		#var maze = maze_data["maze"]
		#var start_point = maze_data["start_point"]
		#var end_point = maze_data["end_point"]
		#
		## Generate the maze
		#generate_maze(maze)
		#
		## Print the maze
		#print_maze(maze)
		#
		## Output coordinates
		#print("Start Point: (", start_point.x, ", ", start_point.y, ")")
		#print("End Point: (", end_point.x, ", ", end_point.y, ")")
		#print("")

func reset_state():
	# No persistent threads here, but expose a reset to clear any cached/random state
	# (Currently nothing to clear but kept for API consistency)
	return
