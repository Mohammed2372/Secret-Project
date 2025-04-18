extends Node

#var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var dirs = [Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]
var dir_names = ["Up", "Down", "Left", "Right"]

# Thread for AI pathfinding
var ai_thread = Thread.new()
var ai_result

func find_coin_locations(maze: Array) -> Dictionary:
	var coins = []
	var start = null
	
	for i in range(maze.size()):
		for j in range(maze[i].size()):
			if maze[i][j] == "C" or maze[i][j] == "B":
				coins.append(Vector2(i, j))
			elif maze[i][j] == "S":
				start = Vector2(i, j)
	
	return {"start": start, "coins": coins}

func bfs_with_path(maze: Array, start: Vector2, target: Vector2) -> Array:
	var rows = maze.size()
	var cols = maze[0].size()
	var queue = [start]
	var parent = {}
	parent[start] = null
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == target:
			var path = []
			var node = target
			while node != null:
				path.push_front(node)
				node = parent.get(node)
			return path
		
		for i in range(4):
			var next_pos = current + dirs[i]
			if next_pos.x >= 0 and next_pos.x < rows and next_pos.y >= 0 and next_pos.y < cols and maze[next_pos.x][next_pos.y] != "#" and not parent.has(next_pos):
				parent[next_pos] = current
				queue.append(next_pos)
	
	return []

func build_distance_matrix(maze: Array, coins: Array, start: Vector2) -> Array:
	var k = coins.size()
	var dist = []
	
	for i in range(k + 1):
		dist.append([])
		for j in range(k + 1):
			dist[i].append(100000)
	
	for i in range(k):
		var path = bfs_with_path(maze, start, coins[i])
		if path.size() > 0:
			dist[0][i + 1] = path.size() - 1
			dist[i + 1][0] = path.size() - 1
	
	for i in range(k):
		for j in range(k):
			if i == j:
				dist[i + 1][j + 1] = 0
			else:
				var path = bfs_with_path(maze, coins[i], coins[j])
				if path.size() > 0:
					dist[i + 1][j + 1] = path.size() - 1
	
	return dist

func tsp_with_path(dist: Array, n: int) -> Dictionary:
	var dp = []
	var parent = []
	
	for i in range(1 << n):
		dp.append([])
		parent.append([])
		for j in range(n):
			dp[i].append(100)
			parent[i].append(-1)
	
	dp[1][0] = 0
	
	for mask in range(1 << n):
		for u in range(n):
			if not (mask & (1 << u)):
				continue
			for v in range(n):
				if u == v or not (mask & (1 << v)):
					continue
				if dp[mask ^ (1 << u)][v] + dist[v][u] < dp[mask][u]:
					dp[mask][u] = dp[mask ^ (1 << u)][v] + dist[v][u]
					parent[mask][u] = v
	
	var final_mask = (1 << n) - 1
	var min_cost = 100000
	var last_city = -1
	
	for u in range(1, n):
		if dp[final_mask][u] + dist[u][0] < min_cost:
			min_cost = dp[final_mask][u] + dist[u][0]
			last_city = u
	
	var path = []
	if last_city != -1:
		var mask = final_mask
		var u = last_city
		while u != -1:
			path.push_front(u)
			var prev_u = parent[mask][u]
			mask ^= (1 << u)
			u = prev_u
	
	return {"cost": min_cost, "path": path}

func get_full_path(maze: Array, coins: Array, coin_order: Array, start: Vector2) -> Array:
	var full_path = []
	
	var first_coin_index = coin_order[1] - 1
	var start_to_first = bfs_with_path(maze, start, coins[first_coin_index])
	if start_to_first.size() > 0:
		full_path.append_array(start_to_first)
	
	for i in range(1, coin_order.size() - 1):
		var from_index = coin_order[i] - 1
		var to_index = coin_order[i + 1] - 1
		var segment_path = bfs_with_path(maze, coins[from_index], coins[to_index])
		if segment_path.size() > 0:
			full_path.append_array(segment_path)
	
	var last_coin_index = coin_order.back() - 1
	var last_to_start = bfs_with_path(maze, coins[last_coin_index], start)
	if last_to_start.size() > 0:
		full_path.append_array(last_to_start)
	
	return full_path

func path_to_directions(path: Array) -> Array:
	var directions = []
	for i in range(1, path.size()):
		var dx = path[i].x - path[i - 1].x
		var dy = path[i].y - path[i - 1].y
		for j in range(4):
			if dirs[j] == Vector2(dx, dy):
				directions.append(dir_names[j])
				break
	return directions
# Function to run in the thread
func _ai_pathfinding(maze: Array):
	var data = find_coin_locations(maze)
	var start = data["start"]
	var coins = data["coins"]
	
	if start == null or coins.size() == 0:
		ai_result = []
		return
	
	var dist = build_distance_matrix(maze, coins, start)
	var tsp_result = tsp_with_path(dist, coins.size() + 1)
	var coin_order = tsp_result["path"]
	var full_path = get_full_path(maze, coins, coin_order, start)
	ai_result = path_to_directions(full_path)

# Start the AI pathfinding in a separate thread and wait for the result
func get_ai_directions(maze: Array) -> Array:
	if ai_thread.is_started():
		ai_thread.wait_to_finish()  # Ensure the thread is not already running
	
	ai_result = null  # Reset the result
	ai_thread.start(Callable(self, "_ai_pathfinding").bind(maze))
	
	# Wait for the thread to finish
	ai_thread.wait_to_finish()
	
	return ai_result

# Clean up the thread when done
func _exit_tree():
	if ai_thread.is_started():
		ai_thread.wait_to_finish()
