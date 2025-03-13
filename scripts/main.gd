extends Node2D

@export_category("players")
@export var player: CharacterBody2D
@export var ai: CharacterBody2D
@export_category("wall & coins & traps")
@export var wall_scene: PackedScene
@export var coin_scene: PackedScene
@export var special_coin_scene: PackedScene

@onready var tile_map = $TileMapLayer

var is_ready = false
var player_score
var ai_score
var round_end = false

func _ready():
	print("Main script running...")
	
	## make a timer for whole tree to make main script run first
	await get_tree().create_timer(0.2).timeout  # Simulate some setup work
	is_ready = true
	
	## set current level
	Global.level = $".".name.to_int()
	print("current level is: ", Global.level)
	
	## player and ai scores initalization
	player_score = player.score
	ai_score = ai.score
	
	## setting for the second camera
	## TODO: make the new camera for the player and make the two cameras shows in the scene
	
	## current level
	if Global.level == 1:
		Global.max_score = 5
		draw_maze(Global.MAZE1)
	elif Global.level == 2:
		Global.max_score = 10
		draw_maze(Global.MAZE2)
	elif Global.level == 3:
		Global.max_score = 15
		draw_maze(Global.MAZE3)
		
	print("Main script finished setup.")

func _process(delta):
	if round_end:
		if player_score > ai_score:
			print("Player wins")
		elif ai_score > player_score:
			print("Ai wins")
		else:
			print("Draw")
		
# Draw the maze using the TileMap
func draw_maze(maze):
	var tile_size = Vector2(tile_map.tile_set.tile_size) * tile_map.scale  # Convert to Vector2
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			var char = maze[y][x]
			var world_pos = tile_map.map_to_local(Vector2i(x, y)) * tile_map.scale  # Adjust for scale
			# Center objects inside tiles
			world_pos += tile_size / 2.0  
			
			var instance = null
			
			if char == "C":
				instance = coin_scene.instantiate()
			elif char == "B":
				instance = special_coin_scene.instantiate()
			elif char == "#":
				instance = wall_scene.instantiate()
			elif char == "S":
				ai.global_position = world_pos  # Set AI position directly
				continue  
			
			if instance:
				instance.position = world_pos
				add_child(instance)
