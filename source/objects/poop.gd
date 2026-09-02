# This script extends "Area2D", allowing it to detect mouse clicks and physical touches in 2D space.
# It controls the interaction for cleanup items (like poop) spawned in the room.
extends Area2D

# ==========================================
# SIGNALS
# ==========================================
# Emitted when this poop object is clicked and removed.
# Listened to by PetActions/Room script to decrement `poop_counter` and award player rewards.
signal poop_removed

# ==========================================
# INPUT EVENT HANDLING
# ==========================================
# Runs automatically whenever an input event (mouse hover, click, or screen tap) occurs over this Area2D's collision shape.
func _on_input_event(_viewport, event, _shape_idx):
	# Check if the input event is a mouse button press.
	if event is InputEventMouseButton:
		# Check if the event was specifically a Left Mouse Click.
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Notify parent systems that a poop was cleaned up (so hygiene counters/penalties can update).
			poop_removed.emit()
			
			# Deletes (frees) this poop node from the scene tree at the end of the current frame.
			queue_free()
