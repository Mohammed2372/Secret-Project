extends Node2D

@export var player: Node2D
@export var ai: Node2D
@export var player_camera: Camera2D
@export var ai_camera: Camera2D
@export var ai_viewport: SubViewport

func _ready():
	# Make sure the AI viewport can see the same world
	ai_viewport.world_2d = get_tree().root.world_2d

func _process(delta):
	# Update camera positions
	if player and player_camera:
		player_camera.global_position = player.global_position
		
	if ai and ai_camera:
		ai_camera.global_position = ai.global_position
