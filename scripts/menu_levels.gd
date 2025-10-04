extends Control

## buttons
@onready var level1 = $"levels_container/Level1"
@onready var level2 = $"levels_container/Level2"
@onready var level3 = $"levels_container/Level3"
@onready var level4 = $"levels_container/Level4"
@onready var quit_button = $VBoxContainer/Quit

# Called when the node enters the scene tree for the first time.
func _ready():
	## hide levels menu
	#hide()
	$levels_container/Level1.grab_focus()
	
	## Connect buttons to respective functions
	level1.connect("pressed", Callable(self, "_on_level_1_button_pressed"))
	level2.connect("pressed", Callable(self, "_on_level_2_button_pressed"))
	level3.connect("pressed", Callable(self, "_on_level_3_button_pressed"))
	level4.connect("pressed", Callable(self, "_on_level_4_button_pressed"))
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_level_1_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level 1.tscn")

func _on_level_2_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level 2.tscn")

func _on_level_3_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level 3.tscn")

func _on_level_4_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level 4.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
