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
	## connect buttons to their respective functoins
	resume_button.connect("pressed", Callable(self, "resume_pressed"))
	restart_button.connect("pressed", Callable(self, "restart_pressed"))
	level_menus_button.connect("pressed", Callable(self, "levels_menu_presses"))
	main_menu_button.connect("pressed", Callable(self, "mainmenu_pressed"))

func resume_pressed():
	emit_signal("resume_game")

func restart_pressed():
	emit_signal("restart_game")

func levels_menu_presses():
	emit_signal("go_to_levels_menu")

func mainmenu_pressed():
	emit_signal("go_to_main_menu")
