extends Node2D

@export_category("players")
@export var player: CharacterBody2D
@export var ai: CharacterBody2D

@export_category("wall & coins & traps")
@export var wall_scene: PackedScene
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

# variables
var is_ready = false
var round_end = false
var maze_width = 0  # To store the width of the maze for offset calculation
var maze_height = 0
var is_paused = false

func _ready():
	print("Main script running...")
	
	## make a timer for whole tree to make main script run first
	await get_tree().create_timer(0.2).timeout  # Simulate some setup work
	is_ready = true
	
	## set current level
	Global.level = $".".name.to_int()
	print("current level is: ", Global.level)
	
	## set up player camera
	player_camera.make_current()  # Make it the main camera
	player_camera.position = player.position  # Initially center on player
	
	## Set up AI viewport and ai camera
	ai_viewport.world_2d = get_tree().root.world_2d
	ai_viewport.size = ai_viewport_size # to improve quality
	ai_viewport.msaa_2d = Viewport.MSAA_DISABLED  # Disable anti-aliasing for pixel art
	ai_viewport_container.custom_minimum_size = ai_viewport_size
	
	## current level
	if Global.level == 1:
		Global.max_score = Global.MAZE1_MAX_SCORE
		maze_width = Global.MAZE1[0].size()  # Get width for offset
		maze_height = Global.MAZE1.size()
		draw_maze(Global.MAZE1, tile_map, false, Vector2.ZERO)  # Draw player maze with no offset
		draw_maze(Global.MAZE1, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))  # Draw AI maze with offset
	elif Global.level == 2:
		Global.max_score = Global.MAZE2_MAX_SCORE
		maze_width = Global.MAZE2[0].size()
		maze_height = Global.MAZE2.size()
		draw_maze(Global.MAZE2, tile_map, false, Vector2.ZERO)
		draw_maze(Global.MAZE2, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))
	elif Global.level == 3:
		Global.max_score = Global.MAZE3_MAX_SCORE
		maze_width = Global.MAZE3[0].size()
		maze_height = Global.MAZE3.size()
		draw_maze(Global.MAZE3, tile_map, false, Vector2.ZERO)
		draw_maze(Global.MAZE3, ai_tile_map, true, Vector2(maze_width * tile_map.tile_set.tile_size.x * tile_map.scale.x * 2, 0))
	elif Global.level == 4:
		print("origin shift level")
		
	## set ai camera
	setup_static_ai_camera()
	
	## recieve signal from pause menu
	pause_menu.connect("resume_game", Callable(self, "_on_resume_game"))
	pause_menu.connect("restart_game", Callable(self, "_on_restart_game"))
	pause_menu.connect("go_to_levels_menu", Callable(self, "_on_go_to_levels_menu"))
	pause_menu.connect("go_to_main_menu", Callable(self, "_on_go_to_main_menu"))
	win_scene.connect("next_level", Callable(self, "_on_next_level"))
	
	print("Main script finished setup.")

func _process(_delta):
	## handle if round ends
	if round_end:
		print("round end is true !")
		if player.score > ai.score:
			$"CanvasLayer/win panel/VBoxContainer/congrats".text = "Player won this level"
			print("Player wins")
		elif ai.score > player.score:
			$"CanvasLayer/win panel/VBoxContainer/congrats".text = "AI won this level"
			print("Ai wins")
		else:
			print("Draw")  # this one will never happen
		
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

## draw maze
func draw_maze(maze, target_tilemap, is_ai_maze, offset):
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
				instance = wall_scene.instantiate()
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

## setup mini camera
func setup_static_ai_camera():
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
func show_win_scene():
	get_tree().paused = true
	win_scene.show_win_screen(Global.player_score, Global.ai_score)

func _on_next_level():
	print("next level button pressed")
	get_tree().paused = false
	load_next_level()

func load_next_level():
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
		"res://scenes/Level 2.tscn",
		"res://scenes/Level 3.tscn",
		"res://scenes/Level 4.tscn",
		"res://scenes/menu_levels.tscn",
	]
	
	var index = levels.find(current_scene)
	if index != -1 and index + 1 < levels.size():
		return levels[index + 1]
	return ""
