# Extends "MarginContainer", making this a dynamic floating speech bubble UI element 
# that auto-resizes around text and displays dialogue using a typewriter effect with natural pacing.
extends MarginContainer

# ==========================================
# NODE REFERENCES
# ==========================================
# Label node that renders dialogue text.
@onready var label = $MarginContainer/Label

# Timer node controlling the delay speed between individual character reveals.
@onready var timer = $LetterDisplayTimer

# ==========================================
# CONFIGURATION CONSTANTS & VARIABLES
# ==========================================
# Maximum pixel width of speech bubble before text wraps onto a new line.
const MAX_WIDTH = 400

# Dialogue content & character tracking variables.
var text = ""
var letter_index = 0

# Pacing parameters (in seconds) for typewriter animation rhythms.
var letter_time = 0.03       # Standard delay per character
var space_time = 0.06        # Delay between words
var punctuation_time = 0.2   # Brief pause on punctuation for natural speech cadence

# Custom signal emitted when the entire text message finishes rendering.
signal finished_displaying()

# ==========================================
# SPEECH BUBBLE SETUP & AUTO-RESIZING
# ==========================================
# Prepares speech bubble positioning/sizing and triggers typewriter rendering.
func display_text(text_to_display: String):
	text = text_to_display
	label.text = text_to_display
	
	# Wait for container to calculate text width bounds.
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	# If text exceeds maximum allowable width, enable word wrap and recalculate height.
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
		
	# Offset bubble position so it centers directly above the target entity head position.
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	# Clear full label text string and begin typewriter character-by-character reveal.
	label.text = ""
	_display_letter()

# ==========================================
# TYPEWRITER ANIMATION & PACING
# ==========================================
# Appends the next letter from the string and sets variable timer delays based on character type.
func _display_letter():
	label.text += text[letter_index]
	letter_index += 1
	
	# Check if end of dialogue string is reached.
	if letter_index >= text.length():
		finished_displaying.emit()
		return
		
	# Adjust typing speed based on upcoming character type for realistic conversational cadence.
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)  # Longer pause after punctuation mark
		" ":
			timer.start(space_time)        # Medium pause between words
		_:
			timer.start(letter_time)       # Fast delay for standard letters

# Timer callback triggered when letter delay elapses, prompting the next character reveal.
func _on_letter_display_timer_timeout():
	_display_letter()
