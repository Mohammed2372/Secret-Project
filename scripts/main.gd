extends Node2D

@export_category("players")
@export var player: CharacterBody2D
@export var ai: CharacterBody2D

@export_category("wall & coins")
@export var wall_scenes: Array[PackedScene]
@export var coin_scene: PackedScene
@export var special_coin_scene: PackedScene

@export_category("Camera Settings")
@export var ai_viewport_size := Vector2(300, 300)  # Size of the AI viewport
@export var ai_viewport_margin := Vector2(10, 10)  # Margin from screen edges

# Tile maps
@onready var tile_map = $"player tilemap"
@onready var ai_tile_map = $"ai tilemap"

# references to cameras
@onready var player_camera = $PlayerCamera
@onready var ai_camera = $CanvasLayer/SubViewportContainer/SubViewport/AICamera
@onready var ai_viewport_container = $CanvasLayer/SubViewportContainer
@onready var ai_viewport = $CanvasLayer/SubViewportContainer/SubViewport

# references to ui scenes
@onready var pause_menu: Control = $"CanvasLayer/pause menu"
@onready var win_scene: Control = $"CanvasLayer/win panel"
@onready var coin_progress_bar: TextureProgressBar = $"CanvasLayer/coin progress bar"

# variables
var is_ready = false
var round_end = false
var maze_width = 0  # To store the width of the maze for offset calculation
var maze_height = 0
var is_paused = false
var maze_shift_timer: Timer

# TODO: there is an error when you select any level from level menu 
# 	 	when you have played it before not for the first time.
# Fix: i think it is because the global scripts of the algorithms.


func _ready():
	#print("Main script running...")
	
	## make a timer for whole tree to make main script run first
	await get_tree().create_timer(0.2).timeout  # Simulate some setup work
	is_ready = true
	
	## set current level
	Global.level = $".".name.to_int()
	
	## set value of progress bar 
	coin_progress_bar.value = 0
	update_coin_display()
	
	## draw maze based on current level
	get_current_level_and_draw()
	
	## set up player camera
	player_camera.make_current()  # Make it the main camera
	player_camera.position = player.position  # Initially center on player
	
	## Set up AI viewport and ai camera
	ai_viewport.world_2d = get_tree().root.world_2d
	ai_viewport.size = ai_viewport_size # to improve quality
	ai_viewport.msaa_2d = Viewport.MSAA_DISABLED  # Disable anti-aliasing for pixel art
	ai_viewport_container.custom_minimum_size = ai_viewport_size
	
	## set ai camera
	setup_static_ai_camera()
	
	## recieve signal from pause menu
	pause_menu.connect("resume_game", Callable(self, "_on_resume_game"))
	pause_menu.connect("restart_game", Callable(self, "_on_restart_game"))
	pause_menu.connect("go_to_levels_menu", Callable(self, "_on_go_to_levels_menu"))
	pause_menu.connect("go_to_main_menu", Callable(self, "_on_go_to_main_menu"))
	win_scene.connect("next_level", Callable(self, "_on_next_level"))

## Pause menu signal handlers
func _on_resume_game() -> void:
	# Reset state on autoload singletons immediately (stop threads, clear caches)
	get_tree().paused = false
	pause_menu.hide()

func _on_restart_game() -> void:
	# Reset relevant global scores and flags
	Global.player_score = 0
	Global.ai_score = 0
	round_end = false

	# Reset Global state
	if Global.has_method("reset"):
		Global.reset()
	
	if Level1Algo.has_method("reset_state"):
		Level1Algo.reset_state()
	if Level2Algo.has_method("reset_state"):
		Level2Algo.reset_state()
	if Level3Algo.has_method("reset_state"):
		Level3Algo.reset_state()
	if Level4Algo.has_method("reset_state"):
		Level4Algo.reset_state()

	# Clear generated maze storage
	Global.Maze4 = [[]]

	# Unpause, then do a short delayed reload so the tree can unpause cleanly
	get_tree().paused = false
	var timer = get_tree().create_timer(0.05)
	timer.timeout.connect(func():
		get_tree().reload_current_scene()
	)

func _on_go_to_levels_menu() -> void:
	Global.player_score = 0
	Global.ai_score = 0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_levels.tscn")

func _on_go_to_main_menu() -> void:
	Global.player_score = 0
	Global.ai_score = 0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	## Initialize timer for origin shift
	if Global.level == 4:
		maze_shift_timer = Timer.new()
		add_child(maze_shift_timer)
		maze_shift_timer.timeout.connect(_on_maze_shift_timeout)
		maze_shift_timer.one_shot = false
		maze_shift_timer.start(10)  # Start immediately with 10 second interval
	
	#print("Main script finished setup.")
	
