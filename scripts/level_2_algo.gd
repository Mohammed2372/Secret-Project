extends Node2D

# Movement directions (Up, Down, Left, Right)
var dy = [-1, 1, 0, 0]
var dx = [0, 0, -1, 1]

# BFS function to find shortest path to the nearest 'C' cell
func bfs(maze: Array, start_x: int, start_y: int) -> Array:
	var n = maze.size()
	var m = maze[0].size()
	var visited = []
	var parent = {}  # Dictionary to track the parent of each cell

	# Initialize visited array
	for i in range(n):
		visited.append([])
		for j in range(m):
			visited[i].append(false)

	var queue = []
	queue.append(Vector2(start_x, start_y))
	visited[start_x][start_y] = true
	parent[Vector2(start_x, start_y)] = null  # Start cell has no parent

	while queue.size() > 0:
		var p = queue.pop_front()
		var x = int(p.x)
		var y = int(p.y)

		for i in range(4):
			var ny = y + dy[i]
			var nx = x + dx[i]

			if ny >= 0 and ny < n and nx >= 0 and nx < m and not visited[nx][ny] and maze[nx][ny] != "#":
				visited[nx][ny] = true
				parent[Vector2(nx, ny)] = Vector2(x, y)  # Set parent of (nx, ny) to (x, y)
				queue.append(Vector2(nx, ny))

				if maze[nx][ny] == "C" or maze[nx][ny] == "B":
					return reconstruct_path(parent, nx, ny)  # Return reconstructed path

	return []  # Return empty path if no 'C' or 'B' is found

# Reconstruct path from (x, y) to start using parent dictionary
func reconstruct_path(parent: Dictionary, x: int, y: int) -> Array:
	var path = []
	var current = Vector2(x, y)

	while current != null:
		path.append(current)
		current = parent.get(current, null)

	path.reverse()  # Reverse to get path from start to target
	return path

# Algorithm to find all 'C' cells one by one
func algo(maze: Array, start_x: int, start_y: int) -> Array:
	var full_path = []
	var x = start_x
	var y = start_y

	while true:
		# Find shortest path to the nearest 'C'
		var path = bfs(maze, x, y)
		if path.is_empty():
			break  # No more 'C' cells found

		# Append the path to full_path
		full_path.append_array(path)

		# Update position to the last 'C' found
		x = path[-1].x
		y = path[-1].y

		# Mark current 'C' as visited or block it to avoid revisiting
		maze[x][y] = "#"

	return full_path

# Convert path coordinates to movement directions
func path_to_directions(path: Array) -> Array:
	var directions = []
	for i in range(1, path.size()):
		var dx = path[i].x - path[i - 1].x
		var dy = path[i].y - path[i - 1].y
		
		if dx == 1:
			directions.append("Down")
		elif dx == -1:
			directions.append("Up")
		elif dy == 1:
			directions.append("Right")
		elif dy == -1:
			directions.append("Left")
	
	return directions
