# This script extends "Label", meaning it attaches directly to a text UI node.
# It handles formatting and displaying the pet's current level, current XP, and XP needed for the next level.
extends Label

# ==========================================
# UI TEXT UPDATE
# ==========================================
# Updates the text shown on screen using the pet's leveling stats.
# Called whenever the pet gains experience or levels up.
func update_label(level, experience, required_exp):
	# Using triple quotes (""") allows writing a multi-line string in GDScript.
	# The '%s' placeholders are automatically replaced in order by the array values [level, experience, required_exp].
	text = """Level: %s
	Experience: %s
	Next level: %s
	""" % [level, experience, required_exp]
