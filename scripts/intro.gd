extends Node2D
@export var main_scene: PackedScene

@onready var sound = $AudioStreamPlayer2D
@onready var anime = $Animat_intro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	anime.play("black_in");
	sound.play();
	get_tree().create_timer(4).timeout.connect(black_out);


func black_out():
	anime.play("black_out");
	get_tree().create_timer(1.5).timeout.connect(start_menu);

func start_menu():
	#get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn");
	get_tree().change_scene_to_packed(main_scene)
