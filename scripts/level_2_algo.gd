extends Node

# Directions: up, down, left, right
var dy = [-1, 1, 0, 0]
var dx = [0, 0, -1, 1]
var vis = []
var par = [] # Parent array

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

# BFS to find the shortest path to the nearest 'C' or 'B'
func bfs(maze, xx, yy):
	var n = maze.size()
	var m = maze[0].size()
	var q = []
	q.append(Vector2(xx, yy))
	vis[xx][yy] = true
	par[xx][yy] = Vector2(-1, -1) # Start cell has no parent
	
	while q.size() > 0:
		var p = q.pop_front()
		var x = p.x
		var y = p.y
		
		for i in range(4):
			var ny = y + dy[i]
			var nx = x + dx[i]
			
			if ny >= 0 and ny < n and nx >= 0 and nx < m and not vis[nx][ny] and maze[nx][ny] != '#':
				vis[nx][ny] = true
				par[nx][ny] = Vector2(x, y) # Set parent of (nx, ny) to (x, y)
				q.append(Vector2(nx, ny))
				
				if maze[nx][ny] == 'B' or maze[nx][ny] == 'C':
					return reconstruct_path(nx, ny) # Reconstruct path from (nx, ny) to start
	
	return [] # Return empty path if no 'C' or 'B' is found

func algo(maze, x, y):
	var full_path = []
	var n = maze.size()
	var m = maze[0].size()
	
	while true:
		# Reset visited and parent arrays
		vis = []
		par = []
		for i in range(n):
			vis.append([])
			par.append([])
			for j in range(m):
				vis[i].append(false)
				par[i].append(Vector2(-1, -1))
		
		var path = bfs(maze, x, y)
		if path.size() == 0:
			break # If no 'C' or 'B' is found, break the loop
		
		# Add the path to the full path
		for p in path:
			full_path.append(p)
		
		# Update x and y to the position of the last 'C' or 'B' found
		x = path[-1].x
		y = path[-1].y
		
		# Mark the current 'C' or 'B' as visited or block it to avoid revisiting
		maze[x][y] = '#'
	
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
