extends Control

## buttons
@onready var start_button = $"VBoxContainer/Start"
#@onready var option_button = $"BoxContainer/Option Button"
@onready var quit_button = $"VBoxContainer/Quit"
@onready var box_container = $"VBoxContainer"

## levels menu scene
@onready var levels_menu = $"menu levels"

func _ready():
	## Connect buttons to respective functions
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	#option_button.connect("pressed", Callable(self, "_on_options_button_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))

func _on_start_button_pressed():
	print("Start button pressed!")
	hide_buttons()
	levels_menu.show()
	$"menu levels/levels_container/Level1".grab_focus()
	
func _on_quit_button_pressed():
	print("quit button pressed")
	get_tree().quit()

func _on_back_button_pressed():
		levels_menu.hide()
		show_buttons()
		$VBoxContainer/Start.grab_focus()

func hide_buttons():
	box_container.hide()  # Assuming BoxContainer contains your Start/Options/Quit buttons

func show_buttons():
	box_container.show()
