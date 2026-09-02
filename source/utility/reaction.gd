# Extends "Marker2D", making this a 2D spatial anchor point used to spawn floating 
# reaction/emotion icon popups (e.g., happy, sad, love hearts) above a pet's head.
extends Marker2D

# ==========================================
# NODE REFERENCES & CONFIGURATION
# ==========================================
# The Sprite2D node containing the reaction icon spritesheet.
@onready var sprite = $Sprite2D

# Choices used for pick_random() directional movement.
var direction_choices = ['left', 'right']

# ==========================================
# INITIALIZATION & FLOAT ANIMATION
# ==========================================
func _ready():
	# Seed the random number generator for unique scatter trajectories.
	randomize()
	
	# Create a smooth tween animation to drift the reaction icon upward and sideways.
	var tween = get_tree().create_tween()
	var direction = direction_choices.pick_random()
	
	# Tween the sprite's position relative to global space using a randomized vector offset over 0.8 seconds.
	if direction == 'left':
		tween.tween_property(sprite, "position", global_position + _get_direction(), 0.8)
	else:
		tween.tween_property(sprite, "position", global_position + _get_direction(), 0.8)

# Generates a randomized 2D displacement vector pointing generally upward and slightly left/right.
func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 32

# ==========================================
# REACTION FRAME SELECTION
# ==========================================
# Sets the specific spritesheet frame index corresponding to the pet's reaction type.
func set_reaction(reaction):
	match reaction:
		"happy":
			sprite.set_frame(0)
		"sad":
			sprite.frame = 15
		"neutral":
			sprite.frame = 3
		"sick":
			sprite.frame = 9
		"love":
			sprite.frame = 2
