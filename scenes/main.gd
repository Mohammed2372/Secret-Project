extends Node2D

# Maze matrix (0 = free, 1 = block)
const MAZE = [
	[0, 0, 1, 1, 1],
	[1, 0, 1, 0, 1],
	[1, 0, 0, 0, 1],
	[1, 1, 1, 0, 1],
	[1, 1, 1, 0, 1]
]

@onready var tile_map = $TileMapLayer

# Tile IDs (set these in the TileSet)
var free_tile_id = 0      # ID for background
var block_tile_id = 1     # ID for block tile
var coin_tile_id = 2      # ID for coin tile
var trap_tile_id = 3      # ID for trap tile
var mut_floor_tile_id = 4 # ID for mut floor tile
var big_coins_tile_id = 5   # ID for big coins tile

# Layer indices (set these in the TileMap)
var block_layer = 0     # Layer for blocks
var coin_layer = 1      # Layer for coins
var trap_layer = 2      # Layer for traps
var mut_floor_layer = 3 # layer for mut floor tile
var big_coins_layer = 4 # layer for big coins

# Called when the node enters the scene tree
func _ready():
	draw_maze(MAZE)

# Draw the maze using the TileMap
func draw_maze(maze):
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			var cell = Vector2i(x, y)  # Use Vector2i for cell coordinates
			if maze[y][x] == 0: # Free
				tile_map.set_cell(cell, free_tile_id, Vector2i.ZERO)
			elif maze[y][x] == 1: # Block
				tile_map.set_cell(cell, block_tile_id, Vector2i.ZERO)
			elif maze[x][y] == 2: # Coins
				tile_map.set_cell(cell, coin_tile_id, Vector2.ZERO)
			elif maze[x][y] == 3: # Traps
				tile_map.set_cell(cell, trap_tile_id, Vector2.ZERO)
			elif maze[x][y] == 4: # Mut floor
				tile_map.set_cell(cell, mut_floor_tile_id, Vector2.ZERO)
			elif maze[x][y] == 5: # Big coins
				tile_map.set_cell(cell, big_coins_tile_id, Vector2.ZERO)
