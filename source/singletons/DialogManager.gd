# This script manages displaying multi-line dialogue boxes on screen.
# It handles instantiating dialogue text box UI scenes, stepping through lines on keypress/click,
# and cleaning up the dialogue UI when conversations finish.
extends Node

# ==========================================
# PRELOADS & CONFIGURATION
# ==========================================
# Preloads the visual text box UI scene used to display dialogue text.
@onready var text_box_scene = preload("res://source/ui/text_box.tscn")

# Fixed screen coordinates where the dialogue box will spawn.
var text_box_position = Vector2(257, 200)

# ==========================================
# STATE & VARIABLES
# ==========================================
# List of string lines to display in sequence during the active conversation.
var dialog_lines: Array[String] = []

# Array index tracking which line is currently being shown.
var current_line_index = 0

# Reference to the active text box UI instance.
var text_box

# Flags tracking whether dialogue is running and whether the typewriter effect has finished writing the current line.
var is_dialog_active = false
var can_advance_line = false

# ==========================================
# DIALOGUE FLOW CONTROLS
# ==========================================
# Starts a new dialogue sequence given an array of string lines.
func start_dialog(lines):
	# Ignore new dialogue requests if a dialogue sequence is already active.
	if is_dialog_active:
		return
		
	dialog_lines = lines
	_show_text_box()
	is_dialog_active = true

# Instantiates and positions the text box UI and feeds it the current line text.
func _show_text_box():
	print(dialog_lines)
	text_box = text_box_scene.instantiate()
	
	# Listen for when the text box finishes printing out the full text line (e.g. typewriter animation complete).
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	
	# Add text box to the main scene root node.
	get_tree().get_first_node_in_group("Main").add_child(text_box)
	text_box.global_position = text_box_position
	
	# Tell text box UI to begin displaying the current line.
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false

# Signal callback: enables player input to advance to the next line once typing completes.
func _on_text_box_finished_displaying():
	can_advance_line = true

# ==========================================
# INPUT HANDLING
# ==========================================
# Listens for player input actions (like spacebar, enter, or click mapped to "advance_dialog").
func _unhandled_input(event):
	if (
		event.is_action_pressed("advance_dialog") &&
		is_dialog_active &&
		can_advance_line
	):
		# Remove current text box UI instance from screen.
		text_box.queue_free()
		current_line_index += 1
		print(current_line_index, dialog_lines.size())
		
		# If we reached the end of the line array, reset state and end conversation.
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			return
			
		# Otherwise, spawn the next text box line!
		_show_text_box()