func _process(_delta):
	## handle if round ends
	if round_end:
		#print("round end is true !")
		if player.score > ai.score:
			#print("Player wins")
			$"CanvasLayer/win panel/VBoxContainer/congrats".text = "You won this level"
		elif ai.score > player.score:
			#print("Ai wins")
			$"CanvasLayer/win panel/VBoxContainer/congrats".text = "AI won this level"
		else:
			print("Draw, that will never happen in this game, wait how is it happening now lol")
		
		## handle scores
		Global.player_score += player.score
		Global.ai_score += ai.score
		
		## show win scene
		show_win_scene()
		
		## return round_end to alse agian
		round_end = false
	
	# Update camera positions to follow their targets
	if player_camera and player:
		player_camera.global_position = player.global_position
	
	#if ai_camera and ai:
		#ai_camera.global_position = ai.global_position
		
	### level 4 (origin shift) call draw maze to redraw new maze
	#if Global.level == 4:
		### timer to call it every 10 seconds
		#get_current_level_and_draw()

## get current level and draw
func get_current_level_and_draw() -> void:
	## current level
	if Global.level == 1:
		## score
		Global.max_score = Global.MAZE1_MAX_SCORE
		coin_progress_bar.max_value = Global.max_score
		## height and width
		# Use a safe reference to the maze (fall back to default if Global was corrupted)
		var maze_ref: Array
		if typeof(Global.MAZE1) == TYPE_ARRAY and Global.MAZE1.size() > 0 and typeof(Global.MAZE1[0]) == TYPE_ARRAY:
			maze_ref = Global.MAZE1
		else:
			print("Warning: Global.MAZE1 invalid, falling back to default MAZE1")
			maze_ref = Global.get_default_maze1()

		maze_width = maze_ref[0].size()
		maze_height = maze_ref.size()
		## draw
		draw_maze(maze_ref, tile_map, false, Vector2.ZERO)  # Draw player maze with no offset
		draw_maze(maze_ref, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))  # Draw AI maze with offset
	elif Global.level == 2:
		## score
		Global.max_score = Global.MAZE2_MAX_SCORE
		coin_progress_bar.max_value = Global.max_score
		## height and width
		var maze_ref: Array
		if typeof(Global.MAZE2) == TYPE_ARRAY and Global.MAZE2.size() > 0 and typeof(Global.MAZE2[0]) == TYPE_ARRAY:
			maze_ref = Global.MAZE2
		else:
			print("Warning: Global.MAZE2 invalid, falling back to default MAZE2")
			maze_ref = Global.get_default_maze2()

		maze_width = maze_ref[0].size()
		maze_height = maze_ref.size()
		## draw
		draw_maze(maze_ref, tile_map, false, Vector2.ZERO)
		draw_maze(maze_ref, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))
	elif Global.level == 3:
		## score
		Global.max_score = Global.MAZE3_MAX_SCORE
		coin_progress_bar.max_value = Global.max_score
		## height and width
		var maze_ref: Array
		if typeof(Global.MAZE3) == TYPE_ARRAY and Global.MAZE3.size() > 0 and typeof(Global.MAZE3[0]) == TYPE_ARRAY:
			maze_ref = Global.MAZE3
		else:
			print("Warning: Global.MAZE3 invalid, falling back to default MAZE3")
			maze_ref = Global.get_default_maze3()

		maze_width = maze_ref[0].size()
		maze_height = maze_ref.size()
		## draw
		draw_maze(maze_ref, tile_map, false, Vector2.ZERO)
		draw_maze(maze_ref, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))
	elif Global.level == 4:
		# Initialize maze with start and end points
		var maze_data = Level4Algo.initialize_maze()
		Global.Maze4 = maze_data["maze"]
		var start_point = maze_data["start_point"]
		var end_point = maze_data["end_point"]
		Global.Maze4 = Level4Algo.generate_maze(Global.Maze4)
		Level4Algo.print_maze(Global.Maze4)
		
		## height and width
		if typeof(Global.Maze4) != TYPE_ARRAY or Global.Maze4.size() == 0 or typeof(Global.Maze4[0]) != TYPE_ARRAY:
			print("Error: Global.Maze4 is invalid - type:", typeof(Global.Maze4))
			return
		maze_width = Global.Maze4[0].size()
		maze_height = Global.Maze4.size()
		## draw
		draw_maze(Global.Maze4, tile_map, false, Vector2.ZERO)
		draw_maze(Global.Maze4, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))

