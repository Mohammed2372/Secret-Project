extends Node

# Directions: up, down, left, right
var dy = [-1, 1, 0, 0]
var dx = [0, 0, -1, 1]
var vis = []
var par = [] # Parent array
var dis = []

# Reconstruct path from (x, y) to start using parent array
func reconstruct_path(x, y):
	var path = []
	while x != -1 and y != -1:
		path.append(Vector2(x, y))
		var p = par[x][y]
		x = p.x
		y = p.y
	path.reverse() # Reverse to get path from start to target
	return path

# BFS to find the shortest path to all reachable coins
func bfs(maze, x, y):
	# Defensive: ensure maze is a 2D array
	if typeof(maze) != TYPE_ARRAY or maze.size() == 0 or typeof(maze[0]) != TYPE_ARRAY:
		#print("level_1_algo.bfs: invalid maze passed, type=", typeof(maze))
		return Vector2(-1, -1)

	var n = int(maze.size())
	var m = int(maze[0].size())
	var target = Vector2(-1, -1) # Target cell
	var max_distance = 0 # Maximum distance to a coin
	var q = []
	x = int(x)
	y = int(y)
	q.append(Vector2(x, y))
	# Ensure vis/par/dis have been initialized to correct dimensions by caller
	if vis.size() != n or par.size() != n or dis.size() != n:
		#print("level_1_algo.bfs: vis/par/dis dimension mismatch. vis.size=", vis.size(), "expected=", n)
		# initialize local ones to avoid crashes
		vis = []
		par = []
		dis = []
		for i in range(n):
			vis.append([])
			par.append([])
			dis.append([])
			for j in range(m):
				vis[i].append(false)
				par[i].append(Vector2(-1, -1))
				dis[i].append(0)

	vis[x][y] = true
	par[x][y] = Vector2(-1, -1) # Start cell has no parent
	dis[x][y] = 0

	while q.size() > 0:
		var p = q.pop_front()
		var cx = int(p.x)
		var cy = int(p.y)

		# Ensure the current maze row exists and is an Array before indexing
		if cx < 0 or cx >= n:
			continue
		if typeof(maze[cx]) != TYPE_ARRAY:
			#print("level_1_algo.bfs: invalid maze row at index", cx, "type=", typeof(maze[cx]), "value=", str(maze[cx]))
			#print("Caller coords p=", p, "maze dims=", n, m)
			return Vector2(-1, -1)

		if (maze[cx][cy] == 'C' or maze[cx][cy] == 'B') and dis[cx][cy] > max_distance:
			max_distance = dis[cx][cy]
			target = Vector2(cx, cy)

		# Ensure cy is within bounds before using it
		if cy < 0 or cy >= m:
			continue

		# Explore neighbors
		for i in range(4):
			var ny = int(cy + dy[i])
			var nx = int(cx + dx[i])
			
			if ny >= 0 and ny < m and nx >= 0 and nx < n:
				# Ensure the maze row is an Array before indexing
				if typeof(maze[nx]) != TYPE_ARRAY:
					#print("level_1_algo.bfs: invalid maze row at index", nx, "type=", typeof(maze[nx]), "value=", str(maze[nx]))
					#print("Caller coords cx=", cx, "cy=", cy, "nx=", nx, "ny=", ny, "maze dims=", n, m)
					continue
				# Now safe to index
				if not vis[nx][ny] and maze[nx][ny] != '#':
					vis[nx][ny] = true
					par[nx][ny] = Vector2(cx, cy) # Set parent of (nx, ny) to (cx, cy)
					dis[nx][ny] = dis[cx][cy] + 1 # Increment distance
					q.append(Vector2(nx, ny))
	
	return target

func algo(maze, x, y):
	# Defensive: ensure maze is a valid 2D array
	if typeof(maze) != TYPE_ARRAY or maze.size() == 0 or typeof(maze[0]) != TYPE_ARRAY:
		return []

	var full_path = []
	var n = int(maze.size())
	var m = int(maze[0].size())
	
	while true:
		# Reset visited and distance arrays
		vis = []
		par = []
		dis = []
		for i in range(n):
			vis.append([])
			par.append([])
			dis.append([])
			for j in range(m):
				vis[i].append(false)
				par[i].append(Vector2(-1, -1))
				dis[i].append(0)
		
		# Run BFS to find all reachable coins and their distances
		var neww = bfs(maze, x, y)
		
		if neww.x == -1 and neww.y == -1:
			break # If no 'C' is found, break the loop
		
		# Reconstruct path to the farthest coin
		var path = reconstruct_path(neww.x, neww.y)
		
		# Add the path to the full path
		for p in path:
			full_path.append(p)
		
		# Update x and y to the position of the farthest 'C' found
		x = int(neww.x)
		y = int(neww.y)

		# Mark the current 'C' as visited or block it to avoid revisiting
		maze[x][y] = '.'
	
	return full_path

func path_to_directions(path):
	var directions = []
	for i in range(1, path.size()):
		dx = path[i].x - path[i - 1].x
		dy = path[i].y - path[i - 1].y

		if dx == 1:
			directions.append("Down")
		elif dx == -1:
			directions.append("Up")
		elif dy == 1:
			directions.append("Right")
		elif dy == -1:
			directions.append("Left")
	return directions
	

func reset_state():
	# Clear any persistent arrays to ensure fresh runs when autoloaded
	vis = []
	par = []
	dis = []
	dy = [-1, 1, 0, 0]
	dx = [0, 0, -1, 1]
