extends Control

## UI Elements
@onready var player_score_label = $"VBoxContainer/player score"
@onready var ai_score_label = $"VBoxContainer/ai score"
@onready var next_level_button = $"VBoxContainer/next level button"

## Signal for transitioning to the next level
signal next_level

func _ready():
	hide()  # Hide initially
	next_level_button.pressed.connect(_on_next_level_pressed)

## Function to update score and show win screen
func show_win_screen(player_score: int, ai_score: int):
	player_score_label.text = "Your Score: " + str(player_score)
	ai_score_label.text = "AI Score: " + str(ai_score)
	visible = true
	$"VBoxContainer/next level button".grab_focus()

## Emit signal when next level button is pressed
func _on_next_level_pressed():
	#print("Next Level Button Pressed")
	emit_signal("next_level")