func _on_maze_shift_timeout():
	if Global.level == 4 and is_ready and not round_end:
		# Clear old maze first
		tile_map.clear()
		ai_tile_map.clear()
		
		# Generate new maze
		var maze_data = Level4Algo.initialize_maze()
		Global.Maze4 = Level4Algo.generate_maze(maze_data["maze"])
		
		# Redraw
		maze_width = Global.Maze4[0].size()
		maze_height = Global.Maze4.size()
		draw_maze(Global.Maze4, tile_map, false, Vector2.ZERO)
		draw_maze(Global.Maze4, ai_tile_map, true, 
			Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))
		
		# Reposition players
		#reposition_players(maze_data["start_point"])
		
func reposition_players(start_pos: Vector2):
	player.position = tile_map.map_to_local(start_pos)
	ai.position = ai_tile_map.map_to_local(start_pos)
	
## draw maze
func draw_maze(maze, target_tilemap, is_ai_maze, offset) -> void:
	var tile_size = Vector2(target_tilemap.tile_set.tile_size) * target_tilemap.scale
	
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			var char = maze[y][x]
			var world_pos = target_tilemap.map_to_local(Vector2i(x, y)) * target_tilemap.scale
			world_pos += tile_size / 2.0
			world_pos += offset  # Add the provided offset
			
			var instance = null
			
			if char == "C":
				instance = coin_scene.instantiate()
			elif char == "B":
				instance = special_coin_scene.instantiate()
			elif char == "#":
				instance = randomize_wall_scenes().instantiate()
			elif char == "S" and not is_ai_maze:
				# Only place player in player maze
				player.global_position = world_pos
				player.global_position -= Vector2(60, 80)
				continue
			elif char == "S" and is_ai_maze:
				# Only place AI in AI maze
				ai.global_position = world_pos
				ai.global_position -= Vector2(60,80)
				continue
			elif (char == "P" and is_ai_maze) or (char == "S" and not is_ai_maze):
				# Skip placing player in AI maze or AI in player maze
				continue
			
			if instance:
				instance.position = world_pos
				add_child(instance)

## random wall scene to use
func randomize_wall_scenes() -> PackedScene:
	if wall_scenes.size() > 0:
		var rand_index = randi() % wall_scenes.size()  # Generate a random index
		var rand_scene = wall_scenes[rand_index]  # Get the random scene
		return rand_scene
	return null

## coins progress bar
func update_coin_display() -> void:
	coin_progress_bar.value = player.score

## setup mini camera
func setup_static_ai_camera() -> void:
	# Calculate the AI maze offset
	var maze_offset = Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0)
	
	# Calculate the center of the AI maze
	var maze_center = Vector2(
		maze_width * 0.5 * tile_map.tile_set.tile_size.x * tile_map.scale.x,
		maze_height * 0.5 * tile_map.tile_set.tile_size.y * tile_map.scale.y
	)
	
	# Position the AI camera at the center of the AI maze (with the offset)
	ai_camera.global_position = maze_center + maze_offset
	
	# Calculate maze dimensions in pixels
	var maze_size = Vector2(
		maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x,
		maze_height * tile_map.tile_set.tile_size.y * tile_map.scale.y
	)
	
	# Calculate zoom factor to fit the entire maze with some margin
	var zoom_factor = min(
		ai_viewport_size.x / maze_size.x,
		ai_viewport_size.y / maze_size.y
	) * 0.9  # 0.9 gives a margin around the maze
	
	# Set camera zoom
	ai_camera.zoom = Vector2(zoom_factor, zoom_factor)

## win scene
func show_win_scene() -> void:
	get_tree().paused = true
	win_scene.show_win_screen(Global.player_score, Global.ai_score)

func _on_next_level() -> void:
	print("next level button pressed")
	get_tree().paused = false
	load_next_level()

func load_next_level() -> void:
	# Logic to determine and load the next level
	var current_scene = get_tree().current_scene.scene_file_path
	var next_scene = get_next_level_path(current_scene)
	
	if next_scene:
		get_tree().change_scene_to_file(next_scene)
	else:
		print("No next level found!")  # Handle when no next level is available

func get_next_level_path(current_scene: String) -> String:
	var levels = [
		"res://scenes/Level 1.tscn",
		"res://scenes/Level 3.tscn",
		"res://scenes/Level 2.tscn",
		#"res://scenes/Level 4.tscn",
		"res://scenes/menu_levels.tscn",
	]
	
	var index = levels.find(current_scene)
	if index != -1 and index + 1 < levels.size():
		return levels[index + 1]
	return ""
