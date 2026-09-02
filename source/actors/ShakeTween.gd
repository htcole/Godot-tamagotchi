# This script procedurally shakes/wobbles a sprite back and forth using Godot Tweens.
# It inherits from Node because it only manages visual animation logic.
extends Node

# Gets a direct reference to the "Sprite2D" node sitting under the parent node.
@onready var sprite = get_parent().get_node("Sprite2D")

# ==========================================
# SHAKE CONFIGURATION & CONSTANTS
# ==========================================
# Initial maximum horizontal displacement (pixels) and rotation angle (degrees).
var x_max = 5
var r_max = 5

# The point at which the remaining shake offset is tiny enough to stop the loop.
const STOP_THERSHOLD = 0.1

# Duration (in seconds) for each individual tilt step (left or right).
const TWEEN_DURATION = 0.05

# Multiplier applied after each tilt to decay (dampen) the shake energy (reduces intensity to ~66% each tilt).
const RECOVERY_FACTOR = 2.0 / 3

# Transition curve type for smooth sine-wave motion.
const TRANSITION_TYPE = Tween.TRANS_SINE

# Emitted when the entire shaking animation loop has finished.
signal tween_completed

# ==========================================
# MAIN SHAKE LOOP
# ==========================================
# Call this function to trigger the shaking animation (e.g. when pet takes damage or reacts).
func start():
	var x = x_max
	var r = r_max
	
	# Keep shaking back and forth as long as the remaining offset 'x' is above the stop threshold.
	while x > STOP_THERSHOLD:
		
		# 1. Tilt Left
		var tween = _tilt_left(x, r)
		await tween.finished # Pause loop until the left-tilt animation completes
		x *= RECOVERY_FACTOR # Reduce horizontal distance for the next step
		r *= RECOVERY_FACTOR # Reduce rotation angle for the next step
		
		_recenter()
		
		# 2. Tilt Right
		tween = _tilt_right(x, r)
		await tween.finished # Pause loop until the right-tilt animation completes
		x *= RECOVERY_FACTOR # Reduce horizontal distance again
		r *= RECOVERY_FACTOR # Reduce rotation angle again
		
		_recenter()
		
	# Notify listening scripts that the pet has stopped shaking.
	emit_signal("tween_completed")

# ==========================================
# HELPER TWEEN FUNCTIONS
# ==========================================
# Creates a tween that tilts the sprite to the left (-x position, positive rotation).
func _tilt_left(x, r):
	var tween = get_tree().create_tween()
	
	# Animate Sprite's horizontal position (position:x) to -x
	tween.tween_property(sprite, "position:x", -x, TWEEN_DURATION)
	
	# Animate Sprite's rotation degrees to +r
	tween.tween_property(sprite, "rotation_degrees", r, TWEEN_DURATION)
	return tween

# Creates a tween that tilts the sprite to the right (+x position, negative rotation).
func _tilt_right(x, r):
	var tween = get_tree().create_tween()
	
	# Animate Sprite's horizontal position (position:x) to +x
	tween.tween_property(sprite, "position:x", x, TWEEN_DURATION)
	
	# Animate Sprite's rotation degrees to -r
	tween.tween_property(sprite, "rotation_degrees", -r, TWEEN_DURATION)
	return tween

# Generates a quick tween holding the sprite's current position and rotation state.
func _recenter():
	var tween = get_tree().create_tween()
	
	# Position snapshot
	var host_x = sprite.position.x
	tween.tween_property(sprite, "position:x", host_x, TWEEN_DURATION)
	
	# Rotation snapshot
	var host_r = sprite.rotation_degrees
	tween.tween_property(sprite, "rotation_degrees", host_r, TWEEN_DURATION)
	return tween
