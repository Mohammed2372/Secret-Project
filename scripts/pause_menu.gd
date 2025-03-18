extends Control

## buttons
@onready var resume_button = $"VBoxContainer/Resume button"
@onready var restart_button = $"VBoxContainer/Restart button"
@onready var level_menus_button = $"VBoxContainer/Level menu button"
@onready var main_menu_button = $"VBoxContainer/Main menu button"

## signals to communicate with the main game scene
signal resume_game
signal restart_game
signal go_to_levels_menu
signal go_to_main_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure it works when paused
	## connect buttons to their respective functoins
	resume_button.connect("pressed", Callable(self, "resume_pressed"))
	restart_button.connect("pressed", Callable(self, "restart_pressed"))
	level_menus_button.connect("pressed", Callable(self, "levels_menu_presses"))
	main_menu_button.connect("pressed", Callable(self, "mainmenu_pressed"))

## inputs
func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if visible:
		hide()
		get_tree().paused = false  
	else:
		show()
		$"VBoxContainer/Resume button".grab_focus()
		get_tree().paused = true 

## resume
func resume_pressed():
	toggle_pause()

## restart
func restart_pressed():
	print("restart button pressed")
	get_tree().paused = false
	var timer = get_tree().create_timer(0.1)  # Small delay
	timer.timeout.connect(func():
		get_tree().reload_current_scene()
	)
	
## levels menu
func levels_menu_presses():
	print("levels menu button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_levels.tscn")

## main menu
func mainmenu_pressed():
	print("main menu button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
